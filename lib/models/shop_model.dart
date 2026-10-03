import 'shop_theme_config.dart';

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
  String whatsappLink;

  /// Id of the storefront theme, matching a key of the Next theme catalog.
  /// See `next/lib/shop/themes.ts`.
  String theme;

  /// The seller's customisations layered on top of the theme defaults.
  ShopThemeConfig themeConfig;

  /// Slug of the public address, e.g. `techzone` for `techzone.macketttz.test`.
  String subdomain;

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
      productCount: productCount ?? this.productCount,
      createdAt: createdAt,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      theme: theme ?? this.theme,
      themeConfig: themeConfig ?? this.themeConfig,
      subdomain: subdomain ?? this.subdomain,
    );
  }
}