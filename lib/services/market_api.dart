import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/shop_removal_preview.dart';
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

/// Average rating of a shop and how many buyers gave one.
class ShopRating {
  const ShopRating({required this.average, required this.count});

  final double average;
  final int count;

  factory ShopRating.fromJson(Map<String, dynamic> json) {
    return ShopRating(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Counters of one shop, for the seller dashboard.
class ShopStats {
  const ShopStats({
    required this.productCount,
    required this.orderCount,
    required this.rating,
    required this.ratingCount,
  });

  final int productCount;
  final int orderCount;
  final double rating;
  final int ratingCount;

  factory ShopStats.fromJson(Map<String, dynamic> json) {
    return ShopStats(
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Outcome of recording an order from the WhatsApp button.
class WhatsAppOrderResult {
  const WhatsAppOrderResult({required this.alreadyOrdered});

  /// True when this product was already ordered today, so no new order was
  /// created.
  final bool alreadyOrdered;

  factory WhatsAppOrderResult.fromJson(Map<String, dynamic> json) {
    return WhatsAppOrderResult(
      alreadyOrdered: json['alreadyOrdered'] == true,
    );
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

  /// The API rejects a page size above 100, so the catalog is fetched in
  /// several pages rather than one big request.
  static const _pageSize = 100;

  /// Upper bound on pages walked, so a wrong `total` cannot spin forever.
  static const _maxPages = 20;

  /// Images travel over the internet, so they get more room than a JSON call.
  static const _uploadTimeout = Duration(seconds: 60);

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
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'username': name.trim(),
      if (email != null && email.isNotEmpty) 'email': email.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (address != null) 'address': address.trim(),
      // Empty means "keep the stored avatar": clearing it is a separate
      // decision, so an omitted field must not wipe the photo.
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
    };

    final data = await _client.request('PATCH', '/users/update-profile', body: body);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── Catalog ───

  Future<List<Product>> products() {
    return _fetchAllPages<Product>(
      (page) => _client.request(
        'GET',
        '/products',
        query: {'limit': _pageSize, 'page': page},
      ),
      Product.fromJson,
    );
  }

  Future<List<Product>> productsByShop(String shopId) {
    return _fetchAllPages<Product>(
      (page) => _client.request(
        'GET',
        '/products/by-shop/$shopId',
        query: {'limit': _pageSize, 'page': page},
      ),
      Product.fromJson,
    );
  }

  /// Walks every page of a paginated list endpoint and concatenates the rows.
  ///
  /// The app filters client-side, so it needs the whole catalog in memory; a
  /// single large `limit` is not an option because the API caps it at 100.
  Future<List<T>> _fetchAllPages<T>(
    Future<dynamic> Function(int page) request,
    T Function(Map<String, dynamic> row) fromJson,
  ) async {
    final collected = <T>[];

    for (var page = 1; page <= _maxPages; page++) {
      final parsed = Paged.parse<T>(await request(page), fromJson);
      if (parsed.items.isEmpty) break;

      collected.addAll(parsed.items);

      // A short page was the last one.
      if (parsed.items.length < _pageSize) break;
    }

    return collected;
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

  /// Deletes the signed-in account for good.
  ///
  /// The password is sent as proof of ownership: the deletion cannot be undone,
  /// so a stolen token alone must not be able to destroy someone's shop.
  Future<void> deleteAccount(String password) async {
    await _client.request('DELETE', '/users/me', body: {'password': password});
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

  /// What deleting the shop would remove: its products, its orders and its
  /// ratings. Read before the confirmation so the seller sees the real count
  /// instead of a vague warning.
  Future<ShopRemovalPreview> shopRemovalPreview(String shopId) async {
    final data = await _client.request('GET', '/shops/$shopId/removal-preview');
    return ShopRemovalPreview.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteShop(String shopId) async {
    await _client.request('DELETE', '/shops/$shopId');
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String shopId,
    bool isNeuf = true,
    bool isNegotiable = true,
    List<String> imageUrls = const [],
    int quantity = 1,
  }) async {
    final data = await _client.request('POST', '/products', body: {
      'name': name.trim(),
      'description': description.trim(),
      // The API validates price as a number, not a decimal string.
      'price': price,
      'imageUrl': imageUrl,
      // The gallery: `imageUrl` stays the cover, `imageUrls` the rest.
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      'categoryId': categoryId,
      'shopId': shopId,
      'isNeuf': isNeuf,
      'isNegotiable': isNegotiable,
      'quantity': quantity,
    });
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// Updates one of the seller's products.
  ///
  /// Only the fields passed are sent, so an edit that changes nothing about
  /// the photo leaves the stored one alone.
  Future<Product> updateProduct(
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
    final body = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (description != null) 'description': description.trim(),
      if (price != null) 'price': price,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      if (imageUrls != null) 'imageUrls': imageUrls,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (isNeuf != null) 'isNeuf': isNeuf,
      if (isNegotiable != null) 'isNegotiable': isNegotiable,
    };

    final data = await _client.request('PATCH', '/products/$productId', body: body);
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// Deletes one of the seller's products.
  Future<void> deleteProduct(String productId) {
    return _client.request('DELETE', '/products/$productId');
  }

  // ─── Media ───

  /// Uploads an image and returns its permanent public URL.
  ///
  /// The file goes to the API, which stores it in the object storage bucket
  /// and answers with the URL to persist on the shop or the product. A local
  /// path cannot be stored: it only resolves on the device that picked it.
  Future<String> uploadImage(File file, {required String folder}) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/media/upload'),
    );

    if (_client.hasSession) {
      request.headers['Authorization'] = 'Bearer ${_client.accessToken}';
    }
    request.fields['folder'] = folder;
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    try {
      final streamed = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(
          body is Map && body['message'] is String
              ? body['message'] as String
              : "L'image n'a pas pu être envoyée.",
          statusCode: response.statusCode,
        );
      }

      final data = (body as Map)['data'] as Map<String, dynamic>;
      return data['url'] as String;
    } on TimeoutException {
      throw ApiException("L'envoi de l'image a expiré.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("L'image n'a pas pu être envoyée.");
    }
  }

  // ─── Shop ratings ───

  /// Rates a shop, or replaces the rating the caller already gave it.
  ///
  /// @returns the new average and how many ratings the shop has.
  Future<ShopRating> rateShop(String shopId, int rating) async {
    final data = await _client.request(
      'POST',
      '/shops/$shopId/rating',
      body: {'rating': rating},
    );
    return ShopRating.fromJson(data as Map<String, dynamic>);
  }

  /// The rating the caller already gave a shop, 0 when they gave none.
  Future<int> myShopRating(String shopId) async {
    final data = await _client.request('GET', '/shops/$shopId/rating/mine');
    return (data as Map<String, dynamic>)['rating'] as int? ?? 0;
  }

  /// Product count, order count and rating of a shop.
  Future<ShopStats> shopStats(String shopId) async {
    final data = await _client.request('GET', '/shops/$shopId/stats');
    return ShopStats.fromJson(data as Map<String, dynamic>);
  }

  // ─── Notifications ───

  /// Notifications published by the admin, newest first.
  Future<List<AppNotification>> notifications() async {
    final data = await _client.request('GET', '/notifications');
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  /// Marks one notification as read.
  Future<void> markNotificationRead(String id) {
    return _client.request('PATCH', '/notifications/$id/read');
  }

  /// Marks every notification as read.
  Future<void> markAllNotificationsRead() {
    return _client.request('PATCH', '/notifications/read-all');
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

  Future<List<Order>> receivedOrders({String? shopId}) async {
    final page = Paged.parse<Order>(
      await _client.request(
        'GET',
        '/orders/received',
        query: {if (shopId != null && shopId.isNotEmpty) 'shopId': shopId},
      ),
      Order.fromJson,
    );
    return page.items;
  }

  /// Records the order behind an "order on WhatsApp" tap.
  ///
  /// The API answers `alreadyOrdered` when this product was already ordered
  /// today, so the app can say so instead of creating a second identical order.
  Future<WhatsAppOrderResult> orderViaWhatsApp(String productId) async {
    final data = await _client.request(
      'POST',
      '/orders/whatsapp',
      body: {'productId': productId},
    );
    return WhatsAppOrderResult.fromJson(data as Map<String, dynamic>);
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