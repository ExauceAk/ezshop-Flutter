import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/order_model.dart';
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
  String _searchQuery = '';
  String _selectedCategory = '';
  bool? _filterNeuf;

  List<Product> get products => _products;
  List<Shop> get shops => _shops;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
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
    notifyListeners();
  }

  // ═══════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════

  Future<bool> updateProfile({String? name, String? phone, String? address}) async {
    try {
      _currentUser = await _api.updateProfile(
        name: name,
        phone: phone,
        address: address,
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

  /// Loads the orders the user placed, plus the ones they received as a seller.
  Future<void> loadOrders() async {
    try {
      _orders = await _api.orders();
      notifyListeners();
    } on ApiException catch (e) {
      _dataError = e.message;
      notifyListeners();
    }
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
        categoryId: categoryId,
        shopId: targetShopId,
        isNeuf: isNeuf,
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

  List<Shop> _userShops() => getUserShops();

  void clearDataError() {
    _dataError = null;
    notifyListeners();
  }
}