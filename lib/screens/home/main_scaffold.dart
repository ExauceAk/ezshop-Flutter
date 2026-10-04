import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import '../search/search_screen.dart';
import '../shop/shop_screen.dart';
import '../profile/profile_screen.dart';
import '../favorites/favorites_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    SizedBox.shrink(), // placeholder — center button opens ShopScreen as a route
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShopScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined,
                  context.l10n.t('nav.home')),
              _buildNavItem(1, Icons.search_rounded, Icons.search_outlined,
                  context.l10n.t('nav.search')),
              const SizedBox(width: 48), // spacer for the center FAB
              _buildNavItem(3, Icons.favorite_rounded, Icons.favorite_border_rounded,
                  context.l10n.t('nav.favorites')),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded,
                  context.l10n.t('nav.profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppTheme.primary : AppTheme.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
