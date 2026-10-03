import 'package:flutter/material.dart';

/// How the hero section is laid out.
enum HeroStyle {
  /// Full-bleed image with the text laid over it, left aligned.
  overlay,

  /// Two columns: image on one side, text on the other.
  split,

  /// Text centred on a flat background, no large image.
  stacked,

  /// Short full-width band, text beside the logo.
  strip,
}

/// How the product area is laid out.
enum ProductLayout {
  /// Card grid, [StorefrontTheme.columns] wide.
  grid,

  /// Full-width rows: image on the left, details on the right.
  list,
}

/// Visual treatment of a single product card.
enum CardStyle {
  /// Thin border, no shadow.
  bordered,

  /// No border, soft shadow.
  elevated,

  /// No border and no shadow, image does all the work.
  minimal,

  /// Border plus an inset frame around the image.
  framed,
}

/// A storefront theme offered when a seller creates or edits a shop.
///
/// A theme is a *structure* (hero shape, product layout, card style) plus a
/// palette and a pair of fonts. Only the text and images the seller types
/// change per shop, so two shops on the same theme always look alike apart from
/// their content.
///
/// The catalog lives here, in the app, rather than being fetched from the web:
/// a seller picks a theme while filling the creation form, before any data
/// exists server-side, so the picker must never depend on a network round trip.
/// `next/lib/shop/themes.ts` mirrors these definitions for the public storefront.
class ShopTheme {
  const ShopTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.swatch,
    required this.headingFont,
    required this.bodyFont,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textColor,
    required this.muted,
    required this.border,
    required this.radius,
    required this.heroStyle,
    required this.heroMinHeight,
    required this.heroUsesImage,
    required this.productLayout,
    required this.columns,
    required this.cardStyle,
    required this.imageAspectRatio,
    required this.showBadge,
    required this.showAbout,
    required this.showStats,
  });

  final String id;
  final String name;
  final String description;

  /// Representative image used when the shop has no banner of its own.
  final String previewImage;

  /// Three theme colours, drawn as dots on the picker card.
  final List<String> swatch;

  /// Google Fonts families.
  final String headingFont;
  final String bodyFont;

  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textColor;
  final Color muted;
  final Color border;
  final double radius;

  final HeroStyle heroStyle;
  final double heroMinHeight;

  /// Whether the seller may replace the hero image.
  final bool heroUsesImage;

  final ProductLayout productLayout;

  /// Only used when [productLayout] is [ProductLayout.grid].
  final int columns;

  final CardStyle cardStyle;

  /// Width / height of the card image.
  final double imageAspectRatio;

  /// Show the "new" / "second hand" badge.
  final bool showBadge;

  final bool showAbout;
  final bool showStats;

  /// The primary colour of the theme, used to tint the seller-facing UI so the
  /// app reflects the choice they just made.
  Color get primaryColor => primary;

  /// One of the three palette colours, drawn as a dot on the picker card.
  ///
  /// Out-of-range indexes fall back to a neutral grey rather than throwing, so
  /// a malformed swatch cannot break the picker.
  Color colorAt(int index) {
    if (index < 0 || index >= swatch.length) return const Color(0xFFE9ECEF);
    final value = int.tryParse(swatch[index].replaceFirst('#', ''), radix: 16);
    if (value == null) return const Color(0xFFE9ECEF);
    return Color(0xFF000000 | value);
  }

  /// Whether the theme paints on a dark background, which decides the default
  /// colour of hero text drawn over an image.
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
}

