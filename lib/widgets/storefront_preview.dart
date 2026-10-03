import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/preview_product.dart';
import '../models/shop_theme.dart';
import '../models/shop_theme_config.dart';

/// Renders a storefront theme inside the app.
///
/// This is a native Flutter rendition of what the Next storefront produces for
/// the same theme, so a seller can compare themes and watch their own copy
/// apply while filling the creation form — no storefront server involved,
/// which matters because nothing is saved server-side at that point.
///
/// The two renderers are kept in sync by hand: `next/lib/shop/themes.ts` holds
/// the same five themes with the same tokens and structure flags.
class StorefrontPreview extends StatelessWidget {
  const StorefrontPreview({
    super.key,
    required this.theme,
    required this.name,
    required this.description,
    this.slug = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.config = const ShopThemeConfig(),
    this.products = samplePreviewProducts,
  });

  final ShopTheme theme;
  final String name;
  final String description;
  final String slug;
  final String logoUrl;
  final String bannerUrl;
  final ShopThemeConfig config;
  final List<PreviewProduct> products;

  /// Falls back to the seller's defaults only when they left a field empty,
  /// exactly like `resolveContent` on the web.
  String get _heroTitle {
    if (config.heroTitle.isNotEmpty) return config.heroTitle;
    return theme.heroUsesImage ? name : 'Bienvenue chez $name';
  }

  String get _heroEyebrow =>
      config.heroEyebrow.isNotEmpty ? config.heroEyebrow : 'Boutique · @$slug';

  String get _heroSubtitle =>
      config.heroSubtitle.isNotEmpty ? config.heroSubtitle : description;

  String get _heroImage {
    if (config.heroImageUrl.isNotEmpty) return config.heroImageUrl;
    if (bannerUrl.isNotEmpty) return bannerUrl;
    return theme.previewImage;
  }

  String get _ctaLabel =>
      config.heroCtaLabel.isNotEmpty ? config.heroCtaLabel : 'Découvrir la collection';

  String get _aboutTitle =>
      config.aboutTitle.isNotEmpty ? config.aboutTitle : 'À propos de $name';

  String get _aboutText =>
      config.aboutText.isNotEmpty ? config.aboutText : description;

  String get _footerText => config.footerText.isNotEmpty
      ? config.footerText
      : '$name · Boutique sur Macketttz';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(theme: theme, name: name, logoUrl: logoUrl),
          _buildHero(),
          if (theme.showStats) _Stats(theme: theme, products: products),
          _Products(
            theme: theme,
            products: products,
          ),
          if (theme.showAbout)
            _About(theme: theme, title: _aboutTitle, text: _aboutText),
          _Footer(theme: theme, text: _footerText),
        ],
      ),
    );
  }

  Widget _buildHero() {
    switch (theme.heroStyle) {
      case HeroStyle.overlay:
        return _HeroOverlay(theme, _heroImage, _heroEyebrow, _heroTitle,
            _heroSubtitle, _ctaLabel);
      case HeroStyle.split:
        return _HeroSplit(theme, _heroImage, _heroEyebrow, _heroTitle,
            _heroSubtitle, _ctaLabel);
      case HeroStyle.stacked:
        return _HeroStacked(theme, _heroEyebrow, _heroTitle, _heroSubtitle, _ctaLabel);
      case HeroStyle.strip:
        return _HeroStrip(theme, _heroImage, logoUrl, _heroEyebrow, _heroTitle,
            _heroSubtitle);
    }
  }
}

// ═══════════════════════════════════
// FONTS
// ═══════════════════════════════════

/// Heading font of a theme, mapped to the Google Fonts helper that matches it.
TextStyle _heading(ShopTheme theme, double size, {Color? color, FontWeight? weight}) {
  final base = TextStyle(fontSize: size, color: color ?? theme.textColor, fontWeight: weight);
  switch (theme.id) {
    case 'vitrine':
      return GoogleFonts.cormorantGaramond(textStyle: base);
    case 'editorial':
      return GoogleFonts.bodoniModa(textStyle: base);
    case 'annuaire':
      return GoogleFonts.manrope(textStyle: base);
    case 'nocturne':
      return GoogleFonts.spaceGrotesk(textStyle: base);
    default:
      return GoogleFonts.playfairDisplay(textStyle: base);
  }
}

