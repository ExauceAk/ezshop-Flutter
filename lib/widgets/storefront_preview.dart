import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/preview_product.dart';
import '../models/shop_theme.dart';
import '../models/shop_theme_config.dart';

/// Renders a storefront theme inside the app with bespoke mobile layouts for
/// all 20 standalone themes, live custom colour overrides (`primaryColor`,
/// `accentColor`, `backgroundColor`), optional e-commerce sections, and
/// realistic French demo copy when form fields are empty.
class StorefrontPreview extends StatefulWidget {
  const StorefrontPreview({
    super.key,
    required this.theme,
    required this.name,
    required this.description,
    this.slug = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.logoFile,
    this.bannerFile,
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
  final File? logoFile;
  final File? bannerFile;
  final ShopThemeConfig config;
  final List<PreviewProduct> products;

  /// Scroll controller owned by the preview sheet, so dragging the sheet and
  /// scrolling the storefront are the same gesture.
  final ScrollController? scrollController;

  @override
  State<StorefrontPreview> createState() => _StorefrontPreviewState();
}

class _StorefrontPreviewState extends State<StorefrontPreview> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final Set<String> _cart = {};
  int? _openFaqIndex = 0;

  ShopTheme get _activeTheme => widget.theme.applyCustomColors(widget.config);

  /// Realistic shop name: uses what the seller typed, or the theme's curated
  /// French maison name instead of "Votre Boutique" or a raw slug.
  String get _shopName {
    final trimmed = widget.name.trim();
    if (trimmed.isNotEmpty && trimmed != 'Votre Boutique') return trimmed;
    return _activeTheme.demoShopName;
  }

  String get _heroEyebrow {
    if (widget.config.heroEyebrow.trim().isNotEmpty) {
      return widget.config.heroEyebrow.trim();
    }
    return _activeTheme.demoEyebrow;
  }

  String get _heroTitle {
    if (widget.config.heroTitle.trim().isNotEmpty) {
      return widget.config.heroTitle.trim();
    }
    if (widget.name.trim().isNotEmpty && widget.name.trim() != 'Votre Boutique') {
      return widget.name.trim();
    }
    return _activeTheme.demoTitle;
  }

  String get _heroSubtitle {
    if (widget.config.heroSubtitle.trim().isNotEmpty) {
      return widget.config.heroSubtitle.trim();
    }
    final desc = widget.description.trim();
    if (desc.isNotEmpty && desc != 'Description de la boutique') {
      return desc;
    }
    return _activeTheme.demoSubtitle;
  }

  String get _ctaLabel {
    if (widget.config.heroCtaLabel.trim().isNotEmpty) {
      return widget.config.heroCtaLabel.trim();
    }
    return context.l10n.t('preview.discover');
  }

  String get _aboutTitle {
    if (widget.config.aboutTitle.trim().isNotEmpty) {
      return widget.config.aboutTitle.trim();
    }
    if (widget.name.trim().isNotEmpty && widget.name.trim() != 'Votre Boutique') {
      return 'À propos de $_shopName';
    }
    return _activeTheme.demoAboutTitle;
  }

  String get _aboutText {
    if (widget.config.aboutText.trim().isNotEmpty) {
      return widget.config.aboutText.trim();
    }
    final desc = widget.description.trim();
    if (desc.isNotEmpty && desc != 'Description de la boutique') {
      return desc;
    }
    return _activeTheme.demoAboutText;
  }

  String get _footerText {
    if (widget.config.footerText.trim().isNotEmpty) {
      return widget.config.footerText.trim();
    }
    return '© ${DateTime.now().year} $_shopName — Tous droits réservés.';
  }

  String get _heroImageUrl {
    if (widget.config.heroImageUrl.trim().isNotEmpty) {
      return widget.config.heroImageUrl.trim();
    }
    if (widget.bannerUrl.trim().isNotEmpty) return widget.bannerUrl.trim();
    return _activeTheme.previewImage;
  }

  List<String> get _categories {
    final set = <String>{'Tous'};
    for (final p in widget.products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList();
  }

  List<PreviewProduct> get _filteredProducts {
    return widget.products.where((p) {
      if (_selectedCategory != 'Tous' && p.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        return p.name.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  int get _cartCount => _cart.length;

  void _addToCart(PreviewProduct product) {
    setState(() {
      _cart.add(product.name);
    });
  }

  void _openFullImage(BuildContext context, List<String> images, int initialIndex) {
    int activeIndex = initialIndex;
    final pageController = PageController(initialPage: initialIndex);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: images.length,
                onPageChanged: (idx) => setDialogState(() => activeIndex = idx),
                itemBuilder: (_, idx) => InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      images[idx],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        size: 56,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(dialogCtx).top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogCtx),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: activeIndex == idx ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activeIndex == idx
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).whenComplete(pageController.dispose);
  }

  void _showProductDetail(PreviewProduct product) {
    final t = _activeTheme;
    final images = product.allImages;
    int selectedImageIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentImage = images.isNotEmpty
              ? images[selectedImageIndex.clamp(0, images.length - 1)]
              : product.imageUrl;
          return Container(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: t.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.muted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openFullImage(
                    ctx,
                    images.isNotEmpty ? images : [product.imageUrl],
                    selectedImageIndex,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(t.radius.clamp(6, 20)),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            currentImage,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) =>
                                ColoredBox(color: t.background),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.zoom_out_map_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  if (images.length > 1) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      '${selectedImageIndex + 1}/${images.length}',
                                      style: _body(
                                        t,
                                        10,
                                        color: Colors.white,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (images.length > 1) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, idx) {
                        final active = idx == selectedImageIndex;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedImageIndex = idx),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: active ? t.primary : t.border,
                                width: active ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                images[idx],
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, __, ___) =>
                                    ColoredBox(color: t.background),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (product.category.isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: _body(t, 10,
                              color: t.primary, weight: FontWeight.w700),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (product.isNeuf ? t.primary : t.accent)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isNeuf ? 'Neuf' : 'Occasion',
                        style: _body(
                          t,
                          10,
                          color: product.isNeuf ? t.primary : t.accent,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatPrice(product.price),
                      style: _heading(t, 18,
                          color: t.primary, weight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: _heading(t, 20, weight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: _body(t, 13, color: t.muted, height: 1.5),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    _addToCart(product);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(t.radius.clamp(6, 16)),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    'Ajouter au panier',
                    style:
                        _body(t, 13, color: Colors.white, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _activeTheme;
    final sections = t.sections;

    return DecoratedBox(
      decoration: BoxDecoration(color: t.background),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: t.id == 'sneaker-drop' ? 76 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sections.contains('marquee')) _buildMarquee(t),
                _buildHeader(t),
                _buildHero(t),
                if (t.showStats && t.id != 'annuaire') _buildStats(t),
                if (sections.contains('trust-badges')) _buildTrustBadges(t),
                if (sections.contains('category-showcase'))
                  _buildCategoryShowcase(t),
                if (sections.contains('featured-spotlight') &&
                    widget.products.isNotEmpty)
                  _buildFeaturedSpotlight(t, widget.products.first),
                _buildCatalogSection(t),
                if (sections.contains('lookbook')) _buildLookbook(t),
                if (sections.contains('craftsmanship')) _buildCraftsmanship(t),
                if (t.showAbout) _buildAboutSection(t),
                if (sections.contains('testimonials')) _buildTestimonials(t),
                if (sections.contains('faq')) _buildFaq(t),
                if (sections.contains('whatsapp-club')) _buildWhatsappClub(t),
                _buildFooter(t),
              ],
            ),
          ),
          if (t.id == 'sneaker-drop') _buildSneakerFloatingDock(t),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HEADER VARIATIONS (tailored per theme)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(ShopTheme t) {
    switch (t.id) {
      case 'gazette':
        return Container(
          color: t.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ÉDITION N° 42',
                    style: _body(t, 9, color: t.muted, weight: FontWeight.w700),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        _heroEyebrow.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _body(t, 9,
                            color: t.accent, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Text(
                    '${widget.products.length} RÉF.',
                    style: _body(t, 9, color: t.muted, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Divider(height: 1, thickness: 1.5, color: t.textColor),
              const SizedBox(height: 8),
              Text(
                _shopName.toUpperCase(),
                textAlign: TextAlign.center,
                style: _heading(t, 24, weight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, thickness: 1, color: t.textColor),
            ],
          ),
        );

      case 'editorial':
        return Container(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            children: [
              Text(
                _heroEyebrow.toUpperCase(),
                style: _body(t, 9, color: t.accent, weight: FontWeight.w600)
                    .copyWith(letterSpacing: 2.0),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildLogoAvatar(t, size: 26),
                  Expanded(
                    child: Text(
                      _shopName.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _heading(t, 20, weight: FontWeight.w700)
                          .copyWith(letterSpacing: 2.5),
                    ),
                  ),
                  _buildCartPill(t),
                ],
              ),
            ],
          ),
        );

      case 'nocturne':
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: t.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: t.primary.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildLogoAvatar(t, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SALON PRIVÉ',
                        style: _body(t, 8, color: t.primary, weight: FontWeight.w700)
                            .copyWith(letterSpacing: 1.5),
                      ),
                      Text(
                        _shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _heading(t, 15, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _buildCartPill(t),
              ],
            ),
          ),
        );

      case 'neon':
        return Container(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(
              bottom: BorderSide(color: t.primary.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.16),
                  border: Border.all(color: t.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SYS.ON',
                  style: _body(t, 9, color: t.primary, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _shopName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _heading(t, 15, weight: FontWeight.w800)
                      .copyWith(letterSpacing: 1.2),
                ),
              ),
              _buildCartPill(t),
            ],
          ),
        );

      case 'tribal':
        return Container(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(
              top: BorderSide(color: t.textColor, width: 2),
              bottom: BorderSide(color: t.textColor, width: 2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                color: t.primary,
                child: Text(
                  'STUDIO',
                  style: _body(t, 10, color: Colors.white, weight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _shopName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _heading(t, 15, weight: FontWeight.w800),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: t.accent,
                  border: Border(left: BorderSide(color: t.textColor, width: 2)),
                ),
                child: Text(
                  'PANIER ($_cartCount)',
                  style: _body(t, 10, color: t.textColor, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            children: [
              _buildLogoAvatar(t, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _heading(t, 16, weight: FontWeight.w700),
                    ),
                    Text(
                      t.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 10, color: t.muted),
                    ),
                  ],
                ),
              ),
              _buildCartPill(t),
            ],
          ),
        );
    }
  }

  Widget _buildLogoAvatar(ShopTheme t, {double size = 30}) {
    if (widget.logoFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: Image.file(
          widget.logoFile!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (widget.logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: Image.network(
          widget.logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultLogoBadge(t, size),
        ),
      );
    }
    return _defaultLogoBadge(t, size);
  }

  Widget _defaultLogoBadge(ShopTheme t, double size) {
    final initial = _shopName.isNotEmpty ? _shopName[0].toUpperCase() : 'B';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: _heading(t, size * 0.48, color: Colors.white, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildCartPill(ShopTheme t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: t.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 14, color: t.primary),
          const SizedBox(width: 4),
          Text(
            '$_cartCount',
            style: _body(t, 11, color: t.primary, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImageWidget(ShopTheme t, {BoxFit fit = BoxFit.cover}) {
    if (widget.bannerFile != null) {
      return Image.file(
        widget.bannerFile!,
        fit: fit,
        alignment: Alignment.topCenter,
      );
    }
    return Image.network(
      _heroImageUrl,
      fit: fit,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t.primary, t.accent],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. HERO VARIATIONS (tailored per theme)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHero(ShopTheme t) {
    switch (t.id) {
      case 'bento':
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        _heroEyebrow.toUpperCase(),
                        style: _body(t, 9, color: t.primary, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _heroTitle,
                      style: _heading(t, 22, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _heroSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 12, color: t.muted, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _Cta(theme: t, label: _ctaLabel),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildHeroImageWidget(t),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                              child: Text(
                                'Collection $_shopName',
                                style: _body(t, 11,
                                    color: Colors.white, weight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: Colors.white, size: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.products.length} pièces',
                                  style: _heading(t, 16,
                                      color: Colors.white,
                                      weight: FontWeight.w800),
                                ),
                                Text(
                                  'Stock direct',
                                  style: _body(t, 10, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'gazette':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.border, width: 1.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'À LA UNE • ${_heroEyebrow.toUpperCase()}',
                style: _body(t, 10, color: t.accent, weight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                _heroTitle,
                style: _heading(t, 24, weight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: _buildHeroImageWidget(t),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _heroSubtitle.isNotEmpty ? _heroSubtitle[0].toUpperCase() : 'D',
                    style: _heading(t, 36, color: t.accent, weight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _heroSubtitle.length > 1 ? _heroSubtitle.substring(1) : _heroSubtitle,
                      style: _body(t, 12.5, color: t.textColor, height: 1.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'baobab':
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(140),
                  bottom: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroImageWidget(t),
                      Positioned(
                        bottom: 10,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _heroEyebrow,
                            style: _body(t, 10,
                                color: t.primary, weight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _heroTitle,
                textAlign: TextAlign.center,
                style: _heading(t, 23, weight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _heroSubtitle,
                textAlign: TextAlign.center,
                style: _body(t, 12, color: t.muted, height: 1.45),
              ),
              const SizedBox(height: 12),
              _Cta(theme: t, label: _ctaLabel),
            ],
          ),
        );

      case 'aqua':
      case 'orbit':
        return Container(
          padding: const EdgeInsets.all(18),
          color: t.surface,
          child: Column(
            children: [
              SizedBox(
                height: 165,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: t.primary.withValues(alpha: 0.35),
                          width: t.id == 'orbit' ? 1.5 : 4,
                        ),
                      ),
                    ),
                    ClipOval(
                      child: SizedBox(
                        width: 132,
                        height: 132,
                        child: _buildHeroImageWidget(t),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 18,
                      child: _pillBadge(t, t.id == 'orbit' ? 'PRÉCISION' : '100% PUR'),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 18,
                      child: _pillBadge(t, 'EN STOCK'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _heroEyebrow.toUpperCase(),
                style: _body(t, 10, color: t.primary, weight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _heroTitle,
                textAlign: TextAlign.center,
                style: _heading(t, 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                _heroSubtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _body(t, 12, color: t.muted, height: 1.4),
              ),
              const SizedBox(height: 12),
              _Cta(theme: t, label: _ctaLabel),
            ],
          ),
        );

      case 'annuaire':
      case 'super-marche':
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.primary,
            borderRadius: BorderRadius.circular(t.radius.clamp(8, 20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.id == 'super-marche' ? 'DRIVE EXPRESS' : 'COMPTOIR PRO',
                      style: _body(t, 9, color: Colors.black87, weight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _heroEyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 10, color: Colors.white70, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _heroTitle,
                style: _heading(t, 20, color: Colors.white, weight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                _heroSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _body(t, 11.5, color: Colors.white.withValues(alpha: 0.88)),
              ),
              const SizedBox(height: 12),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 16, color: t.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: _body(t, 12, color: Colors.black87),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Rechercher un produit',
                          hintStyle: _body(t, 11.5, color: Colors.black45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'vendome':
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Column(
            children: [
              Text(
                'MAISON DE HAUTE CRÉATION • $_heroEyebrow'.toUpperCase(),
                textAlign: TextAlign.center,
                style: _body(t, 9, color: t.accent, weight: FontWeight.w700)
                    .copyWith(letterSpacing: 2.0),
              ),
              const SizedBox(height: 8),
              Text(
                _heroTitle,
                textAlign: TextAlign.center,
                style: _heading(t, 24, weight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 135,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: _buildHeroImageWidget(t),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.background,
                          border: Border.all(color: t.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _heroSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: _body(t, 10.5, color: t.textColor, height: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          widget.products.firstOrNull?.imageUrl ?? _heroImageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => _buildHeroImageWidget(t),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        break;
    }

    switch (t.heroStyle) {
      case HeroStyle.overlay:
        return Container(
          constraints: BoxConstraints(minHeight: t.heroMinHeight),
          child: Stack(
            children: [
              Positioned.fill(child: _buildHeroImageWidget(t)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        _heroEyebrow.toUpperCase(),
                        style: _body(t, 9,
                            color: Colors.white, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _heroTitle,
                      style: _heading(t, 25,
                          color: Colors.white, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _heroSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 12, color: Colors.white.withValues(alpha: 0.88)),
                    ),
                    const SizedBox(height: 14),
                    _Cta(theme: t, label: _ctaLabel),
                  ],
                ),
              ),
            ],
          ),
        );

      case HeroStyle.split:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _heroEyebrow.toUpperCase(),
                          style: _body(t, 9.5,
                              color: t.accent, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _heroTitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _heading(t, 21, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _heroSubtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _body(t, 11.5, color: t.muted, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        _Cta(theme: t, label: _ctaLabel),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Transform.rotate(
                      angle: t.id == 'vintage' ? -0.03 : 0,
                      child: Container(
                        height: 165,
                        decoration: BoxDecoration(
                          color: t.background,
                          borderRadius:
                              BorderRadius.circular(t.radius.clamp(0, 22)),
                          border: Border.all(
                            color: t.id == 'nocturne' || t.id == 'zellige'
                                ? t.primary
                                : t.border,
                            width: t.id == 'tribal' ? 2 : 1.2,
                          ),
                        ),
                        padding: EdgeInsets.all(
                          t.cardStyle == CardStyle.framed ? 5 : 0,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              (t.radius - 3).clamp(0, 18)),
                          child: _buildHeroImageWidget(t),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case HeroStyle.stacked:
        return Container(
          color: t.surface,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            children: [
              Text(
                _heroEyebrow.toUpperCase(),
                style: _body(t, 10, color: t.accent, weight: FontWeight.w700)
                    .copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                _heroTitle,
                textAlign: TextAlign.center,
                style: _heading(t, 25, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _heroSubtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _body(t, 12, color: t.muted, height: 1.45),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(t.radius.clamp(2, 18)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: _buildHeroImageWidget(t),
                ),
              ),
            ],
          ),
        );

      case HeroStyle.strip:
        return Container(
          padding: const EdgeInsets.all(16),
          color: t.primary,
          child: Row(
            children: [
              _buildLogoAvatar(t, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _heroEyebrow.toUpperCase(),
                      style: _body(t, 9,
                          color: Colors.white70, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _heroTitle,
                      style: _heading(t, 19,
                          color: Colors.white, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _heroSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _pillBadge(ShopTheme t, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: t.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        text,
        style: _body(t, 9, color: t.primary, weight: FontWeight.w800),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STATS & CATEGORY FILTER BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStats(ShopTheme t) {
    final available = widget.products.length;
    final fresh = widget.products.where((p) => p.isNeuf).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.clamp(4, 20)),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          _statCell(t, '${widget.products.length}', 'Références'),
          Container(width: 1, height: 22, color: t.border),
          _statCell(t, '$available', 'En stock'),
          Container(width: 1, height: 22, color: t.border),
          _statCell(t, '$fresh', 'Neufs'),
        ],
      ),
    );
  }

  Widget _statCell(ShopTheme t, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: _heading(t, 16, color: t.primary, weight: FontWeight.w800)),
          const SizedBox(height: 1),
          Text(label, style: _body(t, 10, color: t.muted)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. CATALOG & BESPOKE PRODUCT CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCatalogSection(ShopTheme t) {
    final filtered = _filteredProducts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  t.id == 'ardoise'
                      ? 'La Carte du Moment'
                      : t.id == 'gazette'
                          ? 'Cahier des Références'
                          : 'Catalogue ($_shopName)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _heading(t, 18, weight: FontWeight.w800),
                ),
              ),
              Text(
                '${filtered.length} art.',
                style: _body(t, 11, color: t.muted, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final cat in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedCategory == cat
                              ? t.primary
                              : t.surface,
                          borderRadius:
                              BorderRadius.circular(t.radius.clamp(4, 99)),
                          border: Border.all(
                            color: _selectedCategory == cat
                                ? t.primary
                                : t.border,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: _body(
                            t,
                            11,
                            color: _selectedCategory == cat
                                ? Colors.white
                                : t.textColor,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (t.id == 'ardoise')
            _buildArdoiseMenu(t, filtered)
          else if (t.productLayout == ProductLayout.list || t.id == 'annuaire')
            Column(
              children: [
                for (var i = 0; i < filtered.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildListRow(t, filtered[i], i),
                  ),
              ],
            )
          else if (t.id == 'editorial' && filtered.isNotEmpty)
            _buildEditorialSpread(t, filtered)
          else
            _buildGrid(t, filtered),
        ],
      ),
    );
  }

  /// Bistro dotted menu specific to `ardoise`.
  Widget _buildArdoiseMenu(ShopTheme t, List<PreviewProduct> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.primary.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showProductDetail(items[i]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      items[i].imageUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 54, height: 54, color: t.background),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _heading(t, 14, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _body(t, 10.5, color: t.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatPrice(items[i].price),
                    style: _heading(t, 13, color: t.primary, weight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Magazine asymmetric spread for `editorial` (lead card full width + 2-col pairs).
  Widget _buildEditorialSpread(ShopTheme t, List<PreviewProduct> items) {
    final lead = items.first;
    final rest = items.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _showProductDetail(lead),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 190,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        lead.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) =>
                            ColoredBox(color: t.background),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          color: t.primary,
                          child: Text(
                            'PIÈCE PHARE N° 01',
                            style: _body(t, 9,
                                color: Colors.white, weight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lead.name,
                                style: _heading(t, 17, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              lead.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _body(t, 11, color: t.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatPrice(lead.price),
                        style: _heading(t, 15,
                            color: t.primary, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildGrid(t, rest),
      ],
    );
  }

  Widget _buildGrid(ShopTheme t, List<PreviewProduct> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = t.id == 'tribal' ? 0.0 : 12.0;
        const columns = 2;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final inset = t.cardStyle == CardStyle.framed ? 8.0 : 0.0;
        final imageHeight =
            (itemWidth / t.imageAspectRatio).clamp(110.0, 175.0) + inset + 10.0;
        const textHeight = 82.0;

        final rows = <Widget>[];
        for (var start = 0; start < items.length; start += columns) {
          final slice = items.sublist(
            start,
            (start + columns).clamp(0, items.length),
          );
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) SizedBox(width: spacing),
                    SizedBox(
                      width: itemWidth,
                      height: imageHeight + textHeight,
                      child: i < slice.length
                          ? _buildProductCard(t, slice[i], start + i)
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
    );
  }

  Widget _buildProductCard(ShopTheme t, PreviewProduct product, int index) {
    final framed = t.cardStyle == CardStyle.framed;
    final isBaobab = t.id == 'baobab';
    final isVendome = t.id == 'vendome';
    final isSneaker = t.id == 'sneaker-drop';

    return GestureDetector(
      onTap: () => _showProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: t.cardStyle == CardStyle.minimal ? t.surface : t.surface,
          borderRadius: isBaobab
              ? const BorderRadius.vertical(
                  top: Radius.circular(60),
                  bottom: Radius.circular(14),
                )
              : BorderRadius.circular(t.radius),
          border: Border.all(
            color: t.id == 'tribal' ? t.textColor : t.border,
            width: t.id == 'tribal' ? 1.5 : 1,
          ),
          boxShadow: t.cardStyle == CardStyle.elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
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
                padding: framed ? const EdgeInsets.all(5) : EdgeInsets.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: framed
                          ? BorderRadius.circular((t.radius - 2).clamp(0, 18))
                          : BorderRadius.zero,
                      child: Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) =>
                            ColoredBox(color: t.background),
                      ),
                    ),
                    if (isVendome)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          color: t.surface.withValues(alpha: 0.92),
                          child: Text(
                            'N° 0${index + 1}',
                            style: _heading(t, 9,
                                color: t.primary, weight: FontWeight.w700),
                          ),
                        ),
                      )
                    else if (t.showBadge)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.isNeuf ? t.primary : t.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.isNeuf ? 'Neuf' : 'Occas.',
                            style: _body(
                              t,
                              8,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSneaker)
                    Text(
                      'DROP #0${index + 1} • AUTHENTIFIÉ',
                      style: _body(t, 7.5,
                          color: t.accent, weight: FontWeight.w700),
                    )
                  else if (product.category.isNotEmpty)
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 8, color: t.muted, weight: FontWeight.w600),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(t, 11.5, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                _formatPrice(product.price),
                                style: _body(
                                  t,
                                  11.5,
                                  color: t.primary,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius:
                                BorderRadius.circular(t.radius.clamp(4, 8)),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListRow(ShopTheme t, PreviewProduct product, int index) {
    return GestureDetector(
      onTap: () => _showProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radius),
          border: Border.all(color: t.border),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular((t.radius * 0.6).clamp(4, 12)),
              child: Image.network(
                product.imageUrl,
                width: 68,
                height: 64,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) =>
                    Container(width: 68, height: 64, color: t.background),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'REF-0${index + 1}',
                          style: _body(t, 8,
                              color: t.primary, weight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _body(t, 8,
                              color: t.accent, weight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(t, 12.5, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _body(t, 10, color: t.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(product.price),
                  style: _body(t, 11.5,
                      color: t.primary, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _addToCart(product),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Ajouter au panier',
                      style: _body(t, 9,
                          color: Colors.white, weight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. OPTIONAL E-COMMERCE SECTIONS (mirroring next/components/shop/shared/optional-sections.tsx)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMarquee(ShopTheme t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: t.primary,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _marqueeItem(t, 'BIENVENUE CHEZ ${_shopName.toUpperCase()}'),
            _marqueeItem(t, '• COMMANDE DIRECTE SUR WHATSAPP'),
            _marqueeItem(t, '• STOCK VÉRIFIÉ EN TEMPS RÉEL'),
          ],
        ),
      ),
    );
  }

  Widget _marqueeItem(ShopTheme t, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Text(
        text,
        style: _body(t, 9.5, color: Colors.white, weight: FontWeight.w700)
            .copyWith(letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildTrustBadges(ShopTheme t) {
    const items = [
      (Icons.verified_user_outlined, 'Qualité Vérifiée', 'Contrôlé avant envoi'),
      (Icons.chat_bubble_outline_rounded, 'Direct WhatsApp', 'Réponse rapide 7j/7'),
      (Icons.local_shipping_outlined, 'Remise Rapide', 'Retrait ou livraison'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(t.radius.clamp(6, 16)),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  children: [
                    Icon(items[i].$1, size: 18, color: t.primary),
                    const SizedBox(height: 5),
                    Text(
                      items[i].$2,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 10, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$3,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _body(t, 8.5, color: t.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryShowcase(ShopTheme t) {
    final cats = _categories.where((c) => c != 'Tous').take(3).toList();
    if (cats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Les Univers de $_shopName',
            style: _heading(t, 16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < cats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cats[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius:
                            BorderRadius.circular(t.radius.clamp(6, 16)),
                        border: Border.all(color: t.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '0${i + 1}',
                            style: _body(t, 9,
                                color: t.accent, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cats[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _heading(t, 12.5, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSpotlight(ShopTheme t, PreviewProduct spotlight) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.clamp(6, 20)),
        border: Border.all(color: t.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(t.radius.clamp(4, 14)),
            child: Image.network(
              spotlight.imageUrl,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  Container(width: 84, height: 84, color: t.background),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIÈCE VEDETTE',
                  style: _body(t, 9, color: t.accent, weight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  spotlight.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _heading(t, 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatPrice(spotlight.price),
                  style: _body(t, 12, color: t.primary, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLookbook(ShopTheme t) {
    final photos = widget.products.take(3).toList();
    if (photos.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lookbook & Inspirations',
            style: _heading(t, 17, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                for (var i = 0; i < photos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showProductDetail(photos[i]),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(t.radius.clamp(4, 16)),
                        child: Image.network(
                          photos[i].imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          height: 120,
                          errorBuilder: (_, __, ___) =>
                              Container(height: 120, color: t.background),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftsmanship(ShopTheme t) {
    const steps = [
      ('01', 'Explorez', 'Choisissez vos pièces en stock'),
      ('02', 'WhatsApp', 'Message pré-rempli en 1 clic'),
      ('03', 'Réception', 'Retrait ou livraison rapide'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radius.clamp(6, 18)),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commander en 3 étapes simples',
              style: _heading(t, 15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].$1,
                          style: _heading(t, 14,
                              color: t.primary, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i].$2,
                          style: _body(t, 11, weight: FontWeight.w700),
                        ),
                        Text(
                          steps[i].$3,
                          style: _body(t, 9.5, color: t.muted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(ShopTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.clamp(4, 22)),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTRE MAISON',
            style: _body(t, 9, color: t.accent, weight: FontWeight.w800)
                .copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Text(_aboutTitle, style: _heading(t, 17, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            _aboutText,
            style: _body(t, 12, color: t.muted, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials(ShopTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.clamp(6, 18)),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, size: 16, color: t.accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Avis clients vérifiés (4.9/5)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _heading(t, 14, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '« Réponse ultra rapide sur WhatsApp et articles parfaitement conformes aux photos. Je recommande vivement $_shopName ! »',
            style: _body(t, 11.5, color: t.muted, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            '— Aminata K., Cliente fidèle',
            style: _body(t, 10, color: t.textColor, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildFaq(ShopTheme t) {
    const faqs = [
      (
        'Comment passer commande ?',
        'Ajoutez vos articles au panier puis validez sur WhatsApp : votre récapitulatif est prêt.'
      ),
      (
        'Les produits sont-ils en stock ?',
        'Oui, la disponibilité affichée est mise à jour en temps réel.'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes',
            style: _heading(t, 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < faqs.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(t.radius.clamp(4, 14)),
                border: Border.all(color: t.border),
              ),
              child: InkWell(
                onTap: () => setState(
                    () => _openFaqIndex = _openFaqIndex == i ? null : i),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faqs[i].$1,
                              style: _body(t, 12, weight: FontWeight.w700),
                            ),
                          ),
                          Icon(
                            _openFaqIndex == i
                                ? Icons.remove_rounded
                                : Icons.add_rounded,
                            size: 16,
                            color: t.primary,
                          ),
                        ],
                      ),
                      if (_openFaqIndex == i) ...[
                        const SizedBox(height: 6),
                        Text(
                          faqs[i].$2,
                          style: _body(t, 11, color: t.muted, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWhatsappClub(ShopTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius.clamp(6, 20)),
        border: Border.all(color: t.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded, color: t.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conciergerie WhatsApp Directe',
                  style: _heading(t, 14, weight: FontWeight.w700),
                ),
                Text(
                  'Une question ? L’équipe de $_shopName vous répond en direct.',
                  style: _body(t, 11, color: t.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ShopTheme t) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Column(
        children: [
          Text(
            _shopName,
            style: _heading(t, 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _footerText,
            textAlign: TextAlign.center,
            style: _body(t, 11, color: t.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildSneakerFloatingDock(ShopTheme t) {
    return Positioned(
      bottom: 14,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: t.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: t.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'DROP LIVE • ${widget.products.length} PIÈCES',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _body(t, 10, color: t.textColor, weight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'PANIER ($_cartCount)',
                style: _body(t, 10, color: Colors.white, weight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FONTS & PRICE FORMATTERS
// ═══════════════════════════════════════════════════════════════════════════

TextStyle _heading(
  ShopTheme theme,
  double size, {
  Color? color,
  FontWeight? weight,
}) {
  final base = TextStyle(
    fontSize: size,
    color: color ?? theme.textColor,
    fontWeight: weight,
  );
  switch (theme.headingFont) {
    case 'Cormorant Garamond':
      return GoogleFonts.cormorantGaramond(textStyle: base);
    case 'Fraunces':
      return GoogleFonts.fraunces(textStyle: base);
    case 'Space Grotesk':
      return GoogleFonts.spaceGrotesk(textStyle: base);
    case 'Syne':
      return GoogleFonts.syne(textStyle: base);
    case 'Plus Jakarta Sans':
      return GoogleFonts.plusJakartaSans(textStyle: base);
    default:
      return GoogleFonts.playfairDisplay(textStyle: base);
  }
}

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
  switch (theme.bodyFont) {
    case 'Inter':
      return GoogleFonts.inter(textStyle: base);
    case 'Plus Jakarta Sans':
      return GoogleFonts.plusJakartaSans(textStyle: base);
    case 'Space Grotesk':
      return GoogleFonts.spaceGrotesk(textStyle: base);
    case 'Cormorant Garamond':
      return GoogleFonts.cormorantGaramond(textStyle: base);
    default:
      return GoogleFonts.dmSans(textStyle: base);
  }
}

final NumberFormat _priceFormat = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: 'FCFA',
  decimalDigits: 0,
);

String _formatPrice(String decimal) {
  final value = double.tryParse(decimal) ?? 0;
  return _priceFormat
      .format(value)
      .replaceAll(RegExp(r'[\u00a0\u202f\u2007]'), ' ');
}

class _Cta extends StatelessWidget {
  const _Cta({required this.theme, required this.label});

  final ShopTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(theme.radius.clamp(4, 16)),
      ),
      child: Text(
        label,
        style: _body(theme, 11, color: Colors.white, weight: FontWeight.w700),
      ),
    );
  }
}
