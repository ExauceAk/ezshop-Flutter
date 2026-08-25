class Shop {
  final String id;
  String name;
  String description;
  String logoUrl;
  String bannerUrl;
  final String ownerId;
  double rating;
  int productCount;
  DateTime createdAt;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl = '',
    this.bannerUrl = '',
    required this.ownerId,
    this.rating = 4.0,
    this.productCount = 0,
    required this.createdAt,
  });

  Shop copyWith({
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    double? rating,
    int? productCount,
  }) {
    return Shop(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      ownerId: ownerId,
      rating: rating ?? this.rating,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt,
    );
  }
}