/// Body font of a theme.
TextStyle _body(ShopTheme theme, double size, {Color? color, FontWeight? weight, double? height}) {
  final base = TextStyle(fontSize: size, color: color ?? theme.textColor, fontWeight: weight, height: height);
  switch (theme.id) {
    case 'vitrine':
      return GoogleFonts.jost(textStyle: base);
    case 'editorial':
      return GoogleFonts.archivo(textStyle: base);
    case 'nocturne':
      return GoogleFonts.inter(textStyle: base);
    default:
      return GoogleFonts.dmSans(textStyle: base);
  }
}

/// Prices are shown in CFA francs, matching the public storefront.
final NumberFormat _priceFormat = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: 'FCFA',
  decimalDigits: 0,
);

String _formatPrice(String decimal) {
  final value = double.tryParse(decimal) ?? 0;
  return _priceFormat.format(value).replaceAll(RegExp(r'[\u00a0\u202f\u2007]'), ' ');
}

// ═══════════════════════════════════
// SECTIONS
// ═══════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.name, required this.logoUrl});

  final ShopTheme theme;
  final String name;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: theme.isDark ? theme.surface : theme.background,
      child: Row(
        children: [
          if (logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(logoUrl, width: 28, height: 28, fit: BoxFit.cover),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.storefront_rounded, size: 16, color: Colors.white),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _heading(theme, 17, weight: FontWeight.w700),
            ),
          ),
          _NavLabel(theme: theme, label: 'Boutique'),
          _NavLabel(theme: theme, label: 'À propos'),
          const SizedBox(width: 6),
          Icon(Icons.shopping_bag_outlined, size: 18, color: theme.textColor),
        ],
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel({required this.theme, required this.label});

  final ShopTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(label, style: _body(theme, 12, color: theme.muted)),
    );
  }
}

/// Hero with a full-bleed image and the copy laid over it.
class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay(
    this.theme,
    this.imageUrl,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.cta,
  );

  final ShopTheme theme;
  final String imageUrl;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: theme.heroMinHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(color: theme.primaryDark)),
          // Gradient keeps the copy readable over any image.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow.toUpperCase(),
                    style: _body(theme, 10, color: Colors.white70, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _heading(theme, 26, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 12, color: Colors.white70)),
                const SizedBox(height: 14),
                _Cta(theme: theme, label: cta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero in two columns: copy on one side, image on the other.
class _HeroSplit extends StatelessWidget {
  const _HeroSplit(
    this.theme,
    this.imageUrl,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.cta,
  );

  final ShopTheme theme;
  final String imageUrl;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: theme.heroMinHeight,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eyebrow.toUpperCase(),
                      style: _body(theme, 10, color: theme.accent, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _heading(theme, 24, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _body(theme, 12, color: theme.muted)),
                  const SizedBox(height: 14),
                  _Cta(theme: theme, label: cta),
                ],
              ),
            ),
          ),
          Expanded(
            child: Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: theme.primary)),
          ),
        ],
      ),
    );
  }
}

/// Hero with centred copy and no image.
class _HeroStacked extends StatelessWidget {
  const _HeroStacked(this.theme, this.eyebrow, this.title, this.subtitle, this.cta);

  final ShopTheme theme;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(eyebrow.toUpperCase(),
              style: _body(theme, 10, color: theme.muted, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _heading(theme, 26, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _body(theme, 12, color: theme.muted)),
          const SizedBox(height: 16),
          _Cta(theme: theme, label: cta),
        ],
      ),
    );
  }
}

/// Short band with the logo beside the copy.
class _HeroStrip extends StatelessWidget {
  const _HeroStrip(
    this.theme,
    this.imageUrl,
    this.logoUrl,
    this.eyebrow,
    this.title,
    this.subtitle,
  );

  final ShopTheme theme;
  final String imageUrl;
  final String logoUrl;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.heroMinHeight,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover,
            onError: (_, __) {}),
        color: theme.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              logoUrl.isEmpty ? theme.previewImage : logoUrl,
              width: 62,
              height: 62,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 62, height: 62, color: theme.surface),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow.toUpperCase(),
                    style: _body(theme, 9, color: Colors.white70, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _heading(theme, 20, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 11, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.theme, required this.label});

  final ShopTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(theme.radius)),
      child: Text(label,
          style: _body(theme, 11, color: Colors.white, weight: FontWeight.w600)),
    );
  }
}

