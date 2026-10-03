import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';
import 'add_product_screen.dart';
import 'create_shop_screen.dart';
import 'edit_shop_screen.dart';
import '../../config/app_config.dart';

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
            Text('Aucune boutique', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              'Vous n\'avez pas encore de boutique.\nCréez-la en quelques secondes !',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShopScreen())),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text('Créer ma première boutique', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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
                        Text('Mes Boutiques',
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
              label: Text('Nouvelle boutique', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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
      onTap: () => setState(() => _selectedShop = shop),
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
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                      ),
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
                                      Container(
                                        width: 64, height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(shop.name,
                                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                            const SizedBox(height: 4),
                                            Text('${shop.productCount} produits • Note ${shop.rating}',
                                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                                            const SizedBox(height: 4),
                                            // Star rating
                                            Row(
                                              children: List.generate(5, (i) {
                                                return Icon(
                                                  i < shop.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                                  color: const Color(0xFFFFD700),
                                                  size: 18,
                                                );
                                              }),
                                            ),
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
                                        _buildDetailMetaChip(Icons.language_rounded, '${shop.subdomain}.mackettttz.test', 'Domaine de la boutique'),
                                      if (shop.subdomain.isNotEmpty) const SizedBox(width: 10),
                                      _buildDetailMetaChip(Icons.palette_rounded, theme?.name ?? shop.theme, 'Thème actif'),
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

              // ─── Sales banner ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                          child: const Icon(Icons.trending_up_rounded, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bravo ! Vos ventes sont en hausse',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  text: 'Vous avez ',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary),
                                  children: [
                                    TextSpan(
                                      text: '22%',
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success),
                                    ),
                                    TextSpan(text: ' de ventes en plus cette semaine'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 20),
                      ],
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
                      _buildStatCard('Produits', '${shop.productCount}', Icons.shopping_bag_outlined, const Color(0xFFE8EAF6)),
                      const SizedBox(width: 10),
                      _buildStatCard('Ventes', '127', Icons.trending_up_rounded, const Color(0xFFE8F5E9), change: '+22%', changeColor: AppTheme.success),
                      const SizedBox(width: 10),
                      _buildStatCard('Note', shop.rating.toString(), Icons.star_rounded, const Color(0xFFFCE4EC), change: '+0.5', changeColor: AppTheme.success),
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
                      Text('Produits (${shopProducts.length})',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => AddProductScreen(shopId: shop.id)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text('Ajouter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
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
                            Text('Aucun produit', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Ajoutez votre premier produit', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint)),
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

              // ─── Motivational banner ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.local_offer_outlined, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Envie d'augmenter vos ventes ?",
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Ajoutez plus de produits et attirez plus de clients vers votre boutique.',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary, height: 1.4)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
                                ),
                                child: Text('Voir conseils',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.close_rounded, size: 18, color: AppTheme.textHint),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  // ─── Opens the shop's public page in the device browser ───
  void _openPublicShop(Shop shop) {
    final url = Uri.parse(AppConfig.shopUrl(shop.subdomain));
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // ─── Meta chip for detail banner (with subtitle) ───
  Widget _buildDetailMetaChip(IconData icon, String title, String subtitle) {
    return Expanded(
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
          ],
        ),
      ),
    );
  }

  // ─── Stat card (4-column with change) ───
  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, {String? change, Color? changeColor}) {
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
            if (change != null) ...[
              const SizedBox(height: 4),
              Text(change,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: changeColor ?? AppTheme.success)),
            ],
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
                    child: Text('Neuf',
                        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.success)),
                  ),
                  const SizedBox(height: 6),
                  Text(product.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      text: 'Stock: ',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                      children: [
                        TextSpan(
                          text: '${(10 + product.price.round() % 20)}',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu icon
            const Icon(Icons.more_vert_rounded, color: AppTheme.textHint, size: 22),
          ],
        ),
      ),
    );
  }

}
