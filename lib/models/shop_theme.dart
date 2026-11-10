import 'package:flutter/material.dart';

import 'shop_theme_config.dart';

/// How the hero section is laid out.
enum HeroStyle {
  /// Full-bleed image with the text laid over it, left aligned.
  overlay,

  /// Two columns: image on one side, text on the other.
  split,

  /// Text centred on a flat background or poster layout.
  stacked,

  /// Short full-width band, text beside the logo.
  strip,
}

/// How the product area is laid out.
enum ProductLayout {
  /// Card grid, [ShopTheme.columns] wide.
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

/// Preset 3-colour palette a seller can apply in one tap onto any theme.
class StorefrontPalettePreset {
  const StorefrontPalettePreset({
    required this.name,
    required this.primaryHex,
    required this.accentHex,
    required this.backgroundHex,
  });

  final String name;
  final String primaryHex;
  final String accentHex;
  final String backgroundHex;

  Color get primary => parseHexColor(primaryHex) ?? const Color(0xFF176B55);
  Color get accent => parseHexColor(accentHex) ?? const Color(0xFFD6A85F);
  Color get background =>
      parseHexColor(backgroundHex) ?? const Color(0xFFF7F5EF);
}

const List<StorefrontPalettePreset> kPalettePresets = [
  StorefrontPalettePreset(
    name: 'Émeraude & Or',
    primaryHex: '#176B55',
    accentHex: '#D6A85F',
    backgroundHex: '#F7F5EF',
  ),
  StorefrontPalettePreset(
    name: 'Terracotta & Crème',
    primaryHex: '#9A3412',
    accentHex: '#D97706',
    backgroundHex: '#FDF8F3',
  ),
  StorefrontPalettePreset(
    name: 'Obsidienne & Or',
    primaryHex: '#D4AF37',
    accentHex: '#F59E0B',
    backgroundHex: '#090A0F',
  ),
  StorefrontPalettePreset(
    name: 'Bleu Cobalt & Craie',
    primaryHex: '#2563EB',
    accentHex: '#10B981',
    backgroundHex: '#F1F5F9',
  ),
  StorefrontPalettePreset(
    name: 'Cyber Néon',
    primaryHex: '#06B6D4',
    accentHex: '#EC4899',
    backgroundHex: '#080911',
  ),
  StorefrontPalettePreset(
    name: 'Sable & Océan',
    primaryHex: '#0891B2',
    accentHex: '#2DD4BF',
    backgroundHex: '#F0FDFA',
  ),
  StorefrontPalettePreset(
    name: 'Bordeaux & Ivoire',
    primaryHex: '#BE123C',
    accentHex: '#F59E0B',
    backgroundHex: '#FAF8F5',
  ),
  StorefrontPalettePreset(
    name: 'Street Drop',
    primaryHex: '#E11D48',
    accentHex: '#FACC15',
    backgroundHex: '#09090B',
  ),
];

/// Parses a `#RRGGBB` or `#RGB` hex string into a [Color], or returns null.
Color? parseHexColor(String? raw) {
  if (raw == null) return null;
  var clean = raw.trim().replaceFirst('#', '');
  if (clean.length == 3) {
    clean = clean.split('').map((c) => '$c$c').join();
  }
  if (clean.length != 6) return null;
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

/// Formats a [Color] as `#RRGGBB`.
String colorToHex(Color color) {
  final r = (color.r * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
}

/// Mixes [color] toward black (`amount < 0`) or white (`amount > 0`), mirroring
/// `shiftHexBrightness` in `next/lib/shop/use-storefront.ts`.
Color shiftColorBrightness(Color color, double amount) {
  final target = amount < 0 ? 0.0 : 1.0;
  final factor = amount.abs().clamp(0.0, 1.0);
  return Color.fromARGB(
    255,
    ((color.r + (target - color.r) * factor) * 255).round().clamp(0, 255),
    ((color.g + (target - color.g) * factor) * 255).round().clamp(0, 255),
    ((color.b + (target - color.b) * factor) * 255).round().clamp(0, 255),
  );
}

/// Estimates whether [color] is dark using the same WCAG relative luminance
/// threshold (`< 0.35`) as `isHexDark` in `next/lib/shop/use-storefront.ts`.
bool isDarkBackgroundColor(Color color) {
  final luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
  return luminance < 0.35;
}

/// Labels for the optional e-commerce sections rendered by each theme.
const Map<String, String> optionalSectionLabels = {
  'marquee': 'Bandeau défilant',
  'trust-badges': 'Garanties e-commerce',
  'category-showcase': 'Univers & Catégories',
  'featured-spotlight': 'Produit Vedette',
  'lookbook': 'Lookbook Interactif',
  'craftsmanship': 'Parcours en 3 étapes',
  'testimonials': 'Avis Clients',
  'faq': 'FAQ Interactive',
  'whatsapp-club': 'Conciergerie WhatsApp VIP',
};

/// A storefront theme offered when a seller creates or edits a shop.
///
/// Mirrors the 20 standalone themes in `next/lib/shop/themes.ts` and their
/// realistic demo identities in `next/app/preview/[theme]/page.tsx`.
class ShopTheme {
  const ShopTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.signature,
    required this.sections,
    required this.demoShopName,
    required this.demoEyebrow,
    required this.demoTitle,
    required this.demoSubtitle,
    required this.demoAboutTitle,
    required this.demoAboutText,
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
  final String category;
  final String signature;
  final List<String> sections;

  /// Realistic French demo copy shown in previews when the seller has not
  /// entered their own boutique name/description yet.
  final String demoShopName;
  final String demoEyebrow;
  final String demoTitle;
  final String demoSubtitle;
  final String demoAboutTitle;
  final String demoAboutText;

  /// Representative image used when the shop has no banner of its own.
  final String previewImage;

  /// Three default theme colours, drawn as dots on the picker card.
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
  Color colorAt(int index) {
    if (index < 0 || index >= swatch.length) return const Color(0xFFE9ECEF);
    return parseHexColor(swatch[index]) ?? const Color(0xFFE9ECEF);
  }

  /// Whether the theme paints on a dark background.
  bool get isDark => isDarkBackgroundColor(background);

  /// Applies seller-chosen custom colours (`primaryColor`, `accentColor`,
  /// `backgroundColor`) on top of this theme's default palette, automatically
  /// computing `primaryDark`, `surface`, `textColor`, `muted` and `border`
  /// with the exact same contrast rules as `buildThemeVars` in Next.js.
  ShopTheme applyCustomColors(ShopThemeConfig? config) {
    if (config == null || !config.hasCustomColors) return this;

    final customPrimary = parseHexColor(config.primaryColor);
    final customAccent = parseHexColor(config.accentColor);
    final customBg = parseHexColor(config.backgroundColor);

    final nextPrimary = customPrimary ?? primary;
    final nextPrimaryDark = customPrimary != null
        ? shiftColorBrightness(customPrimary, -0.24)
        : primaryDark;
    final nextAccent = customAccent ?? accent;

    var nextBg = background;
    var nextSurface = surface;
    var nextText = textColor;
    var nextMuted = muted;
    var nextBorder = border;

    if (customBg != null) {
      nextBg = customBg;
      if (isDarkBackgroundColor(customBg)) {
        nextSurface = shiftColorBrightness(customBg, 0.07);
        nextText = const Color(0xFFF5F5F7);
        nextMuted = const Color(0xFF9CA3AF);
        nextBorder = shiftColorBrightness(customBg, 0.16);
      } else {
        nextSurface = const Color(0xFFFFFFFF);
        nextText = const Color(0xFF161A18);
        nextMuted = const Color(0xFF68706C);
        nextBorder = shiftColorBrightness(customBg, -0.09);
      }
    }

    return ShopTheme(
      id: id,
      name: name,
      description: description,
      category: category,
      signature: signature,
      sections: sections,
      demoShopName: demoShopName,
      demoEyebrow: demoEyebrow,
      demoTitle: demoTitle,
      demoSubtitle: demoSubtitle,
      demoAboutTitle: demoAboutTitle,
      demoAboutText: demoAboutText,
      previewImage: previewImage,
      swatch: [
        colorToHex(nextPrimary),
        colorToHex(nextAccent),
        colorToHex(nextBg),
      ],
      headingFont: headingFont,
      bodyFont: bodyFont,
      primary: nextPrimary,
      primaryDark: nextPrimaryDark,
      accent: nextAccent,
      background: nextBg,
      surface: nextSurface,
      textColor: nextText,
      muted: nextMuted,
      border: nextBorder,
      radius: radius,
      heroStyle: heroStyle,
      heroMinHeight: heroMinHeight,
      heroUsesImage: heroUsesImage,
      productLayout: productLayout,
      columns: columns,
      cardStyle: cardStyle,
      imageAspectRatio: imageAspectRatio,
      showBadge: showBadge,
      showAbout: showAbout,
      showStats: showStats,
    );
  }
}

/// The 20 standalone themes, matching `next/lib/shop/themes.ts`.
const List<ShopTheme> storefrontThemes = [
  // 1. ATELIER
  ShopTheme(
    id: 'atelier',
    name: 'Atelier',
    description:
        'Maison d’artisanat contemporain : bannière plein cadre, ruban de statistiques flottant et grille bordée intemporelle',
    category: 'Artisanat & Maison',
    signature:
        'Bannière immersive + Ruban stats + Grille bordée + Piliers Savoir-Faire',
    sections: ['trust-badges', 'testimonials'],
    demoShopName: 'Maison Kanso',
    demoEyebrow: 'Artisanat & Matières Nobles',
    demoTitle: 'Des pièces façonnées pour traverser le temps',
    demoSubtitle:
        'Céramiques tournées à la main, bois massif et objets du quotidien dessinés dans notre atelier avec une exigence absolue.',
    demoAboutTitle: 'Le geste juste et la matière brute',
    demoAboutText:
        'Chaque création Maison Kanso est produite en petite série. Nous privilégions les matériaux durables, les patines naturelles et le dialogue direct avec nos clients.',
    previewImage:
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=900&q=80',
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
    heroMinHeight: 220,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 2. VITRINE
  ShopTheme(
    id: 'vitrine',
    name: 'Vitrine',
    description:
        'Concept-store urbain lumineux : recherche en direct dans l’en-tête, écran scindé 50/50 et cartes à prix flottant',
    category: 'Concept-Store',
    signature:
        'Recherche live + Hero 50/50 avec produit flottant + Cartes portrait 4:5',
    sections: ['category-showcase', 'featured-spotlight'],
    demoShopName: 'Studio Néo',
    demoEyebrow: 'Concept-Store Urbain',
    demoTitle: 'Les essentiels du design contemporain',
    demoSubtitle:
        'Une sélection pointue d’objets nomades, de luminaires sculpturaux et d’accessoires pensés pour sublimer votre quotidien.',
    demoAboutTitle: 'Un regard neuf sur les objets de tous les jours',
    demoAboutText:
        'Studio Néo réunit des pièces choisies pour leur justesse fonctionnelle et leur ligne graphique. Toutes nos références affichées sont en stock réel.',
    previewImage:
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=900&q=80',
    swatch: ['#0f172a', '#3b82f6', '#f8fafc'],
    headingFont: 'Plus Jakarta Sans',
    bodyFont: 'Inter',
    primary: Color(0xFF0F172A),
    primaryDark: Color(0xFF020617),
    accent: Color(0xFF3B82F6),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F172A),
    muted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    radius: 20,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.elevated,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 3. EDITORIAL
  ShopTheme(
    id: 'editorial',
    name: 'Éditorial',
    description:
        'Magazine de mode & haute couture : double fronton espacé, affiche 21:9 et double-page asymétrique',
    category: 'Mode & Édition',
    signature:
        'Double Masthead + Cinémascope 21:9 + Double-page magazine asymétrique',
    sections: ['marquee', 'lookbook'],
    demoShopName: 'Maison Valois',
    demoEyebrow: 'Édition Permanente',
    demoTitle: 'L’élégance silencieuse des coupes intemporelles',
    demoSubtitle:
        'Une garde-robe architecturale et des objets d’intérieur composés avec des fibres naturelles d’exception.',
    demoAboutTitle: 'Une certaine idée de l’allure',
    demoAboutText:
        'Affranchie des saisons éphémères, Maison Valois édite des pièces numérotées conçues pour durer et se transmettre.',
    previewImage:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=900&q=80',
    swatch: ['#18181b', '#a16207', '#faf8f5'],
    headingFont: 'Cormorant Garamond',
    bodyFont: 'Plus Jakarta Sans',
    primary: Color(0xFF18181B),
    primaryDark: Color(0xFF09090B),
    accent: Color(0xFFA16207),
    background: Color(0xFFFAF8F5),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF18181B),
    muted: Color(0xFF71717A),
    border: Color(0xFFE4E2DD),
    radius: 4,
    heroStyle: HeroStyle.stacked,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.minimal,
    imageAspectRatio: 3 / 4,
    showBadge: true,
    showAbout: true,
    showStats: false,
  ),

  // 4. ANNUAIRE
  ShopTheme(
    id: 'annuaire',
    name: 'Annuaire',
    description:
        'Comptoir grossiste & catalogue haute densité : barre de filtrage instantané et registre de commande horizontal',
    category: 'Grossiste & B2B',
    signature:
        'Bandeau Showroom + Recherche intégrée + Registre horizontal REF/Stock',
    sections: ['trust-badges', 'faq'],
    demoShopName: 'Comptoir Central',
    demoEyebrow: 'Catalogue Officiel & Stock Direct',
    demoTitle: 'Toutes nos références disponibles immédiatement',
    demoSubtitle:
        'Consultez les disponibilités en temps réel, filtrez par rayon et composez votre bon de commande en quelques secondes.',
    demoAboutTitle: 'La réactivité d’un comptoir professionnel',
    demoAboutText:
        'Notre inventaire est mis à jour quotidiennement. Que vous commandiez à l’unité ou en plusieurs exemplaires, notre équipe confirme votre préparation immédiatement.',
    previewImage:
        'https://images.unsplash.com/photo-1556740758-90de374c12ad?auto=format&fit=crop&w=900&q=80',
    swatch: ['#0284c7', '#f59e0b', '#f1f5f9'],
    headingFont: 'Space Grotesk',
    bodyFont: 'Inter',
    primary: Color(0xFF0284C7),
    primaryDark: Color(0xFF0369A1),
    accent: Color(0xFFF59E0B),
    background: Color(0xFFF1F5F9),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F172A),
    muted: Color(0xFF64748B),
    border: Color(0xFFCBD5E1),
    radius: 12,
    heroStyle: HeroStyle.strip,
    heroMinHeight: 150,
    heroUsesImage: false,
    productLayout: ProductLayout.list,
    columns: 2,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 5. NOCTURNE
  ShopTheme(
    id: 'nocturne',
    name: 'Nocturne',
    description:
        'Galerie privée & luxe sombre : pilule glassmorphique dorée, podium produit éclairé et cadres passe-partout numérotés',
    category: 'Luxe & Galerie',
    signature:
        'Pilule Glassmorphism + Podium Spotlight + Cadres Musée Passe-Partout',
    sections: ['featured-spotlight', 'whatsapp-club'],
    demoShopName: 'Galerie Obsidienne',
    demoEyebrow: 'Salon Privé & Éditions Rares',
    demoTitle: 'L’éclat discret des pièces d’exception',
    demoSubtitle:
        'Objets d’art, luminaires de collection et créations singulières réunis dans un écrin intimiste.',
    demoAboutTitle: 'Une sélection pensée comme une collection privée',
    demoAboutText:
        'La Galerie Obsidienne accompagne les amateurs de belles pièces avec un service de conciergerie personnalisé et une traçabilité complète.',
    previewImage:
        'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=900&q=80',
    swatch: ['#d4af37', '#f59e0b', '#090a0f'],
    headingFont: 'Cormorant Garamond',
    bodyFont: 'DM Sans',
    primary: Color(0xFFD4AF37),
    primaryDark: Color(0xFFB59024),
    accent: Color(0xFFF59E0B),
    background: Color(0xFF090A0F),
    surface: Color(0xFF12151F),
    textColor: Color(0xFFF8FAFC),
    muted: Color(0xFF94A3B8),
    border: Color(0xFF232838),
    radius: 14,
    heroStyle: HeroStyle.split,
    heroMinHeight: 220,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.framed,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 6. BAOBAB
  ShopTheme(
    id: 'baobab',
    name: 'Baobab',
    description:
        'Terroir, cosmétique naturelle & artisanat organique : sceau central, triptyque en arche botanique et cartes en voûte douce',
    category: 'Nature & Terroir',
    signature: 'Médaillon central + Hero en Arche Organique + Cartes voûtées',
    sections: ['craftsmanship', 'testimonials'],
    demoShopName: 'Terres d’Origine',
    demoEyebrow: 'Récolte Authentique & Savoir-Faire',
    demoTitle: 'La richesse pure des matières naturelles',
    demoSubtitle:
        'Soins botaniques, créations artisanales et trésors du terroir préparés dans le respect des traditions.',
    demoAboutTitle: 'Un lien direct entre la terre et votre intérieur',
    demoAboutText:
        'Nous travaillons main dans la main avec des coopératives et artisans passionnés pour garantir une qualité irréprochable et authentique.',
    previewImage:
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=900&q=80',
    swatch: ['#9a3412', '#d97706', '#fdf8f3'],
    headingFont: 'Fraunces',
    bodyFont: 'DM Sans',
    primary: Color(0xFF9A3412),
    primaryDark: Color(0xFF7C2D12),
    accent: Color(0xFFD97706),
    background: Color(0xFFFDF8F3),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF291811),
    muted: Color(0xFF7C6558),
    border: Color(0xFFEADCCF),
    radius: 24,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 7. SAHEL
  ShopTheme(
    id: 'sahel',
    name: 'Sahel',
    description:
        'Galerie solaire minimaliste : badges d’angles flottants, plaque éditoriale suspendue et exposition en quinconce décalée',
    category: 'Minimalisme & Art',
    signature:
        'Navigation aux 4 coins + Plaque suspendue + Galerie en quinconce décalée',
    sections: ['lookbook', 'whatsapp-club'],
    demoShopName: 'Fondation Dune',
    demoEyebrow: 'Architecture & Formes Minérales',
    demoTitle: 'La poésie des lignes pures et de la lumière',
    demoSubtitle:
        'Une exposition d’objets sculpturaux aux teintes chaudes de sable, d’argile et de pierre naturelle.',
    demoAboutTitle: 'L’espace, la matière et le calme',
    demoAboutText:
        'Chaque pièce présentée par Fondation Dune est choisie pour sa présence apaisante et l’authenticité de sa texture.',
    previewImage:
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=900&q=80',
    swatch: ['#b45309', '#0284c7', '#fbf7f0'],
    headingFont: 'Playfair Display',
    bodyFont: 'Plus Jakarta Sans',
    primary: Color(0xFFB45309),
    primaryDark: Color(0xFF92400E),
    accent: Color(0xFF0284C7),
    background: Color(0xFFFBf7F0),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF271C15),
    muted: Color(0xFF847263),
    border: Color(0xFFE8DFD1),
    radius: 8,
    heroStyle: HeroStyle.overlay,
    heroMinHeight: 220,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 2,
    cardStyle: CardStyle.minimal,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: false,
  ),

  // 8. ZELLIGE
  ShopTheme(
    id: 'zellige',
    name: 'Zellige',
    description:
        'Palais géométrique & savoir-faire ancestral : frise octogonale, portail en losange et cartes à double encadrement',
    category: 'Artisanat & Maison',
    signature:
        'Frise géométrique + Portail octogonal + Cartes à coins ciselés',
    sections: ['craftsmanship', 'trust-badges'],
    demoShopName: 'Dar Al-Andalus',
    demoEyebrow: 'Haute Tradition & Géométrie',
    demoTitle: 'L’art millénaire du motif et de la ciselure',
    demoSubtitle:
        'Céramiques émaillées, laiton martelé et créations décoratives réalisés selon les règles de l’art ancestral.',
    demoAboutTitle: 'L’héritage vivant des maîtres artisans',
    demoAboutText:
        'De la terre façonnée à la main jusqu’à l’émaillage final, nos pièces célèbrent la précision géométrique et la générosité des couleurs.',
    previewImage:
        'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?auto=format&fit=crop&w=900&q=80',
    swatch: ['#0f766e', '#ca8a04', '#f4f7f6'],
    headingFont: 'Cormorant Garamond',
    bodyFont: 'DM Sans',
    primary: Color(0xFF0F766E),
    primaryDark: Color(0xFF115E59),
    accent: Color(0xFFCA8A04),
    background: Color(0xFFF4F7F6),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF132A28),
    muted: Color(0xFF5C7471),
    border: Color(0xFFCFE0DD),
    radius: 6,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.framed,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 9. KRAFT
  ShopTheme(
    id: 'kraft',
    name: 'Kraft',
    description:
        'Atelier papeterie, torréfaction & packaging brut : bordures cousues en pointillés, fiche d’atelier tamponnée et étiquettes perforées',
    category: 'Artisanat & Maison',
    signature:
        'Coutures pointillées + Fiche technique tamponnée + Étiquettes colis perforées',
    sections: ['craftsmanship', 'faq'],
    demoShopName: 'Manufacture N° 09',
    demoEyebrow: 'Production d’Atelier & Petites Séries',
    demoTitle: 'Fabriqué avec soin, contrôlé et numéroté',
    demoSubtitle:
        'Objets utilitaires, papeterie cousue et créations brutes expédiés directement depuis notre établi.',
    demoAboutTitle: 'Rien de superflu, uniquement l’essentiel',
    demoAboutText:
        'À la Manufacture N° 09, chaque article passe entre nos mains avant d’être emballé dans un papier kraft robuste et prêt à vous accompagner longtemps.',
    previewImage:
        'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=900&q=80',
    swatch: ['#57412f', '#b45309', '#f3ede2'],
    headingFont: 'Space Grotesk',
    bodyFont: 'DM Sans',
    primary: Color(0xFF57412F),
    primaryDark: Color(0xFF3E2D20),
    accent: Color(0xFFB45309),
    background: Color(0xFFF3EDE2),
    surface: Color(0xFFFAF6EF),
    textColor: Color(0xFF261C14),
    muted: Color(0xFF786655),
    border: Color(0xFFD8CBB8),
    radius: 8,
    heroStyle: HeroStyle.split,
    heroMinHeight: 200,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 10. NEON
  ShopTheme(
    id: 'neon',
    name: 'Néon',
    description:
        'Cyber-lab, gaming & hardware : terminal de commande HUD, télémétrie en direct et cartes sci-fi à coins biseautés',
    category: 'Tech & Urbain',
    signature:
        'Terminal HUD [SYS.ONLINE] + Télémétrie live + Cartes biseautées Cyber',
    sections: ['marquee'],
    demoShopName: 'CyberPulse Lab',
    demoEyebrow: 'Hardware & Équipement Haute Précision',
    demoTitle: 'Performance pure et ingénierie de pointe',
    demoSubtitle:
        'Audio haute-fidélité, périphériques de création et accessoires techniques testés et prêts à l’emploi.',
    demoAboutTitle: 'Conçu pour les créateurs et passionnés exigeants',
    demoAboutText:
        'Chaque référence du laboratoire CyberPulse est sélectionnée pour sa fiabilité technique, son design avant-gardiste et sa disponibilité immédiate.',
    previewImage:
        'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=900&q=80',
    swatch: ['#06b6d4', '#ec4899', '#080911'],
    headingFont: 'Syne',
    bodyFont: 'Space Grotesk',
    primary: Color(0xFF06B6D4),
    primaryDark: Color(0xFF0891B2),
    accent: Color(0xFFEC4899),
    background: Color(0xFF080911),
    surface: Color(0xFF111322),
    textColor: Color(0xFFF1F5F9),
    muted: Color(0xFF94A3B8),
    border: Color(0xFF1E293B),
    radius: 6,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 11. VINTAGE
  ShopTheme(
    id: 'vintage',
    name: 'Vintage',
    description:
        'Brocante chic, vinyles & pièces rares : album photo rétro, tirages Polaroid légèrement inclinés et carte postale du collectionneur',
    category: 'Mode & Édition',
    signature:
        'Hero Scrapbook incliné + Pinboard de tirages Polaroid + Carte postale',
    sections: ['testimonials', 'whatsapp-club'],
    demoShopName: 'L’Archive Rétro',
    demoEyebrow: 'Brocante Choisie & Pièces d’Époque',
    demoTitle: 'Des objets qui ont une âme et une histoire',
    demoSubtitle:
        'Mobilier iconique, éditions originales et trouvailles chinées avec passion, restaurés et prêts pour une seconde vie.',
    demoAboutTitle: 'Le plaisir de chiner des pièces uniques',
    demoAboutText:
        'Toutes nos pièces vintage sont authentifiées, nettoyées et photographiées sous toutes leurs coutures. Lorsqu’un article vous plaît, ne tardez pas : il est souvent unique.',
    previewImage:
        'https://images.unsplash.com/photo-1461784121038-f088ca1e7714?auto=format&fit=crop&w=900&q=80',
    swatch: ['#7c2d12', '#ca8a04', '#f5efe6'],
    headingFont: 'Fraunces',
    bodyFont: 'DM Sans',
    primary: Color(0xFF7C2D12),
    primaryDark: Color(0xFF5C200D),
    accent: Color(0xFFCA8A04),
    background: Color(0xFFF5EFE6),
    surface: Color(0xFFFFFDF9),
    textColor: Color(0xFF291D16),
    muted: Color(0xFF78695E),
    border: Color(0xFFDFD5C6),
    radius: 6,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.framed,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 12. TRIBAL
  ShopTheme(
    id: 'tribal',
    name: 'Tribal',
    description:
        'Créations afro-fusion, wax & art graphique : barre d’onglets encadrés 2px, frise géométrique et matrice contiguë brutaliste',
    category: 'Mode & Édition',
    signature:
        'Grille d’onglets 2px + Frise graphique Kente + Matrice contiguë sans gap',
    sections: ['marquee', 'category-showcase'],
    demoShopName: 'Studio Kente',
    demoEyebrow: 'Création Contemporaine & Identité',
    demoTitle: 'La force du geste graphique et des couleurs franches',
    demoSubtitle:
        'Textiles d’auteur, objets sculptés et créations audacieuses au croisement de l’héritage culturel et du design moderne.',
    demoAboutTitle: 'Un manifeste créatif sans compromis',
    demoAboutText:
        'Studio Kente met en lumière des créations vibrantes à forte personnalité, réalisées en séries limitées.',
    previewImage:
        'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=900&q=80',
    swatch: ['#c2410c', '#eab308', '#faf6f0'],
    headingFont: 'Syne',
    bodyFont: 'Plus Jakarta Sans',
    primary: Color(0xFFC2410C),
    primaryDark: Color(0xFF9A3412),
    accent: Color(0xFFEAB308),
    background: Color(0xFFFAF6F0),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF181411),
    muted: Color(0xFF6B5E54),
    border: Color(0xFF181411),
    radius: 0,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 13. AQUA
  ShopTheme(
    id: 'aqua',
    name: 'Aqua',
    description:
        'Cosmétique marine, spa & bien-être : hublot circulaire entouré de bulles orbitales et cartes galets ultra-arrondies',
    category: 'Nature & Terroir',
    signature:
        'Hublot circulaire + Bulles d’avantages orbitales + Cartes galets 32px',
    sections: ['trust-badges', 'faq'],
    demoShopName: 'Source Marine',
    demoEyebrow: 'Rituels de Soin & Bien-Être',
    demoTitle: 'Une parenthèse de fraîcheur et de sérénité',
    demoSubtitle:
        'Soins apaisants, essences botaniques et accessoires de spa conçus pour transformer votre routine quotidienne.',
    demoAboutTitle: 'La pureté des formules douces',
    demoAboutText:
        'Source Marine privilégie des compositions limpides, respectueuses et sensorielles pour offrir à votre peau un véritable moment de ressourcement.',
    previewImage:
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=900&q=80',
    swatch: ['#0891b2', '#2dd4bf', '#f0fdfa'],
    headingFont: 'Plus Jakarta Sans',
    bodyFont: 'DM Sans',
    primary: Color(0xFF0891B2),
    primaryDark: Color(0xFF0E7490),
    accent: Color(0xFF2DD4BF),
    background: Color(0xFFF0FDFA),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F292E),
    muted: Color(0xFF567A80),
    border: Color(0xFFCCFBF1),
    radius: 28,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.elevated,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 14. ORBIT
  ShopTheme(
    id: 'orbit',
    name: 'Orbit',
    description:
        'Studio design, horlogerie & objets connectés : anneau orbital à 4 nœuds cardinaux et tuiles Bento à capsule de prix flottante',
    category: 'Tech & Urbain',
    signature:
        'Anneau orbital à 4 nœuds + Tuiles Squircles avec capsule flottante sur l’image',
    sections: ['featured-spotlight', 'trust-badges'],
    demoShopName: 'Orbit Design Lab',
    demoEyebrow: 'Ingénierie & Objets de Précision',
    demoTitle: 'L’équilibre parfait entre fonction et géométrie',
    demoSubtitle:
        'Accessoires en aluminium usiné, lampes architecturales et objets intelligents au design minimaliste.',
    demoAboutTitle: 'La précision dans chaque millimètre',
    demoAboutText:
        'Notre studio développe et sélectionne des objets durables aux finitions irréprochables, pensés pour les espaces de vie et de travail modernes.',
    previewImage:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=80',
    swatch: ['#4f46e5', '#06b6d4', '#f5f7ff'],
    headingFont: 'Space Grotesk',
    bodyFont: 'Inter',
    primary: Color(0xFF4F46E5),
    primaryDark: Color(0xFF3730A3),
    accent: Color(0xFF06B6D4),
    background: Color(0xFFF5F7FF),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF111827),
    muted: Color(0xFF6B7280),
    border: Color(0xFFE0E7FF),
    radius: 24,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.elevated,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 15. ARDOISE
  ShopTheme(
    id: 'ardoise',
    name: 'Ardoise',
    description:
        'Bistronomie, cave, traiteur & épicerie fine : tableau d’ardoise encadré et carte de restaurant avec lignes de points (......) vers le prix',
    category: 'Gastronomie',
    signature:
        'Tableau du Chef + Carte gastronomique à lignes pointillées + Suggestion du jour',
    sections: ['testimonials', 'whatsapp-club'],
    demoShopName: 'La Table des Gourmets',
    demoEyebrow: 'Spécialités Maison & Épicerie Fine',
    demoTitle: 'Le goût du vrai, préparé chaque jour avec passion',
    demoSubtitle:
        'Découvrez notre carte du moment, nos produits de terroir et nos créations gourmandes disponibles sur commande directe.',
    demoAboutTitle: 'La générosité d’une maison de bouche',
    demoAboutText:
        'Nous sélectionnons les meilleurs ingrédients auprès de producteurs engagés pour vous proposer chaque jour une carte courte, fraîche et savoureuse.',
    previewImage:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80',
    swatch: ['#f59e0b', '#ef4444', '#18181b'],
    headingFont: 'Playfair Display',
    bodyFont: 'DM Sans',
    primary: Color(0xFFF59E0B),
    primaryDark: Color(0xFFD97706),
    accent: Color(0xFFEF4444),
    background: Color(0xFF18181B),
    surface: Color(0xFF232329),
    textColor: Color(0xFFF4F4F5),
    muted: Color(0xFFA1A1AA),
    border: Color(0xFF3F3F46),
    radius: 12,
    heroStyle: HeroStyle.split,
    heroMinHeight: 200,
    heroUsesImage: true,
    productLayout: ProductLayout.list,
    columns: 2,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 16. GAZETTE
  ShopTheme(
    id: 'gazette',
    name: 'La Gazette',
    description:
        'Journal imprimé Broadsheet : manchette de presse avec numéro d’édition, article de Une à lettrine et colonnes séparées par des filets d’encre',
    category: 'Mode & Édition',
    signature:
        'Manchette de quotidien + Une 3 colonnes à lettrine + Annonces à filets d’encre',
    sections: ['marquee', 'faq'],
    demoShopName: 'La Gazette des Arts',
    demoEyebrow: 'Édition Spéciale & Sélection de la Rédaction',
    demoTitle: 'Les plus belles pièces du moment réunies en cahier',
    demoSubtitle:
        'Chaque semaine, notre rédaction passe en revue et sélectionne des objets remarquables, disponibles immédiatement pour nos lecteurs.',
    demoAboutTitle: 'Pourquoi nous publions ce catalogue',
    demoAboutText:
        'À la manière d’un journal indépendant, nous documentons l’histoire, la fabrication et les qualités de chaque pièce que nous mettons en vente.',
    previewImage:
        'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=900&q=80',
    swatch: ['#1c1917', '#b91c1c', '#f5f2eb'],
    headingFont: 'Playfair Display',
    bodyFont: 'Cormorant Garamond',
    primary: Color(0xFF1C1917),
    primaryDark: Color(0xFF0C0A09),
    accent: Color(0xFFB91C1C),
    background: Color(0xFFF5F2EB),
    surface: Color(0xFFFCFAF5),
    textColor: Color(0xFF1C1917),
    muted: Color(0xFF57534E),
    border: Color(0xFF292524),
    radius: 2,
    heroStyle: HeroStyle.stacked,
    heroMinHeight: 220,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 4 / 3,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 17. BENTO
  ShopTheme(
    id: 'bento',
    name: 'Bento Studio',
    description:
        'Architecture Bento 2.0 : mosaïque asymétrique à 4 tuiles dès le haut de page et grille modulaire mêlant cartes simples et tuiles larges',
    category: 'Concept-Store',
    signature:
        'Mosaïque Hero 4-Tuiles + Grille Bento modulaire à cartes larges',
    sections: ['category-showcase', 'trust-badges'],
    demoShopName: 'Bento Studio',
    demoEyebrow: 'Design Modulaire & Quotidien',
    demoTitle: 'Organisez votre univers avec style et clarté',
    demoSubtitle:
        'Une collection d’objets astucieux, esthétiques et durables pour la maison, le bureau et vos déplacements.',
    demoAboutTitle: 'Chaque chose à sa juste place',
    demoAboutText:
        'Inspiré par l’art japonais de la modularité, Bento Studio réunit des créations pratiques et harmonieuses qui simplifient la vie de tous les jours.',
    previewImage:
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
    swatch: ['#2563eb', '#10b981', '#f1f5f9'],
    headingFont: 'Plus Jakarta Sans',
    bodyFont: 'Inter',
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1D4ED8),
    accent: Color(0xFF10B981),
    background: Color(0xFFF1F5F9),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F172A),
    muted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    radius: 24,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.elevated,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 18. VENDOME
  ShopTheme(
    id: 'vendome',
    name: 'Place Vendôme',
    description:
        'Haute joaillerie & parfumerie de prestige : triptyque vertical symétrique, planches de salon numérotées (N° 01) et filets ultra-fins',
    category: 'Luxe & Galerie',
    signature:
        'Triptyque Haute Joaillerie + Planches numérotées N° 01 + Diptyque Maison',
    sections: ['lookbook', 'whatsapp-club'],
    demoShopName: 'Maison Lutetia',
    demoEyebrow: 'Haute Création & Prestige',
    demoTitle: 'L’excellence du détail et la noblesse des matières',
    demoSubtitle:
        'Créations précieuses, éditions signées et pièces de caractère présentées dans le respect de la grande tradition.',
    demoAboutTitle: 'L’exigence des grandes maisons',
    demoAboutText:
        'Chaque pièce Maison Lutetia fait l’objet d’une attention particulière et vous est remise dans son écrin accompagnée de son certificat.',
    previewImage:
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=900&q=80',
    swatch: ['#1c1917', '#c5a059', '#faf8f5'],
    headingFont: 'Cormorant Garamond',
    bodyFont: 'DM Sans',
    primary: Color(0xFF1C1917),
    primaryDark: Color(0xFF0C0A09),
    accent: Color(0xFFC5A059),
    background: Color(0xFFFAF8F5),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF1C1917),
    muted: Color(0xFF78716C),
    border: Color(0xFFE7E2D8),
    radius: 2,
    heroStyle: HeroStyle.split,
    heroMinHeight: 220,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.minimal,
    imageAspectRatio: 4 / 5,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 19. SUPER-MARCHE
  ShopTheme(
    id: 'super-marche',
    name: 'Super-Marché',
    description:
        'Drive local & épicerie express : barre latérale de rayons, recherche rapide et cartes rayon claires',
    category: 'Grossiste & B2B',
    signature:
        'Sidebar latérale fixe + Rayons par catégorie + Cartes Drive',
    sections: ['trust-badges'],
    demoShopName: 'Marché Frais Express',
    demoEyebrow: 'Rayons Complets & Commande Rapide',
    demoTitle: 'Faites votre sélection en quelques clics',
    demoSubtitle:
        'Naviguez par rayon, repérez nos offres du jour et envoyez votre panier complet directement sur WhatsApp pour une préparation express.',
    demoAboutTitle: 'Votre commerce de proximité, encore plus simple',
    demoAboutText:
        'Fini l’attente : choisissez vos articles en ligne, vérifiez la disponibilité en stock et récupérez ou faites-vous livrer votre commande dans la journée.',
    previewImage:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80',
    swatch: ['#16a34a', '#eab308', '#f8fafc'],
    headingFont: 'Plus Jakarta Sans',
    bodyFont: 'Inter',
    primary: Color(0xFF16A34A),
    primaryDark: Color(0xFF15803D),
    accent: Color(0xFFEAB308),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    textColor: Color(0xFF0F172A),
    muted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    radius: 16,
    heroStyle: HeroStyle.strip,
    heroMinHeight: 170,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),

  // 20. SNEAKER-DROP
  ShopTheme(
    id: 'sneaker-drop',
    name: 'Sneaker Drop',
    description:
        'Streetwear & éditions limitées : dock flottant inférieur, bannière à découpe diagonale et cartes streetwear numérotées',
    category: 'Tech & Urbain',
    signature:
        'Dock flottant + Découpe diagonale Streetwear + Cartes Drop numérotées',
    sections: ['marquee'],
    demoShopName: 'Kicks Lab Officiel',
    demoEyebrow: 'Drop Exclusif & Stock Limité',
    demoTitle: 'Les pièces les plus recherchées du moment',
    demoSubtitle:
        'Éditions limitées, pièces streetwear authentifiées par nos experts et prêtes à rejoindre votre collection.',
    demoAboutTitle: 'Authenticité garantie sur chaque pièce',
    demoAboutText:
        'Chaque article proposé chez Kicks Lab est minutieusement contrôlé avant mise en ligne. Premier arrivé, premier servi.',
    previewImage:
        'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=900&q=80',
    swatch: ['#e11d48', '#facc15', '#09090b'],
    headingFont: 'Syne',
    bodyFont: 'Space Grotesk',
    primary: Color(0xFFE11D48),
    primaryDark: Color(0xFFBE123C),
    accent: Color(0xFFFACC15),
    background: Color(0xFF09090B),
    surface: Color(0xFF18181B),
    textColor: Color(0xFFFAFAFA),
    muted: Color(0xFFA1A1AA),
    border: Color(0xFF27272A),
    radius: 14,
    heroStyle: HeroStyle.split,
    heroMinHeight: 210,
    heroUsesImage: true,
    productLayout: ProductLayout.grid,
    columns: 3,
    cardStyle: CardStyle.bordered,
    imageAspectRatio: 1,
    showBadge: true,
    showAbout: true,
    showStats: true,
  ),
];

const String defaultThemeId = 'atelier';

/// Kept for backwards compatibility; empty now that all 20 themes are live.
class LockedShopTheme {
  const LockedShopTheme({required this.id, required this.name});

  final String id;
  final String name;
}

const List<LockedShopTheme> lockedStorefrontThemes = [];

/// Resolves a theme id, falling back to the default one.
ShopTheme getStorefrontTheme(String? id) {
  final clean = id?.trim().toLowerCase();
  for (final theme in storefrontThemes) {
    if (theme.id == clean) return theme;
  }
  return storefrontThemes.first;
}
