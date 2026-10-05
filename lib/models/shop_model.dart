import 'shop_theme_config.dart';

class Shop {
  final String id;
  String name;
  String description;
  String logoUrl;
  String bannerUrl;
  final String ownerId;

  /// Average of the ratings buyers gave the shop, 0 when nobody rated it yet.
  double rating;

  /// How many buyers gave a rating.
  int ratingCount;
  int productCount;
  DateTime createdAt;
  String whatsappLink;

  /// Id of the storefront theme, matching a key of the Next theme catalog.
  /// See `next/lib/shop/themes.ts`.
  String theme;

  /// The seller's customisations layered on top of the theme defaults.
  ShopThemeConfig themeConfig;

  /// Slug of the public address, e.g. `techzone` for
  /// `techzone.ezshop.store`.
  String subdomain;

  Shop({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl = '',
    this.bannerUrl = '',
    required this.ownerId,
    this.rating = 0,
    this.ratingCount = 0,
    this.productCount = 0,
    required this.createdAt,
    this.whatsappLink = '',
    this.theme = 'atelier',
    this.themeConfig = const ShopThemeConfig(),
    this.subdomain = '',
  });

  Shop copyWith({
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    double? rating,
    int? ratingCount,
    int? productCount,
    String? whatsappLink,
    String? theme,
    ShopThemeConfig? themeConfig,
    String? subdomain,
  }) {
    return Shop(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      ownerId: ownerId,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      theme: theme ?? this.theme,
      themeConfig: themeConfig ?? this.themeConfig,
      subdomain: subdomain ?? this.subdomain,
    );
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: '${json['id']}',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      // 0 means "not rated yet": the stars are drawn empty rather than
      // pretending the shop has a perfect score.
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      // The API always sends an ISO timestamp, but fall back to now so a
      // malformed date cannot break the whole list.
      createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      whatsappLink: json['whatsappLink']?.toString() ?? '',
      theme: json['theme']?.toString() ?? 'atelier',
      themeConfig: ShopThemeConfig.fromJson(json['themeConfig'] as Map<String, dynamic>?),
      // The API allows a null subdomain for shops created before the field
      // existed, so this cannot be assumed non-empty.
      subdomain: json['subdomain']?.toString() ?? '',
    );
  }
}