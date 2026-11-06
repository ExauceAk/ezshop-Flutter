/// The storefront content and custom colour palette a seller customises on top
/// of their chosen theme.
///
/// Mirrors `ShopThemeConfig` in `next/lib/shop/themes.ts` and the
/// `ShopThemeConfigDto` accepted by the Nest API. Every field is optional: an
/// empty one falls back to the theme's default copy or palette.
class ShopThemeConfig {
  const ShopThemeConfig({
    this.primaryColor = '',
    this.accentColor = '',
    this.backgroundColor = '',
    this.heroEyebrow = '',
    this.heroTitle = '',
    this.heroSubtitle = '',
    this.heroImageUrl = '',
    this.aboutTitle = '',
    this.aboutText = '',
    this.footerText = '',
    this.heroCtaLabel = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.contactAddress = '',
  });

  /// Seller-chosen primary brand colour (`#RRGGBB`). Empty means "use theme default".
  final String primaryColor;

  /// Seller-chosen secondary accent colour (`#RRGGBB`). Empty means "use theme default".
  final String accentColor;

  /// Seller-chosen storefront background colour (`#RRGGBB`). Empty means "use theme default".
  final String backgroundColor;

  /// Small label above the hero title, e.g. "Boutique indépendante".
  final String heroEyebrow;

  /// Hero headline. Empty means "use the shop name".
  final String heroTitle;

  /// Paragraph under the hero headline.
  final String heroSubtitle;

  /// Hero background image. Empty means "use the shop banner".
  final String heroImageUrl;

  /// Title of the "about" section.
  final String aboutTitle;

  /// Body of the "about" section. Empty means "use the shop description".
  final String aboutText;

  /// One-line pitch shown in the footer.
  final String footerText;

  /// Label of the hero call-to-action button.
  final String heroCtaLabel;

  final String contactEmail;
  final String contactPhone;
  final String contactAddress;

  /// True when at least one custom colour override is active.
  bool get hasCustomColors =>
      primaryColor.isNotEmpty ||
      accentColor.isNotEmpty ||
      backgroundColor.isNotEmpty;

  factory ShopThemeConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ShopThemeConfig();

    String read(String key) => json[key]?.toString() ?? '';

    return ShopThemeConfig(
      primaryColor: read('primaryColor'),
      accentColor: read('accentColor'),
      backgroundColor: read('backgroundColor'),
      heroEyebrow: read('heroEyebrow'),
      heroTitle: read('heroTitle'),
      heroSubtitle: read('heroSubtitle'),
      heroImageUrl: read('heroImageUrl'),
      aboutTitle: read('aboutTitle'),
      aboutText: read('aboutText'),
      footerText: read('footerText'),
      heroCtaLabel: read('heroCtaLabel'),
      contactEmail: read('contactEmail'),
      contactPhone: read('contactPhone'),
      contactAddress: read('contactAddress'),
    );
  }

  /// Drops empty fields so the payload stays small and a cleared field really
  /// clears it server-side instead of sending a blank string.
  Map<String, String> toJson() {
    final map = <String, String>{
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'heroEyebrow': heroEyebrow,
      'heroTitle': heroTitle,
      'heroSubtitle': heroSubtitle,
      'heroImageUrl': heroImageUrl,
      'aboutTitle': aboutTitle,
      'aboutText': aboutText,
      'footerText': footerText,
      'heroCtaLabel': heroCtaLabel,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'contactAddress': contactAddress,
    };
    map.removeWhere((_, value) => value.isEmpty);
    return map;
  }

  ShopThemeConfig copyWith({
    String? primaryColor,
    String? accentColor,
    String? backgroundColor,
    String? heroEyebrow,
    String? heroTitle,
    String? heroSubtitle,
    String? heroImageUrl,
    String? aboutTitle,
    String? aboutText,
    String? footerText,
    String? heroCtaLabel,
    String? contactEmail,
    String? contactPhone,
    String? contactAddress,
  }) {
    return ShopThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      heroEyebrow: heroEyebrow ?? this.heroEyebrow,
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutText: aboutText ?? this.aboutText,
      footerText: footerText ?? this.footerText,
      heroCtaLabel: heroCtaLabel ?? this.heroCtaLabel,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactAddress: contactAddress ?? this.contactAddress,
    );
  }

  /// Returns a copy with all custom colour overrides reset to the theme's defaults.
  ShopThemeConfig clearColors() {
    return copyWith(
      primaryColor: '',
      accentColor: '',
      backgroundColor: '',
    );
  }
}
