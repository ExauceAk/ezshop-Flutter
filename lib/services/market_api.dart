import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/user_model.dart';
import 'api_client.dart';

/// Result of a paginated list endpoint.
class Paged<T> {
  const Paged({required this.items, required this.total});

  final List<T> items;
  final int total;

  static Paged<T> parse<T>(
    dynamic payload,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (payload is Map<String, dynamic>) {
      final raw = (payload['items'] as List?) ?? const [];
      return Paged<T>(
        items: raw
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList(),
        total: (payload['total'] as num?)?.toInt() ?? 0,
      );
    }
    // Some endpoints answer with a bare array rather than a page.
    if (payload is List) {
      return Paged<T>(
        items: payload.whereType<Map<String, dynamic>>().map(fromJson).toList(),
        total: payload.length,
      );
    }
    return Paged<T>(items: const [], total: 0);
  }
}

/// A session returned by `/auth/login` or `/auth/register`.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;
}

/// Typed wrapper around every marketplace endpoint the app uses.
///
/// One method per action, so screens never deal with paths or JSON.
class MarketApi {
  MarketApi(this._client);

  final ApiClient _client;

  /// Large enough that the whole catalog fits in one page: the app keeps its
  /// existing client-side filtering, which would otherwise need a round trip
  /// on every keystroke.
  static const _catalogLimit = 200;

  // ─── Auth ───

  Future<AuthSession> login(String email, String password) async {
    final data = await _client.request(
      'POST',
      '/auth/login',
      body: {'identity': email.trim(), 'password': password},
      authenticated: false,
    ) as Map<String, dynamic>;

    return AuthSession(
      accessToken: '${data['accessToken']}',
      refreshToken: '${data['refreshToken']}',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _client.request(
      'POST',
      '/auth/register',
      body: {
        'username': name.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      },
      authenticated: false,
    ) as Map<String, dynamic>;

    return AuthSession(
      accessToken: '${data['accessToken']}',
      refreshToken: '${data['refreshToken']}',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// Asks the API to email a reset link.
  ///
  /// The API answers 201 whether or not the address exists, so this cannot
  /// tell the caller anything beyond "request sent".
  Future<void> requestPasswordReset(String email) async {
    await _client.request(
      'POST',
      '/auth/send-forgot-password-link',
      body: {'email': email.trim()},
      authenticated: false,
    );
  }

  Future<UserModel> me() async {
    final data = await _client.request('GET', '/users/me');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final body = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'username': name.trim(),
      if (email != null && email.isNotEmpty) 'email': email.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (address != null) 'address': address.trim(),
    };

    final data = await _client.request('PATCH', '/users/update-profile', body: body);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── Catalog ───

  Future<List<Product>> products() async {
    final page = Paged.parse<Product>(
      await _client.request(
        'GET',
        '/products',
        query: {'limit': _catalogLimit},
      ),
      Product.fromJson,
    );
    return page.items;
  }

  Future<List<Product>> productsByShop(String shopId) async {
    final page = Paged.parse<Product>(
      await _client.request(
        'GET',
        '/products/by-shop/$shopId',
        query: {'limit': _catalogLimit},
      ),
      Product.fromJson,
    );
    return page.items;
  }

  Future<List<Category>> categories() async {
    final data = await _client.request('GET', '/categories');
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  // ─── Shops ───

  Future<List<Shop>> shops() async {
    final data = await _client.request('GET', '/shops');
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Shop.fromJson).toList();
  }

  Future<List<Shop>> myShops() async {
    final data = await _client.request('GET', '/shops/mine');
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Shop.fromJson).toList();
  }

  Future<Shop> createShop({
    required String name,
    String description = '',
    String whatsappLink = '',
    String logoUrl = '',
    String bannerUrl = '',
    required String theme,
    required Map<String, String> themeConfig,
    required String subdomain,
  }) async {
    final data = await _client.request('POST', '/shops', body: {
      'name': name.trim(),
      'description': description.trim(),
      'whatsappLink': whatsappLink.trim(),
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'theme': theme,
      'themeConfig': themeConfig,
      'subdomain': subdomain.trim(),
    });
    return Shop.fromJson(data as Map<String, dynamic>);
  }

  Future<Shop> updateShop(
    String shopId, {
    String? name,
    String? description,
    String? whatsappLink,
    String? logoUrl,
    String? bannerUrl,
    String? theme,
    Map<String, String>? themeConfig,
    String? subdomain,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (description != null) 'description': description.trim(),
      if (whatsappLink != null) 'whatsappLink': whatsappLink.trim(),
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
      if (theme != null) 'theme': theme,
      if (themeConfig != null) 'themeConfig': themeConfig,
      if (subdomain != null) 'subdomain': subdomain.trim(),
    };

    final data = await _client.request('PATCH', '/shops/$shopId', body: body);
    return Shop.fromJson(data as Map<String, dynamic>);
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String shopId,
    bool isNeuf = true,
    int quantity = 1,
  }) async {
    final data = await _client.request('POST', '/products', body: {
      'name': name.trim(),
      'description': description.trim(),
      // The API validates price as a number, not a decimal string.
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'shopId': shopId,
      'isNeuf': isNeuf,
      'quantity': quantity,
    });
    return Product.fromJson(data as Map<String, dynamic>);
  }

  // ─── Favorites ───

  /// Products the user marked as favorite, most recent first.
  ///
  /// The endpoint returns one row per favorite with the product nested inside.
  Future<List<Product>> favorites() async {
    final data = await _client.request('GET', '/favorites');
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((row) => row['product'])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<void> addFavorite(String productId) async {
    await _client.request('POST', '/favorites/$productId');
  }

  Future<void> removeFavorite(String productId) async {
    await _client.request('DELETE', '/favorites/$productId');
  }

  // ─── Orders ───

  Future<List<Order>> orders() async {
    final page = Paged.parse<Order>(
      await _client.request('GET', '/orders'),
      Order.fromJson,
    );
    return page.items;
  }

  Future<List<Order>> receivedOrders() async {
    final page = Paged.parse<Order>(
      await _client.request('GET', '/orders/received'),
      Order.fromJson,
    );
    return page.items;
  }

  // ─── Cart ───

  /// Cart content as `{ items, totalCount, totalAmount }`.
  Future<Map<String, dynamic>> cart() async {
    final data = await _client.request('GET', '/cart');
    return data is Map<String, dynamic> ? data : const {};
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    await _client.request('POST', '/cart', body: {
      'productId': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    await _client.request(
      'PATCH',
      '/cart/$productId',
      body: {'quantity': quantity},
    );
  }

  Future<void> removeFromCart(String productId) async {
    await _client.request('DELETE', '/cart/$productId');
  }

  Future<void> clearCart() async {
    await _client.request('DELETE', '/cart');
  }
}