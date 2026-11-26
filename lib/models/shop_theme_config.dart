/// Custom customer review configured by the seller to replace default theme
/// testimonials on their storefront.
class ShopTestimonial {
  const ShopTestimonial({
    this.author = '',
    this.role = '',
    this.text = '',
    this.rating = 5,
  });

  final String author;
  final String role;
  final String text;
  final int rating;

  factory ShopTestimonial.fromJson(Map<String, dynamic> json) {
    final rawRating = (json['rating'] as num?)?.toInt() ?? 5;
    return ShopTestimonial(
      author: json['author']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      rating: rawRating.clamp(1, 5),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'author': author.trim(),
      if (role.trim().isNotEmpty) 'role': role.trim(),
      'text': text.trim(),
      'rating': rating.clamp(1, 5),
    };
    return map;
  }

  ShopTestimonial copyWith({
    String? author,
    String? role,
    String? text,
    int? rating,
  }) {
    return ShopTestimonial(
      author: author ?? this.author,
      role: role ?? this.role,
      text: text ?? this.text,
      rating: rating ?? this.rating,
    );
  }
}

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
    this.testimonials = const [],
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

  /// Custom customer testimonials overriding theme defaults when non-empty.
  final List<ShopTestimonial> testimonials;

  /// True when at least one custom colour override is active.
  bool get hasCustomColors =>
      primaryColor.isNotEmpty ||
      accentColor.isNotEmpty ||
      backgroundColor.isNotEmpty;

  factory ShopThemeConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ShopThemeConfig();

    String read(String key) => json[key]?.toString() ?? '';

    final rawTestimonials = json['testimonials'];
    final parsedTestimonials = rawTestimonials is List
        ? rawTestimonials
            .whereType<Map<String, dynamic>>()
            .map(ShopTestimonial.fromJson)
            .where((t) => t.author.trim().isNotEmpty && t.text.trim().isNotEmpty)
            .toList()
        : const <ShopTestimonial>[];

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
      testimonials: parsedTestimonials,
    );
  }

  /// Drops empty fields so the payload stays small and a cleared field really
  /// clears it server-side instead of sending a blank string.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
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
    map.removeWhere((_, value) => value is String && value.isEmpty);
    if (testimonials.isNotEmpty) {
      map['testimonials'] = testimonials.map((t) => t.toJson()).toList();
    }
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
    List<ShopTestimonial>? testimonials,
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
      testimonials: testimonials ?? this.testimonials,
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
