import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';
import '../shop/create_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCreateShopBanner(),
              _buildConditionToggle(),
              _buildPopularProducts(),
              _buildPopularShops(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour, 👋', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
                    Text(
                      provider.currentUser?.name ?? 'Invité',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateShopBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateShopScreen())),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20, top: -20,
                  child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('🏪 Marketplace', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      Text('Créez votre propre boutique', style: GoogleFonts.poppins(fontSize: constraints.maxWidth < 400 ? 18 : 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Proposez vos produits et vendez en ligne', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Text('Commencer →', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConditionToggle() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(
              children: [
                _buildToggleBtn('Tous', provider.filterNeuf == null, () => provider.setFilterNeuf(null)),
                _buildToggleBtn('Neuf', provider.filterNeuf == true, () => provider.setFilterNeuf(true)),
                _buildToggleBtn('Occasion', provider.filterNeuf == false, () => provider.setFilterNeuf(false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : AppTheme.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildPopularProducts() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final filtered = provider.filteredProducts;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Produits', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('${filtered.length}', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded, size: 60, color: AppTheme.textHint.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('Aucun produit', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                    ]),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _buildProductCard(filtered[index]),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF1F3F5), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(product.images.isNotEmpty ? product.images.first : '', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 40, color: AppTheme.textHint)),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: product.isNeuf ? AppTheme.success : AppTheme.warning, borderRadius: BorderRadius.circular(6)),
                      child: Text(product.isNeuf ? 'Neuf' : 'Occasion', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(6)),
                        child: Text('-${product.discountPercent.round()}%', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    top: 8, right: product.discountPercent > 0 ? 42 : 8,
                    child: GestureDetector(
                      onTap: () => context.read<AppProvider>().toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                        child: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: product.isFavorite ? AppTheme.error : AppTheme.textHint),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('\$${product.price.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularShops() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.shops.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text('Boutiques populaires', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.shops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final shop = provider.shops[index];
                  return _buildShopCard(shop.name);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShopCard(String name) {
    return Container(
      width: 130,
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
