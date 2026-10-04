import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_model.dart';
import '../../models/shop_removal_preview.dart';
import '../../services/api_client.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../product/product_detail_screen.dart';
import '../common/coming_soon_screen.dart';
import 'add_product_screen.dart';
import 'create_shop_screen.dart';
import 'edit_shop_screen.dart';
import 'shop_webview_screen.dart';
import '../../config/app_config.dart';
import '../../utils/price_format.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Shop? _selectedShop;

  /// Illustration violette servant de fond aux écrans de boutique.
  static const _backdropAsset = 'assets/images/storefront-illustration-preview.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final userShops = provider.getUserShops();

            if (userShops.isEmpty) return _buildCreateShopView();
            if (_selectedShop != null) return _buildShopDetailView(_selectedShop!, provider);
            return _buildShopListView(userShops, provider);
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  NO SHOPS → Empty state
  // ═══════════════════════════════════════
  Widget _buildCreateShopView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded, size: 34, color: AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(context.l10n.t('shop.list.empty'),
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              context.l10n.t('shop.list.emptySubtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShopScreen())),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text(context.l10n.t('shop.list.createFirst'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  SHOP LIST
  // ═══════════════════════════════════════
  Widget _buildShopListView(List<Shop> shops, AppProvider provider) {
    final l10n = context.l10n;

    return Column(
      children: [
        // ─── Hero banner (same purple artwork as the shop detail) ───
        SizedBox(
          height: 148,
          width: double.infinity,
          child: _buildVioletBackdrop(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('shop.list.title'),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('${shops.length} boutique${shops.length > 1 ? 's' : ''} en ligne',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _buildShopCard(shops[index], provider),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, -4)),
            ],
          ),
          child: SizedBox(
            width: double.infinity, height: 54,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShopScreen())),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(context.l10n.t('shop.list.new'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(Shop shop, AppProvider provider) {
    // Colours et noms viennent du catalogue de thèmes, plus d'une table en dur.
    final accent = provider.themeColorOf(shop);
    final theme = provider.themeOf(shop);
    final themeLabel = theme?.name ?? shop.theme;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedShop = shop);
        // Counters and received orders are only needed on the detail screen, so
        // they are fetched here instead of with the shop list.
        provider.loadShopStats(shop.id);
        provider.loadShopOrders(shop.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Card cover: the shop's own banner, the artwork otherwise ───
            SizedBox(
              height: 96,
              width: double.infinity,
              child: _buildVioletBackdrop(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                imageUrl: shop.bannerUrl.isNotEmpty ? shop.bannerUrl : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildShopLogo(shop, size: 44, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(shop.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 11),
                            const SizedBox(width: 2),
                            Text(shop.rating.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  _buildInfoChip(Icons.inventory_2_outlined, '${shop.productCount}', accent),
                  const SizedBox(width: 6),
                  _buildInfoChip(Icons.palette_rounded, themeLabel, accent),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  PURPLE BACKDROP
  // ═══════════════════════════════════════

  /// Purple artwork used as the background of the shop screens.
  ///
  /// Falls back to the bundled illustration when the shop has no banner, and
  /// always darkens it a little so white text stays readable on top.
  Widget _buildVioletBackdrop({
    required Widget child,
    BorderRadius borderRadius = BorderRadius.zero,
    String? imageUrl,
  }) {
    final backdrop = imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              _backdropAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            _backdropAsset,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          );

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          backdrop,
          // Voile sombre : garde le contraste du texte blanc.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.18),
                  Colors.black.withOpacity(0.34),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  //  SHOP DETAIL (new design)
  // ═══════════════════════════════════════
  Widget _buildShopDetailView(Shop shop, AppProvider provider) {
    final l10n = context.l10n;
    final shopProducts = provider.getProductsByShop(shop.id);
    final accent = provider.themeColorOf(shop);
    final theme = provider.themeOf(shop);

    return Column(
      children: [
        // ─── AppBar ───
        Container(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => setState(() => _selectedShop = null),
              ),
              Expanded(
                child: Text(
                  shop.name,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Template badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (theme?.name ?? shop.theme).toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: accent),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ouvre l'éditeur de boutique (thème, logo, textes)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditShopScreen(shop: shop)),
                ),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune_rounded, size: 20, color: accent),
                ),
              ),
              const SizedBox(width: 8),
              // Ouvre la boutique publique dans le navigateur
              GestureDetector(
                onTap: () => _openPublicShop(shop),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.open_in_new_rounded, size: 20, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),

        // ─── Scrollable content ───
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ─── Shop banner card ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Full background image
                            Image.asset(
                              _backdropAsset,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            // Content overlay
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Shop icon + name + rating
                                  Row(
                                    children: [
                                      _buildShopLogo(shop, size: 64, radius: 18),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(shop.name,
                                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                            const SizedBox(height: 4),
                                            Text('${shop.productCount} produits',
                                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  // Meta chips row
                                  Row(
                                    children: [
                                      if (shop.subdomain.isNotEmpty)
                                        _buildDetailMetaChip(
                                          Icons.language_rounded,
                                          AppConfig.shopDisplayUrl(shop.subdomain),
                                          l10n.t('shop.detail.viewShop'),
                                          onTap: () => _openShopWebView(shop),
                                        ),
                                      if (shop.subdomain.isNotEmpty) const SizedBox(width: 10),
                                      _buildDetailMetaChip(
                                        Icons.palette_rounded,
                                        theme?.name ?? shop.theme,
                                        l10n.t('shop.detail.themeActive'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Boost banner ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    onTap: _openBoostPage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.t('shop.detail.boost.title'),
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(l10n.t('shop.detail.boost.subtitle'),
                                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Stats row (3 columns) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        l10n.t('shop.detail.stats.products'),
                        '${shop.productCount}',
                        Icons.shopping_bag_outlined,
                        const Color(0xFFE8EAF6),
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        l10n.t('shop.detail.stats.orders'),
                        '${provider.statsOfShop(shop.id)?.orderCount ?? 0}',
                        Icons.trending_up_rounded,
                        const Color(0xFFE8F5E9),
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        l10n.t('shop.detail.stats.rating'),
                        shop.rating.toString(),
                        Icons.star_rounded,
                        const Color(0xFFFCE4EC),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Products header ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n.t('shop.detail.stats.products')} (${shopProducts.length})',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => AddProductScreen(shopId: shop.id)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(l10n.t('shop.detail.products.add'),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Products list ───
              shopProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.inventory_2_outlined, size: 36, color: AppTheme.primary.withOpacity(0.4)),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.t('shop.detail.products.empty'),
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text(l10n.t('shop.detail.products.emptySubtitle'),
                                style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProductListCard(shopProducts[index]),
                          childCount: shopProducts.length,
                        ),
                      ),
                    ),

              // ─── Received orders ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.t('shop.detail.orders.title'),
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(
                        '${provider.ordersOfShop(shop.id).length}',
                        style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              _buildReceivedOrders(provider, shop),

              // ─── Danger zone: only for the shop's own seller ───
              if (_isOwner(shop)) _buildDangerZone(shop),

              // ─── Closing space, so the last card is not flush with the edge ───
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),

      ],
    );
  }

  /// Whether the signed-in user owns this shop.
///
/// Deleting is offered only to the owner: the API refuses anyone else, and
/// showing a red button to a visitor who cannot use it is just a dead end.
bool _isOwner(Shop shop) {
  final user = context.read<AppProvider>().currentUser;
  return user != null && shop.ownerId == user.id;
}

/// The delete button, kept at the bottom of the page rather than in the
/// header: it is destructive, and a slip of the thumb on a phone should not be
/// able to remove a whole shop.
Widget _buildDangerZone(Shop shop) {
  final l10n = context.l10n;

  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('shop.detail.danger.title'),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDeleteShop(shop),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(l10n.t('shop.detail.danger.delete')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Asks before deleting the shop, saying exactly what goes with it.
///
/// Two steps on purpose: the counts are fetched first so the dialog can name
/// them, because "your products will be deleted" is not the same warning as
/// "12 products and 3 orders will be deleted". The dialog then asks for the
/// shop name to be typed, which is the only confirmation that survives a
/// mis-tap on the second dialog too.
Future<void> _confirmDeleteShop(Shop shop) async {
  final l10n = context.l10n;
  final provider = context.read<AppProvider>();
  final messenger = ScaffoldMessenger.of(context);

  // The counts come from the API so the warning cannot drift from what will
  // actually be removed.
  ShopRemovalPreview? preview;
  try {
    preview = await provider.shopRemovalPreview(shop.id);
  } on ApiException {
    preview = null;
  }
  if (!mounted) return;

  final nameController = TextEditingController();
  final typed = await showDialog<bool>(
    context: context,
    builder: (ctx) => _DeleteShopDialog(
      shop: shop,
      preview: preview,
      nameController: nameController,
    ),
  );
  nameController.dispose();
  if (typed != true || !mounted) return;

  final deleted = await provider.deleteShop(shop.id);
  if (!mounted) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        deleted
            ? l10n.t('shop.detail.danger.done')
            : (provider.dataError ?? l10n.t('shop.detail.danger.failed')),
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: deleted ? AppTheme.success : AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  if (!deleted || !mounted) return;

  // The shop is gone: leave its page instead of showing an empty shell.
  if (mounted) setState(() => _selectedShop = null);
  if (mounted) Navigator.of(context).maybePop();
}

// ─── Orders buyers placed for the products of this shop ───
  ///
  /// Shows who ordered, what, and since when: the seller needs that to answer
  /// on WhatsApp, which is where the deal actually happens.
  Widget _buildReceivedOrders(AppProvider provider, Shop shop) {
    final orders = provider.ordersOfShop(shop.id);

    if (orders.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.t('shop.detail.orders.empty'),
            style: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildOrderCard(orders[index], accent: provider.themeColorOf(shop)),
          childCount: orders.length,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, {required Color accent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No status badge: order status is not something the app tracks or
          // acts on yet, showing "En attente" on every order was only noise.
          Text(
            order.buyerName.isEmpty
                ? context.l10n.t('shop.detail.orders.client')
                : order.buyerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${item.productName} — ${formatPrice(item.productPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${order.date.day}/${order.date.month}/${order.date.year}',
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  // ─── Product menu: edit or delete ───
  Future<void> _onProductMenu(String action, Product product) async {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddProductScreen(
              shopId: product.shopId,
              existing: product,
            ),
          ),
        );

      case 'delete':
        await _confirmDelete(product);
    }
  }

  /// Asks before deleting: the product disappears from the storefront at once
  /// and there is no undo in the app.
  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.t('product.delete.title')),
        content: Text(context.l10n.t('product.delete.body', {'name': product.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.t('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.t('product.menu.delete'),
                style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<AppProvider>();
    final deleted = await provider.deleteProduct(product.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? context.l10n.t('product.delete.done')
              : (provider.dataError ?? context.l10n.t('product.delete.failed')),
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: deleted ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Opens the "boost" page: announced, not built yet ───
  void _openBoostPage() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(
          title: context.l10n.t('shop.detail.boost.title'),
          message: context.l10n.t('soon.boostMessage'),
        ),
      ),
    );
  }

  // ─── Opens the shop's public page in the device browser ───
  void _openPublicShop(Shop shop) {
    final url = Uri.parse(AppConfig.shopUrl(shop.subdomain));
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // ─── Opens the shop's public page inside the app ───
  void _openShopWebView(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopWebViewScreen(shop: shop)),
    );
  }

  // ─── Shop logo, falling back to the storefront icon ───
  Widget _buildShopLogo(Shop shop, {required double size, required double radius}) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.storefront_rounded, color: Colors.white, size: size * 0.5),
    );

    if (shop.logoUrl.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        shop.logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }

  // ─── Meta chip for detail banner (with subtitle) ───
  Widget _buildDetailMetaChip(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 9, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Stat card ───
  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.textPrimary, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ─── Product list card ───
  Widget _buildProductListCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80, height: 80,
                color: const Color(0xFFF1F3F5),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first : '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 28, color: AppTheme.textHint),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Neuf badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(context.l10n.t('product.tag.neuf'),
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.success)),
                  ),
                  const SizedBox(height: 6),
                  Text(product.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(formatPrice(product.price),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ],
              ),
            ),
            // Actions on the product: edit or delete, from the seller's own shop
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textHint, size: 22),
              onSelected: (action) => _onProductMenu(action, product),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textPrimary),
                      const SizedBox(width: 10),
                      Text(context.l10n.t('product.menu.edit')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                      const SizedBox(width: 10),
                      Text(context.l10n.t('product.menu.delete'),
                          style: const TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

/// Confirmation dialog for the shop deletion.
///
/// States what the cascade will remove, with real counts, and only enables the
/// confirm button once the shop name has been typed: a shop is the seller's
/// whole storefront, and the mistake is not recoverable from inside the app.
class _DeleteShopDialog extends StatefulWidget {
  const _DeleteShopDialog({
    required this.shop,
    required this.preview,
    required this.nameController,
  });

  final Shop shop;

  /// Null when the counts could not be fetched; the dialog then warns without
  /// quoting numbers rather than inventing them.
  final ShopRemovalPreview? preview;

  final TextEditingController nameController;

  @override
  State<_DeleteShopDialog> createState() => _DeleteShopDialogState();
}

class _DeleteShopDialogState extends State<_DeleteShopDialog> {
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onTyped);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onTyped);
    super.dispose();
  }

  void _onTyped() {
    final matches = widget.nameController.text.trim() == widget.shop.name;
    if (matches != _canConfirm) setState(() => _canConfirm = matches);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = widget.preview;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.t('shop.detail.delete.title'),
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.t('shop.detail.delete.body', {'name': widget.shop.name}),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            if (preview == null)
              Text(
                l10n.t('shop.detail.delete.unknownCounts'),
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.error),
              )
            else ...[
              _row(
                Icons.inventory_2_outlined,
                l10n.t('shop.detail.delete.products', {'count': '${preview.productCount}'}),
              ),
              _row(
                Icons.receipt_long_outlined,
                l10n.t('shop.detail.delete.orders', {'count': '${preview.orderCount}'}),
              ),
              _row(
                Icons.star_outline_rounded,
                l10n.t('shop.detail.delete.ratings', {'count': '${preview.ratingCount}'}),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.t('shop.detail.delete.confirmLabel', {'name': widget.shop.name}),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: widget.nameController,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: widget.shop.name,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => _onTyped(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.t('common.cancel')),
        ),
        TextButton(
          // Disabled until the name matches, so the dialog cannot be dismissed
          // by an accidental tap on the wrong button.
          onPressed: _canConfirm ? () => Navigator.pop(context, true) : null,
          child: Text(
            l10n.t('shop.detail.delete.confirm'),
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13.5),
              ),
            ),
          ],
        ),
      );
}
