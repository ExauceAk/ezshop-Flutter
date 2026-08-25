class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final String categoryId;
  final String shopId;
  final String sellerName;
  final double rating;
  final int reviewCount;
  final int stock;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.shopId,
    required this.sellerName,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.stock = 10,
    this.isFavorite = false,
  });

  Product copyWith({
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    String? imageUrl,
    String? categoryId,
    int? stock,
    bool? isFavorite,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      shopId: shopId,
      sellerName: sellerName,
      rating: rating,
      reviewCount: reviewCount,
      stock: stock ?? this.stock,
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
