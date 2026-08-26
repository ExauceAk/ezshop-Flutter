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

  double get discountPercent {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice! * 100).roundToDouble();
    }
    return 0;
  }
}
