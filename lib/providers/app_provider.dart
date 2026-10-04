import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/shop_theme.dart';
import '../models/shop_theme_config.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/market_api.dart';

/// Single source of truth for the app, backed entirely by the Nest API.
///
/// Every method that touches the network is asynchronous: the UI awaits it and
/// shows a spinner or an error, because the previous in-memory behaviour (a
/// synchronous `bool` that always succeeded) hid failures.
class AppProvider extends ChangeNotifier {
  AppProvider({ApiClient? client}) : _client = client ?? ApiClient() {
    _api = MarketApi(_client);
  }

  final ApiClient _client;
  late final MarketApi _api;

  // ─── Session ───

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  String? _authError;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get authError => _authError;

  // ─── Language ───

  AppLanguage _language = AppLanguage.fr;

  /// Language of the interface. Only the wording of the app is translated:
  /// products, shops and profiles are shown exactly as their author wrote
  /// them.
  AppLanguage get language => _language;

  AppStrings get strings => AppStrings(_language);

  /// Switches the interface language and remembers it for the next launch.
  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;

    _language = language;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);
  }

  static const _languageKey = 'app_language';

  Future<void> _restoreLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(_languageKey));
  }

  // ─── Loading state ───

  bool _booting = true;
  bool _loading = false;
  String? _dataError;

  /// True until the saved session and the first catalog load have settled.
  /// Screens use it to hold back a spinner instead of flashing empty data.
  bool get booting => _booting;

  bool get loading => _loading;
  String? get dataError => _dataError;

  // ─── Data ───

  List<Product> _products = [];
  List<Shop> _shops = [];
  List<Category> _categories = [];
  List<Order> _orders = [];

  /// Orders placed against the shops the user owns, all of them.
  List<Order> _receivedOrders = [];

  /// Orders received per shop id, for the shop detail screen.
  final Map<String, List<Order>> _shopOrders = {};

  /// Counters per shop id: number of orders and average rating.
  final Map<String, ShopStats> _shopStats = {};

  /// Rating the user already gave a shop, per shop id.
  final Map<String, int> _myShopRatings = {};

  List<AppNotification> _notifications = [];

  /// Notifications published by the admin.
  List<AppNotification> get notifications => _notifications;

  /// Notifications the user has not opened yet, for the bell badge.
  int get unreadNotifications =>
      _notifications.where((notification) => !notification.isRead).length;
  String _searchQuery = '';
  String _selectedCategory = '';
  bool? _filterNeuf;

  List<Product> get products => _products;
  List<Shop> get shops => _shops;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
  List<Order> get receivedOrders => _receivedOrders;

  /// Orders received for one shop, empty until [loadShopOrders] ran.
  List<Order> ordersOfShop(String shopId) => _shopOrders[shopId] ?? const [];

  /// Counters of a shop, or null while [loadShopStats] is still running.
  ShopStats? statsOfShop(String shopId) => _shopStats[shopId];

  /// The rating the user already gave a shop, 0 when they gave none.
  int myRatingOf(String shopId) => _myShopRatings[shopId] ?? 0;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool? get filterNeuf => _filterNeuf;

  // ═══════════════════════════════════
  // BOOTSTRAP
  // ═══════════════════════════════════

  /// Restores a saved session, then loads the catalog.
  ///
  /// Safe to call once at startup. A restored session that the API rejects is
  /// discarded rather than surfaced as an error: the user simply lands on the
  /// login screen.
  Future<void> initialize() async {
    _booting = true;
    notifyListeners();

    await _restoreLanguage();
    await _client.restoreSession();

    if (_client.hasSession) {
      try {
        _currentUser = await _api.me();
        _isLoggedIn = true;
      } on ApiException {
        await _client.clearSession();
        _currentUser = null;
        _isLoggedIn = false;
      }
    }

    await _loadCatalog();

    // A restored session must load the orders too: "Mes Commandes" reads them
    // from the provider, and it was empty until the user logged out and back in.
    if (_isLoggedIn) {
      await loadOrders();
      await loadNotifications();
    }

    _booting = false;
    notifyListeners();
  }

  /// Loads everything the browsing screens need.
  ///
  /// Each call is independent: a failing orders endpoint must not empty the
  /// product list.
  Future<void> refresh() async {
    _loading = true;
    _dataError = null;
    notifyListeners();

    await _loadCatalog();

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadCatalog() async {
    final errors = <String>[];

    Future<void> load(Future<void> Function() task) async {
      try {
        await task();
      } on ApiException catch (e) {
        errors.add(e.message);
      }
    }

    await Future.wait([
      load(() async => _categories = await _api.categories()),
      load(() async => _shops = await _api.shops()),
      load(() async {
        _products = await _api.products();
        // Favorites live in their own table, so the flag has to be re-applied
        // on top of the freshly fetched products.
        await _applyFavorites();
      }),
    ]);

    _dataError = errors.isEmpty ? null : errors.first;
  }

  Future<void> _applyFavorites() async {
    try {
      final favorites = await _api.favorites();
      final ids = favorites.map((p) => p.id).toSet();
      for (final product in _products) {
        product.isFavorite = ids.contains(product.id);
      }
    } on ApiException {
      // A missing favorite list only means the star stays empty.
    }
  }

  // ═══════════════════════════════════
  // STOREFRONT THEMES
  // ═══════════════════════════════════

  /// The themes offered when creating or editing a shop.
  ///
  /// Held in the app, not fetched: the picker and the preview must work before
  /// the shop exists, and on a phone that may not reach the storefront server.
  List<ShopTheme> get themes => storefrontThemes;

  /// Accent colour of a shop, taken from its theme.
  Color themeColorOf(Shop shop) => getStorefrontTheme(shop.theme).primaryColor;

  /// The catalog entry of a shop's theme, for its name and description.
  ShopTheme themeOf(Shop shop) => getStorefrontTheme(shop.theme);

  /// The catalog entry for a bare theme id, used while a theme is still being
  /// chosen and no shop exists yet.
  ShopTheme themeFor(String themeId) => getStorefrontTheme(themeId);

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════
  // AUTH
  // ═══════════════════════════════════

  /// Signs in against the API.
  ///
  /// @returns true on success, false with [authError] set otherwise.
  Future<bool> login(String email, String password) async {
    _authError = null;
    notifyListeners();

    try {
      final session = await _api.login(email, password);
      await _persistSession(session);
      _currentUser = session.user;
      _isLoggedIn = true;
      notifyListeners();
      await _afterLogin();
      return true;
    } on ApiException catch (e) {
      _authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _authError = null;
    notifyListeners();

    if (password != confirmPassword) {
      _authError = 'Les mots de passe ne correspondent pas';
      notifyListeners();
      return false;
    }

    try {
      final session = await _api.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      await _persistSession(session);
      _currentUser = session.user;
      _isLoggedIn = true;
      notifyListeners();
      await _afterLogin();
      return true;
    } on ApiException catch (e) {
      _authError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Requests a password reset email.
  ///
  /// The API deliberately answers the same way for unknown addresses, so a
  /// success here never confirms the account exists.
  Future<bool> forgotPassword(String email) async {
    _authError = null;
    notifyListeners();

    try {
      await _api.requestPasswordReset(email);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _client.clearSession();
    _currentUser = null;
    _isLoggedIn = false;
    _authError = null;
    _products = [];
    _orders = [];
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  /// Hands the token pair to the client so it can refresh silently later.
  Future<void> _persistSession(AuthSession session) {
    return _client.adoptSession(session.accessToken, session.refreshToken);
  }

  /// Loads what the signed-in screens need, once a session exists.
  Future<void> _afterLogin() async {
    await _loadCatalog();
    await loadOrders();
    await loadNotifications();
    notifyListeners();
  }

  // ═══════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    try {
      _currentUser = await _api.updateProfile(
        name: name,
        phone: phone,
        address: address,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════
  // SEARCH & FILTER
  // ═══════════════════════════════════

  List<Product> get filteredProducts {
    List<Product> result = List.from(_products);
    if (_filterNeuf != null) {
      result = result.where((p) => p.isNeuf == _filterNeuf).toList();
    }
    if (_selectedCategory.isNotEmpty) {
      result = result.where((p) => p.categoryId == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String categoryId) {
    _selectedCategory = (_selectedCategory == categoryId) ? '' : categoryId;
    notifyListeners();
  }

  void setFilterNeuf(bool? value) {
    _filterNeuf = value;
    notifyListeners();
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> getProductsByShop(String shopId) {
    return _products.where((p) => p.shopId == shopId).toList();
  }

  Shop? getShopById(String shopId) {
    for (final shop in _shops) {
      if (shop.id == shopId) return shop;
    }
    return null;
  }

  List<Shop> getUserShops() {
    if (_currentUser == null) return [];
    return _shops.where((s) => s.ownerId == _currentUser!.id).toList();
  }

  // ═══════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════

  /// Flips the favorite flag of a product and persists it.
  ///
  /// The local flag flips first so the star reacts instantly; a failure rolls
  /// it back.
  Future<void> toggleFavorite(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = _products[index];
    final wasFavorite = product.isFavorite;
    product.isFavorite = !wasFavorite;
    notifyListeners();

    try {
      if (wasFavorite) {
        await _api.removeFavorite(productId);
      } else {
        await _api.addFavorite(productId);
      }
    } on ApiException catch (e) {
      product.isFavorite = wasFavorite;
      _dataError = e.message;
      notifyListeners();
    }
  }

  List<Product> get favoriteProducts {
    return _products.where((p) => p.isFavorite).toList();
  }

  // ═══════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════

  /// Loads the notifications published by the admin.
///
/// Read-only in the app: the messages are written from the API's Swagger UI,
/// so there is nothing to create here, only to display and mark as read.
Future<void> loadNotifications() async {
    try {
      _notifications = await _api.notifications();
      notifyListeners();
    } on ApiException {
      // A bell that cannot load must not break the screen behind it, nor
      // report an error the user cannot act on.
    }
  }

  /// Marks one notification as read, in the API and in the local list.
  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    final previous = _notifications[index];
    _notifications[index] = previous.copyWith(isRead: true);
    notifyListeners();

    try {
      await _api.markNotificationRead(id);
    } on ApiException {
      // Rolled back so the dot comes back rather than lying about the state.
      _notifications[index] = previous;
      notifyListeners();
    }
  }

  /// Marks every notification as read.
  Future<void> markAllNotificationsRead() async {
    if (unreadNotifications == 0) return;

    final previous = _notifications;
    _notifications = [
      for (final notification in previous) notification.copyWith(isRead: true),
    ];
    notifyListeners();

    try {
      await _api.markAllNotificationsRead();
    } on ApiException {
      _notifications = previous;
      notifyListeners();
    }
  }

  /// Loads the orders the user placed, plus the ones they received as a seller.
  Future<void> loadOrders() async {
    try {
      _orders = await _api.orders();
      _receivedOrders = await _api.receivedOrders();
      notifyListeners();
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
    }
  }

  /// Loads the orders received for one shop, for its detail screen.
  Future<void> loadShopOrders(String shopId) async {
    try {
      _shopOrders[shopId] = await _api.receivedOrders(shopId: shopId);
      notifyListeners();
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
    }
  }

  /// Loads the counters of a shop: product count, order count and rating.
  Future<void> loadShopStats(String shopId) async {
    try {
      _shopStats[shopId] = await _api.shopStats(shopId);
      final mine = await _api.myShopRating(shopId);
      _myShopRatings[shopId] = mine;
      notifyListeners();
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
    }
  }

  /// Rates a shop, or changes the rating already given.
  ///
  /// @returns true on success; false with [dataError] set when the API refuses
  /// (a seller cannot rate their own shop).
  Future<bool> rateShop(String shopId, int rating) async {
    try {
      final summary = await _api.rateShop(shopId, rating);

      _myShopRatings[shopId] = rating;
      _shopStats[shopId] = ShopStats(
        productCount: _shopStats[shopId]?.productCount ?? 0,
        orderCount: _shopStats[shopId]?.orderCount ?? 0,
        rating: summary.average,
        ratingCount: summary.count,
      );

      // The shop card in the lists shows the same average, so it is refreshed
      // in place instead of waiting for the next catalog load.
      final index = _shops.indexWhere((shop) => shop.id == shopId);
      if (index != -1) {
        _shops[index] = _shops[index].copyWith(
          rating: summary.average,
          ratingCount: summary.count,
        );
      }

      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Records the order behind an "order on WhatsApp" tap.
  ///
  /// @returns true when a new order was created, false when this product was
  /// already ordered today or the API refused.
  Future<bool> orderViaWhatsApp(String productId) async {
    try {
      final result = await _api.orderViaWhatsApp(productId);

      // Refresh both lists: the buyer sees it in "Mes Commandes", the seller
      // in the orders of their shop.
      _orders = await _api.orders();
      _receivedOrders = await _api.receivedOrders();

      _dataError = null;
      notifyListeners();
      return !result.alreadyOrdered;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Uploads a gallery and returns the URLs in the order they were picked.
  ///
  /// One file that fails does not lose the others: the upload returns the
  /// URLs it managed to store, so a product still goes live with the photos
  /// that made it through.
  Future<List<String>> uploadImages(
    List<File> files, {
    required String folder,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final url = await uploadImage(file, folder: folder);
      if (url != null && url.isNotEmpty) urls.add(url);
    }

    return urls;
  }

  // ═══════════════════════════════════
  // SHOP MANAGEMENT
  // ═══════════════════════════════════

  /// Creates a shop on the API and adds it to the list.
  ///
  /// @returns false with [dataError] set when the API refuses, most often
  /// because the subdomain is already taken.
  Future<bool> createShop({
    required String name,
    required String description,
    String whatsappLink = '',
    String logoUrl = '',
    String bannerUrl = '',
    required String theme,
    ShopThemeConfig themeConfig = const ShopThemeConfig(),
    String subdomain = '',
  }) async {
    try {
      final shop = await _api.createShop(
        name: name,
        description: description,
        whatsappLink: whatsappLink,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        theme: theme,
        themeConfig: themeConfig.toJson(),
        subdomain: subdomain,
      );

      _shops = [..._shops, shop];

      if (_currentUser != null && !_currentUser!.hasShop) {
        _currentUser = _currentUser!.copyWith(hasShop: true, shopId: shop.id);
      }

      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Applies an edit to an existing shop on the API.
  ///
  /// Lets the seller change the theme, the logo and every storefront text
  /// after the shop has been created.
  Future<bool> updateShop(
    String shopId, {
    String? name,
    String? description,
    String? whatsappLink,
    String? logoUrl,
    String? bannerUrl,
    String? theme,
    ShopThemeConfig? themeConfig,
    String? subdomain,
  }) async {
    try {
      final updated = await _api.updateShop(
        shopId,
        name: name,
        description: description,
        whatsappLink: whatsappLink,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        theme: theme,
        themeConfig: themeConfig?.toJson(),
        subdomain: subdomain,
      );

      final index = _shops.indexWhere((s) => s.id == shopId);
      if (index != -1) {
        _shops[index] = updated;
      }

      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Adds a product to a shop on the API.
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    bool isNeuf = true,
    bool isNegotiable = true,
    List<String> imageUrls = const [],
    String? shopId,
    String? categoryId,
  }) async {
    if (_currentUser == null) return false;

    final targetShopId = shopId ?? _currentUser!.shopId ?? (_userShops().firstOrNull?.id);
    if (targetShopId == null || categoryId == null || categoryId.isEmpty) {
      _dataError = 'Choisissez une catégorie et une boutique.';
      notifyListeners();
      return false;
    }

    try {
      final product = await _api.createProduct(
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        // The gallery the seller picked; the first one is the cover.
        imageUrls: imageUrls,
        categoryId: categoryId,
        shopId: targetShopId,
        isNeuf: isNeuf,
        isNegotiable: isNegotiable,
      );

      _products = [product, ..._products];

      final shop = getShopById(targetShopId);
      if (shop != null) {
        final index = _shops.indexWhere((s) => s.id == targetShopId);
        _shops[index] = shop.copyWith(productCount: shop.productCount + 1);
      }

      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Applies an edit to one of the seller's products.
  ///
  /// The product in the list is replaced in place, so every screen showing it
  /// (shop detail, search, home) reflects the change without a refetch.
  Future<bool> updateProduct(
    String productId, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    bool? isNeuf,
    bool? isNegotiable,
    List<String>? imageUrls,
  }) async {
    try {
      final updated = await _api.updateProduct(
        productId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        imageUrls: imageUrls,
        categoryId: categoryId,
        isNeuf: isNeuf,
        isNegotiable: isNegotiable,
      );

      // The response only carries the edited fields, so the stored favorite
      // flag is re-applied on top of it.
      final wasFavorite =
          _products.firstWhere((p) => p.id == productId).isFavorite;

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updated.copyWith(isFavorite: wasFavorite);
      }

      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Removes a product from the shop and from every list in the app.
  Future<bool> deleteProduct(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    // Kept so the card can be restored if the API refuses the deletion.
    final removed = index != -1 ? _products[index] : null;

    if (removed != null) {
      _products = [..._products]..removeAt(index);
      notifyListeners();
    }

    try {
      await _api.deleteProduct(productId);
      // The shop header shows a product count that the API will now report one
      // lower, so it is lowered here too.
      if (removed != null) {
        final shopIndex = _shops.indexWhere((s) => s.id == removed.shopId);
        if (shopIndex != -1) {
          final shop = _shops[shopIndex];
          _shops[shopIndex] = shop.copyWith(
            productCount: (shop.productCount - 1).clamp(0, 1 << 31),
          );
        }
      }
      _dataError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (removed != null) {
        _products = [..._products]..insert(index, removed);
      }
      _dataError = e.errors?.values.firstOrNull ?? e.message;
      notifyListeners();
      return false;
    }
  }

  /// Sends an image to the API and returns the public URL to store.
  ///
  /// Returns null on failure with [dataError] set, so a caller can report the
  /// problem instead of silently saving a dead URL.
  Future<String?> uploadImage(File file, {required String folder}) async {
    try {
      final url = await _api.uploadImage(file, folder: folder);
      _dataError = null;
      return url;
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
      return null;
    }
  }

  /// Stores a new profile picture.
  ///
  /// The image is uploaded first and the resulting URL is then attached to the
  /// profile: the user row only ever holds a link, so a failed upload leaves
  /// the previous photo in place instead of pointing at nothing.
  Future<bool> updateAvatar(File file) async {
    final url = await uploadImage(file, folder: 'avatars');
    if (url == null || url.isEmpty) return false;

    final saved = await updateProfile(avatarUrl: url);
    if (!saved) return false;

    // The profile endpoint answers with the whole user, so _currentUser already
    // carries the new photo; fall back to a local patch if it did not.
    if ((_currentUser?.avatarUrl ?? '') != url && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatarUrl: url);
      notifyListeners();
    }
    return true;
  }

  List<Shop> _userShops() => getUserShops();

  void clearDataError() {
    _dataError = null;
    notifyListeners();
  }
}