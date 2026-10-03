import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/shop_theme.dart';
import '../models/shop_theme_config.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';
import '../services/mock_data.dart';
import '../services/theme_service.dart';

class AppProvider extends ChangeNotifier {
  // ─── Auth State ───
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  String? _authError;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get authError => _authError;

  // ─── Data ───
  List<Product> _products = [];
  List<Shop> _shops = [];
  List<Category> _categories = [];
  List<Order> _orders = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool? _filterNeuf; // null = tous, true = neuf, false = occasion

  List<Product> get products => _products;
  List<Shop> get shops => _shops;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool? get filterNeuf => _filterNeuf;

  AppProvider() {
    _products = List.from(MockData.products);
    _shops = List.from(MockData.shops);
    _categories = MockData.categories;
    _orders = _generateMockOrders();
    loadThemes();
  }

  // ═══════════════════════════════════
  // STOREFRONT THEMES
  // ═══════════════════════════════════

  final ThemeService _themeService = ThemeService();
  List<ShopTheme> _themes = [];
  bool _themesLoading = false;

  /// The themes offered when creating or editing a shop.
  List<ShopTheme> get themes => _themes;
  bool get themesLoading => _themesLoading;

  /// Theme used when the catalog cannot be fetched, so shop creation still
  /// works without the storefront being reachable.
  ShopTheme get fallbackTheme => _themes.isNotEmpty
      ? _themes.first
      : const ShopTheme(
          id: 'atelier',
          name: 'Atelier',
          description: 'Serif et vert profond, très élégant',
          previewImage: '',
          swatch: ['#176b55', '#d6a85f', '#f7f5ef'],
        );

  /// Loads the catalog from the Next app. Safe to call more than once.
  Future<void> loadThemes() async {
    if (_themesLoading || _themes.isNotEmpty) return;
    _themesLoading = true;
    notifyListeners();

    _themes = await _themeService.fetchThemes();
    _themesLoading = false;
    notifyListeners();
  }

  /// Accent colour of a shop, taken from its theme.
  ///
  /// Replaces the hardcoded per-template colour map that used to be duplicated
  /// in several screens.
  Color themeColorOf(Shop shop) {
    for (final theme in _themes) {
      if (theme.id == shop.theme) return theme.primaryColor;
    }
    return fallbackTheme.primaryColor;
  }

  /// The catalog entry of a shop's theme, for its name and description.
  ShopTheme? themeOf(Shop shop) {
    for (final theme in _themes) {
      if (theme.id == shop.theme) return theme;
    }
    return null;
  }

  @override
  void dispose() {
    _themeService.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════
  // AUTH METHODS
  // ═══════════════════════════════════

  bool login(String email, String password) {
    _authError = null;
    if (email.isEmpty || password.isEmpty) {
      _authError = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _authError = 'Le mot de passe doit contenir au moins 6 caractères';
      notifyListeners();
      return false;
    }
    _currentUser = MockData.users.first;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  bool signup(String name, String email, String password, String confirmPassword) {
    _authError = null;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _authError = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }
    if (!email.contains('@')) {
      _authError = 'Email invalide';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _authError = 'Le mot de passe doit contenir au moins 6 caractères';
      notifyListeners();
      return false;
    }
    if (password != confirmPassword) {
      _authError = 'Les mots de passe ne correspondent pas';
      notifyListeners();
      return false;
    }
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  bool forgotPassword(String email) {
    _authError = null;
    if (email.isEmpty || !email.contains('@')) {
      _authError = 'Email invalide';
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _authError = null;
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // ═══════════════════════════════════
  // USER PROFILE
  // ═══════════════════════════════════

  void updateProfile({String? name, String? phone, String? address}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, phone: phone, address: address);
    notifyListeners();
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
    try {
      return _shops.firstWhere((s) => s.id == shopId);
    } catch (_) {
      return null;
    }
  }

  List<Shop> getUserShops() {
    if (_currentUser == null) return [];
    return _shops.where((s) => s.ownerId == _currentUser!.id).toList();
  }

  // ═══════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════

  void toggleFavorite(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners();
    }
  }

  List<Product> get favoriteProducts {
    return _products.where((p) => p.isFavorite).toList();
  }

  // ═══════════════════════════════════
  // ORDERS (kept for history, no cart)
  // ═══════════════════════════════════

  // ═══════════════════════════════════
  // SHOP MANAGEMENT
  // ═══════════════════════════════════

  bool createShop({
    required String name,
    required String description,
    String whatsappLink = '',
    String logoUrl = '',
    String bannerUrl = '',
    String theme = 'atelier',
    ShopThemeConfig themeConfig = const ShopThemeConfig(),
    String subdomain = '',
  }) {
    if (_currentUser == null || name.isEmpty) return false;
    final shop = Shop(
      id: 'shop_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      ownerId: _currentUser!.id,
      createdAt: DateTime.now(),
      whatsappLink: whatsappLink,
      theme: theme,
      themeConfig: themeConfig,
      subdomain: subdomain,
    );
    _shops.add(shop);
    // Support multiple shops: set first shop as default
    if (!_currentUser!.hasShop) {
      _currentUser = _currentUser!.copyWith(hasShop: true, shopId: shop.id);
    }
    notifyListeners();
    return true;
  }

  /// Applies an edit to an existing shop.
  ///
  /// Lets the seller change the theme, the logo and every storefront text
  /// after the shop has been created.
  ///
  /// @returns false when the shop does not belong to the signed-in user.
  bool updateShop(
    String shopId, {
    String? name,
    String? description,
    String? whatsappLink,
    String? logoUrl,
    String? bannerUrl,
    String? theme,
    ShopThemeConfig? themeConfig,
    String? subdomain,
  }) {
    if (_currentUser == null) return false;

    final index = _shops.indexWhere((s) => s.id == shopId);
    if (index == -1) return false;

    final shop = _shops[index];
    if (shop.ownerId != _currentUser!.id) return false;

    _shops[index] = shop.copyWith(
      name: name,
      description: description,
      whatsappLink: whatsappLink,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      theme: theme,
      themeConfig: themeConfig,
      subdomain: subdomain,
    );
    notifyListeners();
    return true;
  }

  bool addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    bool isNeuf = true,
    String? shopId,
    String? categoryId,
  }) {
    final targetShopId = shopId ?? _currentUser?.shopId;
    if (_currentUser == null || targetShopId == null) return false;
    final shop = getShopById(targetShopId);
    if (shop == null) return false;

    final product = Product(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId ?? '',
      shopId: shop.id,
      sellerName: shop.name,
      isNeuf: isNeuf,
    );
    _products.insert(0, product);
    shop.productCount++;
    notifyListeners();
    return true;
  }

  // ═══════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════

  List<Order> _generateMockOrders() {
    return [
      Order(
        id: 'ord1',
        items: [
          OrderItem(productId: 'prod1', productName: 'iPhone 15 Pro Max', productPrice: 1199.99, quantity: 1, imageUrl: 'https://picsum.photos/400/400?random=1'),
        ],
        totalAmount: 1199.99,
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'delivered',
      ),
      Order(
        id: 'ord2',
        items: [
          OrderItem(productId: 'prod3', productName: "Robe d'été florale", productPrice: 49.99, quantity: 2, imageUrl: 'https://picsum.photos/400/400?random=3'),
          OrderItem(productId: 'prod5', productName: 'Sérum Vitamine C', productPrice: 29.99, quantity: 1, imageUrl: 'https://picsum.photos/400/400?random=5'),
        ],
        totalAmount: 129.97,
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'shipped',
      ),
    ];
  }
}
