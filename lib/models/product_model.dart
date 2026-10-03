class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final String shopId;
  final String sellerName;
  final double rating;
  final int reviewCount;
  final bool isNeuf;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.categoryId,
    required this.shopId,
    required this.sellerName,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isNeuf = true,
    this.isFavorite = false,
  });

  /// Returns all images: imageUrls if available, else [imageUrl]
  List<String> get allImages {
    if (imageUrls.isNotEmpty) return imageUrls;
    return [imageUrl];
  }

  /// Alias used in UI screens
  List<String> get images => allImages;

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    String? imageUrl,
    List<String>? imageUrls,
    String? categoryId,
    bool? isNeuf,
    bool? isFavorite,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      shopId: shopId,
      sellerName: sellerName,
      rating: rating,
      reviewCount: reviewCount,
      isNeuf: isNeuf ?? this.isNeuf,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Reads a decimal the API sends as a string ("1499.99") or a number.
  static double _readDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // The seller name is denormalised on the product response, so the shop can
    // be displayed without a second fetch.
    final shop = json['shop'];

    return Product(
      id: '${json['id']}',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _readDouble(json['price']),
      oldPrice: json['oldPrice'] == null ? null : _readDouble(json['oldPrice']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      imageUrls: (json['imageUrls'] as List?)?.map((e) => '$e').toList() ?? const [],
      categoryId: json['categoryId']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      sellerName: shop is Map ? shop['name']?.toString() ?? '' : (json['sellerName']?.toString() ?? ''),
      isNeuf: json['isNeuf'] != false,
    );
  }

  double get discountPercent {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice! * 100).roundToDouble();
    }
    return 0;
  }
}
