import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  _buildProfileHeader(user?.name ?? 'Invité', user?.email ?? ''),
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

  Widget _buildProfileHeader(String name, String email) {
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
                'Mon Profil',
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
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.primary),
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

  Widget _buildSettingsList(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
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
              'Ma Boutique',
              () => Navigator.pushNamed(context, '/shop'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.shopping_bag_outlined,
              'Mes Commandes',
              () => _showOrdersDialog(context, provider),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.favorite_outline_rounded,
              'Mes Favoris',
              () {},
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.location_on_outlined,
              'Adresses de livraison',
              () {},
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.payment_outlined,
              'Moyens de paiement',
              () {},
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.notifications_outlined,
              'Notifications',
              () {},
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.help_outline_rounded,
              'Aide & Support',
              () {},
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.info_outline_rounded,
              'À propos',
              () {},
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
                'Se déconnecter',
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
            Text('Modifier le profil', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Text('Nom', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Votre nom'),
            ),
            const SizedBox(height: 16),
            Text('Téléphone', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+33 6 00 00 00 00'),
            ),
            const SizedBox(height: 16),
            Text('Adresse', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(hintText: 'Votre adresse'),
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
                            ? 'Profil mis à jour'
                            : (provider.dataError ?? 'Impossible d\'enregistrer'),
                      ),
                      backgroundColor: saved ? AppTheme.success : AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            Text('Mes Commandes', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Expanded(
              child: provider.orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 60, color: AppTheme.textHint),
                          const SizedBox(height: 12),
                          Text('Aucune commande', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];
                        final statusColors = {
                          'pending': AppTheme.warning,
                          'shipped': AppTheme.primary,
                          'delivered': AppTheme.success,
                          'cancelled': AppTheme.error,
                        };
                        final statusLabels = {
                          'pending': 'En attente',
                          'shipped': 'Expédiée',
                          'delivered': 'Livrée',
                          'cancelled': 'Annulée',
                        };
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Commande #${order.id.substring(order.id.length - 4)}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (statusColors[order.status] ?? AppTheme.warning).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusLabels[order.status] ?? order.status,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColors[order.status],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.items.length} article(s) • \$${order.totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13),
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
