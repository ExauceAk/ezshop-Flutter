import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_pick.dart';
import '../../utils/price_format.dart';
import '../common/coming_soon_screen.dart';
import '../favorites/favorites_screen.dart';
import '../settings/about_screen.dart';
import '../settings/help_screen.dart';
import '../settings/language_screen.dart';
import '../settings/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// True while a picked avatar is being uploaded, so the badge can show a
  /// spinner instead of pretending the tap did nothing.
  bool _savingAvatar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final user = provider.currentUser;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(
                    user?.name ?? context.l10n.t('profile.guest'),
                    user?.email ?? '',
                    user?.avatarUrl ?? '',
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsList(provider),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String avatarUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                context.l10n.t('profile.title'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                // The clip lives on the photo, not on the container: a
                // rectangle clip would leave the photo's own white margins
                // visible as bars on either side of the face.
                child: ClipOval(
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitial(name),
                          )
                        : _buildInitial(name),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _savingAvatar
                    ? null
                    : () => _pickAvatar(context.read<AppProvider>()),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: _savingAvatar
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback shown until a photo is picked: the first letter of the name.
  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  /// Picks a square photo, then uploads it and attaches it to the profile.
  ///
  /// The crop keeps the framing the user chose instead of a layout cutting
  /// their face off at display time.
  Future<void> _pickAvatar(AppProvider provider) async {
    final file = await pickAndCropSquare(
      context,
      title: context.l10n.t('profile.avatar.cropTitle'),
    );
    if (file == null || !mounted) return;

    setState(() => _savingAvatar = true);
    final saved = await provider.updateAvatar(file);
    if (!mounted) return;
    setState(() => _savingAvatar = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? context.l10n.t('profile.avatar.updated')
              : (provider.dataError ?? context.l10n.t('profile.avatar.failed')),
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: saved ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSettingsList(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.t('profile.settings'),
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.person_outline_rounded,
              'Modifier le profil',
              () => _showEditProfileDialog(context, provider),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.storefront_rounded,
              context.l10n.t('profile.menu.shops'),
              () => Navigator.pushNamed(context, '/shop'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.shopping_bag_outlined,
              context.l10n.t('profile.menu.orders'),
              () => _showOrdersDialog(context, provider),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.favorite_outline_rounded,
              context.l10n.t('profile.menu.favorites'),
              // The same screen as the Favoris tab, pushed so the profile menu
              // does not have to know how the tab is built.
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.verified_outlined,
              context.l10n.t('profile.menu.validation'),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComingSoonScreen(
                    title: context.l10n.t('profile.menu.validation'),
                    message: context.l10n.t('soon.title'),
                  ),
                ),
              ),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.language_rounded,
              context.l10n.t('profile.menu.language'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.notifications_outlined,
              context.l10n.t('profile.menu.notifications'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.help_outline_rounded,
              context.l10n.t('profile.menu.help'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              ),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.info_outline_rounded,
              context.l10n.t('profile.menu.about'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // The session is cleared server-side by dropping the tokens, so
                // wait for storage to be wiped before leaving the screen.
                await provider.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: Text(
                context.l10n.t('profile.logout'),
                style: GoogleFonts.poppins(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppTheme.divider),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final user = provider.currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.t('profile.edit.title'),
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Text(context.l10n.t('profile.edit.name'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration:
                  InputDecoration(hintText: context.l10n.t('profile.edit.nameHint')),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.t('profile.edit.phone'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration:
                  InputDecoration(hintText: context.l10n.t('profile.edit.phoneHint')),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.t('profile.edit.address'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration:
                  InputDecoration(hintText: context.l10n.t('profile.edit.addressHint')),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final saved = await provider.updateProfile(
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved
                            ? ctx.l10n.t('profile.edit.saved')
                            : (provider.dataError ?? ctx.l10n.t('profile.edit.failed')),
                      ),
                      backgroundColor: saved ? AppTheme.success : AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(context.l10n.t('common.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Orders received across every shop the user owns.
  ///
  /// A seller needs the buyers who ordered from them, not the orders they
  /// placed themselves, so this lists [AppProvider.receivedOrders]: all the
  /// shops combined, newest first.
  void _showOrdersDialog(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(ctx.l10n.t('profile.orders.title'),
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Expanded(
              child: provider.orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 60, color: AppTheme.textHint),
                          const SizedBox(height: 12),
                          Text(ctx.l10n.t('profile.orders.empty'),
                              style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.receivedOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = provider.receivedOrders[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Same as the shop screen: no status chip, the app has no
                              // order-status logic to expose here.
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.buyerName.isEmpty
                                        ? ctx.l10n.t('shop.detail.orders.client')
                                        : order.buyerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  if (order.shopName.isNotEmpty)
                                    Text(
                                      order.shopName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              for (final item in order.items)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '• ${item.productName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.items.length} article(s) • ${formatPrice(order.totalAmount)}',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${order.date.day}/${order.date.month}/${order.date.year}',
                                style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
