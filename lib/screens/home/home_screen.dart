import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../settings/notifications_screen.dart';
import '../shop/shop_screen.dart';

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
        child: RefreshIndicator(
          onRefresh: () => context.read<AppProvider>().refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              // The app logo, so the greeting says which marketplace the user
              // is opening even before they read their own name.
              Image.asset('assets/images/logo.png', height: 34, width: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.currentUser?.name ?? context.l10n.t('home.guest'),
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              // Bell of the notification centre: the dot counts what the
              // admin published and the user has not opened yet.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                  ),
                  if (provider.unreadNotifications > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
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
          // Lands on "Mes boutiques" rather than straight on the creation form:
          // a seller who already has a shop must not be pushed into a second
          // one, and the creation form itself is reachable from that screen.
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
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
                        child: Text(context.l10n.t('home.banner.tag'),
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      Text(context.l10n.t('home.banner.title'),
                          style: GoogleFonts.poppins(fontSize: constraints.maxWidth < 400 ? 18 : 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(context.l10n.t('home.banner.subtitle'),
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Text(context.l10n.t('home.banner.cta'),
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
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
                _buildToggleBtn(context.l10n.t('home.filter.all'), provider.filterNeuf == null, () => provider.setFilterNeuf(null)),
                _buildToggleBtn(context.l10n.t('home.filter.neuf'), provider.filterNeuf == true, () => provider.setFilterNeuf(true)),
                _buildToggleBtn(context.l10n.t('home.filter.occasion'), provider.filterNeuf == false, () => provider.setFilterNeuf(false)),
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
                  Text(context.l10n.t('home.products'),
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
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
                      Text(context.l10n.t('home.products.empty'),
                          style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                    ]),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.61, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ProductCard(product: filtered[index]),
                    ),
                  ),
          ],
        );
      },
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
              child: Text(context.l10n.t('home.shops.popular'),
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
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