/// The five themes, with genuinely different structures so a seller picks a
/// layout and not just a colour scheme.
const List<ShopTheme> storefrontThemes = [
  ShopTheme(
    id: 'atelier',
    name: 'Atelier',
    description: 'Serif et vert profond, très élégant',
    previewImage:
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=600&q=80',
    swatch: ['#176b55', '#d6a85f', '#f7f5ef'],
    headingFont: 'Playfair Display',
    bodyFont: 'DM Sans',
    primary: Color(0xFF176B55),
    primaryDark: Color(0xFF0D4F3E),
    accent: Color(0xFFD6A85F),
    background: Color(0xFFF7F5EF),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF17211D),
    muted: Color(0xFF747B76),
    border: Color(0xFFE4E5DF),
    radius: 18,
    heroStyle: HeroStyle.overlay,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 4,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 3 / 4,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),
  ShopTheme(
    id: 'vitrine',
    name: 'Vitrine',
    description: 'Hero en deux colonnes, cartes surélevées',
    previewImage:
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=600&q=80',
    swatch: ['#b4502f', '#2f2a26', '#faf6f2'],
    headingFont: 'Cormorant Garamond',
    bodyFont: 'Jost',
    primary: Color(0xFFB4502F),
    primaryDark: Color(0xFF8D3A20),
    accent: Color(0xFFC9A227),
    background: Color(0xFFFAF6F2),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F2A26),
    muted: Color(0xFF7D7269),
    border: Color(0xFFECE2D8),
    radius: 4,
    heroStyle: HeroStyle.split,
    heroMinHeight: 200,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.elevated,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),
  ShopTheme(
    id: 'editorial',
    name: 'Éditorial',
    description: 'Titre centré, grille aérée, noir & blanc',
    previewImage:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=600&q=80',
    swatch: ['#111111', '#8a8a8a', '#ffffff'],
    headingFont: 'Bodoni Moda',
    bodyFont: 'Archivo',
    primary: Color(0xFF111111),
    primaryDark: Color(0xFF000000),
    accent: Color(0xFF111111),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF111111),
    muted: Color(0xFF767676),
    border: Color(0xFFE8E8E8),
    radius: 0,
    heroStyle: HeroStyle.stacked,
    heroMinHeight: 170,
    heroUsesImage: false,
    productLayout: ProductLayout.grid,
    columns: 4,
    cardStyle: CardStyle.minimal,
    imageAspectRatio: 3 / 4,
    showBadge: false,
    showAbout: true,
    showStats: false,
  ),
  ShopTheme(
    id: 'annuaire',
    name: 'Annuaire',
    description: 'Liste horizontale, tons chauds, très lisible',
    previewImage:
        'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=600&q=80',
    swatch: ['#3f5e78', '#e08a3c', '#f4efe6'],
    headingFont: 'Manrope',
    bodyFont: 'Manrope',
    primary: Color(0xFF3F5E78),
    primaryDark: Color(0xFF2C455A),
    accent: Color(0xFFE08A3C),
    background: Color(0xFFF4EFE6),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF26333D),
    muted: Color(0xFF6C7A86),
    border: Color(0xFFDDD5C8),
    radius: 14,
    heroStyle: HeroStyle.strip,
    heroMinHeight: 130,
    heroUsesImage: true,
    productLayout: ProductLayout.list,
    columns: 4,
    cardStyle: CardStyle.framed,
    imageAspectRatio: 4 / 3,
    showBadge: true,
    showAbout: false,
    showStats: true,
  ),
  ShopTheme(
    id: 'nocturne',
    name: 'Nocturne',
    description: 'En-tête sombre et contrasté, ton vif',
    previewImage:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=600&q=80',
    swatch: ['#5b3df5', '#00d4b8', '#0e0e12'],
    headingFont: 'Space Grotesk',
    bodyFont: 'Inter',
    primary: Color(0xFF5B3DF5),
    primaryDark: Color(0xFF3F27B8),
    accent: Color(0xFF00D4B8),
    background: Color(0xFF0E0E12),
    surface: Color(0xFF17171D),
    textColor: Color(0xFFF4F4F6),
    muted: Color(0xFF9A9AA5),
    border: Color(0xFF2A2A33),
    radius: 20,
    heroStyle: HeroStyle.overlay,
    heroMinHeight: 200,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.framed,
    imageAspectRatio: 16 / 10,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),
];

const String defaultThemeId = 'atelier';

/// Resolves a theme id, falling back to the default one.
ShopTheme getStorefrontTheme(String? id) {
  for (final theme in storefrontThemes) {
    if (theme.id == id) return theme;
  }
  return storefrontThemes.first;
}