/// Three counters shown above the catalogue on most themes.
class _Stats extends StatelessWidget {
  const _Stats({required this.theme, required this.products});

  final ShopTheme theme;
  final List<PreviewProduct> products;

  @override
  Widget build(BuildContext context) {
    final available = products.where((p) => p.isAvailable).length;
    final fresh = products.where((p) => p.isNeuf).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radius),
        border: theme.cardStyle == CardStyle.bordered ? Border.all(color: theme.border) : null,
      ),
      child: Row(
        children: [
          _stat(theme, '${products.length}', 'produits'),
          _divider(theme),
          _stat(theme, '$available', 'disponibles'),
          _divider(theme),
          _stat(theme, '$fresh', 'neufs'),
        ],
      ),
    );
  }

  Widget _stat(ShopTheme theme, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: _heading(theme, 16, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: _body(theme, 10, color: theme.muted)),
        ],
      ),
    );
  }

  Widget _divider(ShopTheme theme) => Container(width: 1, height: 22, color: theme.border);
}

class _About extends StatelessWidget {
  const _About({required this.theme, required this.title, required this.text});

  final ShopTheme theme;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radius),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _heading(theme, 17, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(text, maxLines: 4, overflow: TextOverflow.ellipsis,
              style: _body(theme, 12, color: theme.muted, height: 1.5)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.theme, required this.text});

  final ShopTheme theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.surface : theme.background,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _body(theme, 11, color: theme.muted)),
    );
  }
}

// ═══════════════════════════════════
// PRODUCTS
// ═══════════════════════════════════

class _Products extends StatelessWidget {
  const _Products({required this.theme, required this.products});

  final ShopTheme theme;
  final List<PreviewProduct> products;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: theme.productLayout == ProductLayout.list
          ? Column(
              children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProductRow(theme: theme, product: product),
                  ),
              ],
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              // A phone is far narrower than the `columns` of a desktop grid,
              // so the preview packs fewer per row rather than overflowing.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: theme.columns > 3 ? 2 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  _ProductCard(theme: theme, product: products[index]),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.theme, required this.product});

  final ShopTheme theme;
  final PreviewProduct product;

  @override
  Widget build(BuildContext context) {
    final framed = theme.cardStyle == CardStyle.framed;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardStyle == CardStyle.minimal ? Colors.transparent : theme.surface,
        borderRadius: BorderRadius.circular(theme.radius),
        border: switch (theme.cardStyle) {
          CardStyle.bordered || CardStyle.framed => Border.all(color: theme.border),
          _ => null,
        },
        boxShadow: theme.cardStyle == CardStyle.elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              // The framed style insets the image inside a border.
              padding: framed ? const EdgeInsets.all(5) : EdgeInsets.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(color: theme.background),
                  ),
                  if (theme.showBadge)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isNeuf ? theme.primary : theme.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(product.isNeuf ? 'Neuf' : 'Occas.',
                            style: _body(theme, 8, color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                  if (!product.isAvailable)
                    Positioned.fill(
                      child: ColoredBox(
                        color: theme.background.withValues(alpha: 0.6),
                        child: Center(
                          child: Text('Épuisé', style: _body(theme, 10, color: theme.muted)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 11, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(_formatPrice(product.price),
                        style: _body(theme, 11, color: theme.primary, weight: FontWeight.w700)),
                    if (product.oldPrice != null) ...[
                      const SizedBox(width: 5),
                      Text(_formatPrice(product.oldPrice!),
                          style: _body(theme, 9, color: theme.muted).copyWith(
                            decoration: TextDecoration.lineThrough,
                          )),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.theme, required this.product});

  final ShopTheme theme;
  final PreviewProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radius),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radius * 0.6),
              child: Image.network(product.imageUrl,
                  width: 78, height: 60, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 78, height: 60, color: theme.background)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category.toUpperCase(),
                      style: _body(theme, 8, color: theme.accent, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(theme, 12, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(theme, 10, color: theme.muted)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatPrice(product.price),
                    style: _body(theme, 12, color: theme.primary, weight: FontWeight.w700)),
                if (theme.showBadge)
                  Text(product.isNeuf ? 'Neuf' : 'Occas.',
                      style: _body(theme, 9, color: theme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}