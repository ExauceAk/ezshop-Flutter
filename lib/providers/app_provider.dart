import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';
import '../services/mock_data.dart';

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

  List<Product> get products => _products;
  List<Shop> get shops => _shops;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  AppProvider() {
    _products = List.from(MockData.products);
    _shops = List.from(MockData.shops);
    _categories = MockData.categories;
    _orders = _generateMockOrders();
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

  List<Product> get flashSaleProducts {
    return _products.where((p) => p.oldPrice != null && p.oldPrice! > p.price).toList();
  }

  List<Product> get favoriteProducts {
    return _products.where((p) => p.isFavorite).toList();
  }

  // ═══════════════════════════════════
  // CART
  // ═══════════════════════════════════

  final Map<String, int> _cart = {};

  Map<String, int> get cart => _cart;

  int get cartCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  double get cartTotal {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
    });
    return total;
  }

  List<Product> get cartProducts {
    return _cart.keys.map((id) => _products.firstWhere((p) => p.id == id)).toList();
  }

  void addToCart(String productId) {
    _cart[productId] = (_cart[productId] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = quantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ═══════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════

  void placeOrder() {
    if (_cart.isEmpty || _currentUser == null) return;
    final items = _cart.entries.map((e) {
      final product = _products.firstWhere((p) => p.id == e.key);
      return OrderItem(
        productId: e.key,
        productName: product.name,
        productPrice: product.price,
        quantity: e.value,
        imageUrl: product.imageUrl,
      );
    }).toList();
    final order = Order(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      totalAmount: cartTotal,
      date: DateTime.now(),
    );
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
  }

  // ═══════════════════════════════════
  // SHOP MANAGEMENT
  // ═══════════════════════════════════

  bool createShop(String name, String description) {
    if (_currentUser == null || name.isEmpty) return false;
    final shop = Shop(
      id: 'shop_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: _currentUser!.id,
      createdAt: DateTime.now(),
    );
    _shops.add(shop);
    _currentUser = _currentUser!.copyWith(hasShop: true, shopId: shop.id);
    notifyListeners();
    return true;
  }

  bool addProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    int stock = 10,
  }) {
    if (_currentUser == null || _currentUser!.shopId == null) return false;
    final shop = getShopById(_currentUser!.shopId!);
    if (shop == null) return false;

    final product = Product(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      imageUrl: 'https://picsum.photos/400/400?random=${DateTime.now().millisecondsSinceEpoch}',
      categoryId: categoryId,
      shopId: shop.id,
      sellerName: shop.name,
      stock: stock,
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
          OrderItem(productId: 'prod3', productName: 'Robe d\'été florale', productPrice: 49.99, quantity: 2, imageUrl: 'https://picsum.photos/400/400?random=3'),
          OrderItem(productId: 'prod5', productName: 'Sérum Vitamine C', productPrice: 29.99, quantity: 1, imageUrl: 'https://picsum.photos/400/400?random=5'),
        ],
        totalAmount: 129.97,
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'shipped',
      ),
    ];
  }
}
