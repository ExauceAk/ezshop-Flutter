import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../utils/price_format.dart';
import '../../widgets/product_tags.dart';
import '../../widgets/shop_rating_sheet.dart';
import '../../widgets/top_fade.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = widget.product;
    // The shop is fetched with the rest of the app state, so the seller line
    // shows the shop name and its WhatsApp number instead of the raw shop id.
    final shop = context.watch<AppProvider>().getShopById(product.shopId);
    final images = product.images.where((url) => url.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Image Carousel with AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              ),
            ),
            actions: [
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  return GestureDetector(
                    onTap: () => provider.toggleFavorite(product.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? AppTheme.error : AppTheme.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image PageView — tap opens the zoomable viewer.
                  GestureDetector(
                    onTap: images.isEmpty ? null : _openGallery,
                    child: images.isEmpty
                        ? Container(
                            color: const Color(0xFFF1F3F5),
                            child: const Center(
                              child: Icon(Icons.image_outlined, size: 60, color: AppTheme.textHint),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                color: const Color(0xFFF1F3F5),
                                child: Hero(
                                  tag: _heroTag(index),
                                  child: Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.image_outlined, size: 60, color: AppTheme.textHint),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Image indicator dots
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? AppTheme.primary
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // The picture runs under the status bar: fading it towards white keeps
                  // the clock and the battery readable over it.
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopFade(),
                  ),
                  // Condition badge
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 16,
                    child: ProductTags(product: product, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (product.discountPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercent.round()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Row(
                    children: [
                      Text(
                        formatPrice(product.price),
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          formatPrice(product.oldPrice!),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // The price is only a starting point when the seller accepts
                  // an offer, so the page says it right below the amount.
                  if (product.isNegotiable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.handshake_outlined, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.t('product.negotiableHint'),
                              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Description
                  Text(
                    l10n.t('product.description'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Seller info. Tapping it rates the shop: the seller card is where a buyer
                  // already is when deciding whether to trust the shop.
                  GestureDetector(
                    onTap: shop == null ? null : () => showShopRatingSheet(context, shop!),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration,
                      child: Row(
                        children: [
                          _buildShopLogo(shop),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.t('product.soldBy'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  shop?.name ?? product.sellerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (shop != null)
                                  _buildRatingLine(context, shop),
                              ],
                            ),
                          ),
                          if (shop != null)
                            const Icon(
                              Icons.star_outline_rounded,
                              color: AppTheme.textHint,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contact via WhatsApp button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: shop != null ? () => _orderOnWhatsApp(product, shop) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFB9C4BD),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 22),
                      label: Text(
                        shop != null
                            ? l10n.t('product.orderWhatsapp')
                            : l10n.t('product.unknownShop'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tag shared by the carousel and the fullscreen viewer, so the opened image
/// is the one that flies into place.
String _heroTag(int index) => 'product-image-${widget.product.id}-$index';

/// Opens the fullscreen viewer: pinch to zoom, swipe between images.
  void _openGallery() {
    final images = widget.product.images.where((url) => url.isNotEmpty).toList();
    if (images.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, animation, __) => _ProductGallery(
          images: images,
          initialIndex: _currentImageIndex,
          heroTagFor: _heroTag,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// Shop logo, falling back to the storefront icon.
Widget _buildShopLogo(Shop? shop) {
  final logoUrl = shop?.logoUrl ?? '';

  if (logoUrl.isEmpty) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.storefront_rounded, color: AppTheme.primary),
    );
  }

  return ClipOval(
    child: Image.network(
      logoUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.storefront_rounded, color: AppTheme.primary),
      ),
    ),
  );
}

/// Opens WhatsApp on the shop's own number, with the product pre-filled, after
/// recording the order so the seller sees who asked for what.
///
/// The order is saved first: if the buyer never reaches WhatsApp the seller
/// still knows there was an intent, and the buyer's "Mes Commandes" lists it.
/// Tapping twice on the same day updates the same order instead of creating a
/// duplicate, which the API decides.
Future<void> _orderOnWhatsApp(Product product, Shop shop) async {
  final l10n = context.l10n;
  final provider = context.read<AppProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final created = await provider.orderViaWhatsApp(product.id);

  final message = Uri.encodeComponent(
    l10n.t('product.whatsappMessage', {
      'name': product.name,
      'price': formatPrice(product.price),
    }),
  );
  final digits = shop.whatsappLink
      .split('?')
      .first
      .split('/')
      .last
      .replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.isEmpty) {
    _showNoWhatsApp(context);
    return;
  }

  final url = Uri.parse('https://wa.me/$digits?text=$message');
  final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

  if (!opened) {
    _showNoWhatsApp(context);
    return;
  }

  if (!created) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          provider.dataError ?? l10n.t('product.orderAlreadyRecorded'),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Average rating of a shop, under its name.
Widget _buildRatingLine(BuildContext context, Shop shop) {
  final l10n = context.l10n;

  if (shop.ratingCount == 0) {
    return Text(
      l10n.t('product.noReviews'),
      style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
    );
  }

  return Row(
    children: [
      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
      const SizedBox(width: 2),
      Text(
        '${shop.rating.toStringAsFixed(1)} (${shop.ratingCount})',
        style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary),
      ),
      const SizedBox(width: 6),
      Text(
        l10n.t('product.rate'),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    ],
  );
}

void _showNoWhatsApp(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        context.l10n.t('product.noWhatsapp'),
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    ),
  );
}
}

/// Fullscreen image viewer opened from the carousel.
///
/// No veil over the picture here: on a black background the photo is what the
/// seller is looking at, and a fade would sit on top of the zoomed image.
class _ProductGallery extends StatefulWidget {
  const _ProductGallery({
    required this.images,
    required this.initialIndex,
    required this.heroTagFor,
  });

  final List<String> images;
  final int initialIndex;
  final String Function(int index) heroTagFor;

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          pageController: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) => setState(() => _index = index),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (_, event) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.images[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTagFor(index)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          ),
        ),

        // A fullscreen tap-to-close overlay would swallow the pinch and the swipe,
        // so the viewer is closed with a button instead.
        Positioned(
          top: MediaQuery.paddingOf(context).top + 6,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
            ),
          ),
        ),

        if (widget.images.length > 1)
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _index == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _index == index ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
      ],
    );
  }
}
