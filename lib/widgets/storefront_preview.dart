import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
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
    this.scrollController,
  });

  final ShopTheme theme;
  final String name;
  final String description;
  final String slug;
  final String logoUrl;
  final String bannerUrl;
  final ShopThemeConfig config;
  final List<PreviewProduct> products;

  /// Scroll controller owned by the preview sheet, so dragging the sheet and
  /// scrolling the storefront are the same gesture.
  final ScrollController? scrollController;

  /// Falls back to the seller's defaults only when they left a field empty,
  /// exactly like `resolveContent` on the web.
  /// Copy shown when the seller left a field empty.
  ///
  /// Kept in sync with `resolveContent` on the web, and translated like the rest
  /// of the interface: an English seller previewing their theme must read the
  /// storefront copy in English.
  String _heroTitle(AppStrings l10n) {
    if (config.heroTitle.isNotEmpty) return config.heroTitle;
    return theme.heroUsesImage
        ? name
        : l10n.t('preview.welcome', {'name': name});
  }

  String _heroEyebrow(AppStrings l10n) => config.heroEyebrow.isNotEmpty
      ? config.heroEyebrow
      : l10n.t('preview.byline', {'slug': slug});

  String get _heroSubtitle =>
      config.heroSubtitle.isNotEmpty ? config.heroSubtitle : description;

  String get _heroImage {
    if (config.heroImageUrl.isNotEmpty) return config.heroImageUrl;
    if (bannerUrl.isNotEmpty) return bannerUrl;
    return theme.previewImage;
  }

  String _ctaLabel(AppStrings l10n) => config.heroCtaLabel.isNotEmpty
      ? config.heroCtaLabel
      : l10n.t('preview.discover');

  String _aboutTitle(AppStrings l10n) => config.aboutTitle.isNotEmpty
      ? config.aboutTitle
      : l10n.t('preview.aboutOf', {'name': name});

  String get _aboutText => config.aboutText.isNotEmpty ? config.aboutText : description;

  String _footerText(AppStrings l10n) => config.footerText.isNotEmpty
      ? config.footerText
      : l10n.t('preview.footer', {'name': name});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.background),
      child: SingleChildScrollView(
        controller: scrollController,
        // The storefront is wider than a phone in the desktop themes; letting
        // it stay portrait keeps every section readable instead of scrolling
        // sideways.
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(theme: theme, name: name, logoUrl: logoUrl),
            _buildHero(l10n),
            if (theme.showStats) _Stats(theme: theme, products: products),
            _Products(theme: theme, products: products),
            if (theme.showAbout)
              _About(theme: theme, title: _aboutTitle(l10n), text: _aboutText),
            _Footer(theme: theme, text: _footerText(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(AppStrings l10n) {
    switch (theme.heroStyle) {
      case HeroStyle.overlay:
        return _HeroOverlay(
          theme,
          _heroImage,
          _heroEyebrow(l10n),
          _heroTitle(l10n),
          _heroSubtitle,
          _ctaLabel(l10n),
        );
      case HeroStyle.split:
        return _HeroSplit(
          theme,
          _heroImage,
          _heroEyebrow(l10n),
          _heroTitle(l10n),
          _heroSubtitle,
          _ctaLabel(l10n),
        );
      case HeroStyle.stacked:
        return _HeroStacked(
            theme, _heroEyebrow(l10n), _heroTitle(l10n), _heroSubtitle, _ctaLabel(l10n));
      case HeroStyle.strip:
        return _HeroStrip(
          theme,
          _heroImage,
          logoUrl,
          _heroEyebrow(l10n),
          _heroTitle(l10n),
          _heroSubtitle,
        );
    }
  }
}

// ═══════════════════════════════════
// FONTS
// ═══════════════════════════════════

/// Heading font of a theme, mapped to the Google Fonts helper that matches it.
TextStyle _heading(ShopTheme theme, double size, {Color? color, FontWeight? weight}) {
  final base = TextStyle(
    fontSize: size,
    color: color ?? theme.textColor,
    fontWeight: weight,
  );
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
TextStyle _body(
  ShopTheme theme,
  double size, {
  Color? color,
  FontWeight? weight,
  double? height,
}) {
  final base = TextStyle(
    fontSize: size,
    color: color ?? theme.textColor,
    fontWeight: weight,
    height: height,
  );
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Below this width the links would squeeze the shop name out, so the
          // header drops to logo + name + basket.
          final showLinks = constraints.maxWidth >= 340;

          return Row(
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
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
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
              if (showLinks) ...[
                _NavLabel(
                    theme: theme, label: context.l10n.t('preview.shopName')),
                _NavLabel(theme: theme, label: context.l10n.t('preview.about')),
              ],
              const SizedBox(width: 6),
              Icon(Icons.shopping_bag_outlined, size: 18, color: theme.textColor),
            ],
          );
        },
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
    const padding = EdgeInsets.all(20);

    return Container(
      width: double.infinity,
      // A minimum, not a fixed height: a long shop description must push the
      // hero taller instead of overflowing it.
      constraints: BoxConstraints(minHeight: theme.heroMinHeight),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
        // Gradient keeps the copy readable over any image, and doubles as the
        // fallback background when the image fails to load.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: theme.heroMinHeight - padding.vertical),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: _body(theme, 10, color: Colors.white70, weight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _heading(theme, 26, color: Colors.white, weight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _body(theme, 12, color: Colors.white70),
              ),
              const SizedBox(height: 14),
              _Cta(theme: theme, label: cta),
            ],
          ),
        ),
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
    return ConstrainedBox(
      // Minimum height again: the copy column is what grows when the seller
      // writes a long description, and the image follows it.
      constraints: BoxConstraints(minHeight: theme.heroMinHeight),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: theme.heroMinHeight - 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: _body(theme, 10, color: theme.accent, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _heading(theme, 24, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 12, color: theme.muted),
                  ),
                  const SizedBox(height: 14),
                      _Cta(theme: theme, label: cta),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: theme.primary),
              ),
            ),
          ],
        ),
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
          Text(
            eyebrow.toUpperCase(),
            style: _body(theme, 10, color: theme.muted, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _heading(theme, 26, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _body(theme, 12, color: theme.muted),
          ),
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
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.heroMinHeight),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.heroMinHeight),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
          color: theme.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                logoUrl.isEmpty ? theme.previewImage : logoUrl,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 62, height: 62, color: theme.surface),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: _body(
                      theme,
                      9,
                      color: Colors.white70,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _heading(
                      theme,
                      20,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(theme.radius),
      ),
      child: Text(
        label,
        style: _body(theme, 11, color: Colors.white, weight: FontWeight.w600),
      ),
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
        border: theme.cardStyle == CardStyle.bordered
            ? Border.all(color: theme.border)
            : null,
      ),
      child: Row(
        children: [
          _stat(theme, '${products.length}', context.l10n.t('preview.products')),
          _divider(theme),
          _stat(theme, '$available', context.l10n.t('preview.availableCount')),
          _divider(theme),
          _stat(theme, '$fresh', context.l10n.t('preview.freshCount')),
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

  Widget _divider(ShopTheme theme) =>
      Container(width: 1, height: 22, color: theme.border);
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
          Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: _body(theme, 12, color: theme.muted, height: 1.5),
          ),
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: _body(theme, 11, color: theme.muted),
      ),
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

  /// A phone cannot show the 4 columns a desktop grid would; two keeps the
  /// cards legible instead of squeezing them into slivers.
  static const _phoneColumns = 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (theme.productLayout == ProductLayout.list) {
            return Column(
              children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProductRow(theme: theme, product: product),
                  ),
              ],
            );
          }

          const spacing = 12.0;
          const columns = _phoneColumns;
          final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          // The framed style insets the image, which adds to its box.
          final inset = theme.cardStyle == CardStyle.framed ? 10.0 : 0.0;
          final imageHeight = itemWidth / theme.imageAspectRatio + inset;
          // Name line + price line, plus the card's own padding.
          const textHeight = 58.0;

          final rows = <Widget>[];
          for (var start = 0; start < products.length; start += columns) {
            final slice = products.sublist(
              start,
              (start + columns).clamp(0, products.length),
            );
            rows.add(
              Padding(
                padding: const EdgeInsets.only(bottom: spacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: spacing),
                      SizedBox(
                        width: itemWidth,
                        height: imageHeight + textHeight,
                        child: i < slice.length
                            ? _ProductCard(theme: theme, product: slice[i])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(children: rows);
        },
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
                        child: Text(
                          product.isNeuf
                              ? context.l10n.t('product.tag.neuf')
                              : context.l10n.t('preview.usedShort'),
                          style: _body(
                            theme,
                            8,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (!product.isAvailable)
                    Positioned.fill(
                      child: ColoredBox(
                        color: theme.background.withValues(alpha: 0.6),
                        child: Center(
                          child: Text(
                            context.l10n.t('preview.soldOut'),
                            style: _body(theme, 10, color: theme.muted),
                          ),
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
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _body(theme, 11, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                // Cards are narrow on a phone: scale the price line down
                // rather than letting a long amount with a struck-through
                // original price overflow the card.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: _body(
                          theme,
                          11,
                          color: theme.primary,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          _formatPrice(product.oldPrice!),
                          style: _body(
                            theme,
                            9,
                            color: theme.muted,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
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
              child: Image.network(
                product.imageUrl,
                width: 78,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 78, height: 60, color: theme.background),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: _body(theme, 8, color: theme.accent, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 12, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(theme, 10, color: theme.muted),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(product.price),
                  style: _body(theme, 12, color: theme.primary, weight: FontWeight.w700),
                ),
                if (theme.showBadge)
                  Text(
                    product.isNeuf ? 'Neuf' : 'Occas.',
                    style: _body(theme, 9, color: theme.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
