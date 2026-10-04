import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';
import 'delete_account_screen.dart';

/// Support address, the same one printed on the public policy page.
///
/// Kept in one place so the page and the app never disagree on where a user
/// should write.
const String supportEmail = 'olneon.help@gmail.com';

/// Privacy and account deletion.
///
/// The policy lives on the web because it is public and must be readable
/// without an account, but a user asking "how do I get out?" is inside the app
/// and should not have to leave it to find out. This screen is that answer:
/// the full policy opens in the browser, and the deletion is one tap away.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  /// Public policy page, on the storefront's apex domain.
  static Uri get policyUrl {
    final uri = Uri.parse(AppConfig.webUrl);
    return uri.replace(path: '/privacy');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('privacy.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            icon: Icons.shield_outlined,
            color: AppTheme.primary,
            title: l10n.t('privacy.title'),
            subtitle: l10n.t('privacy.subtitle'),
            onTap: () => launchUrl(policyUrl, mode: LaunchMode.externalApplication),
            trailingLabel: l10n.t('privacy.openWeb'),
          ),
          const SizedBox(height: 14),
          _card(
            icon: Icons.person_remove_outlined,
            color: AppTheme.error,
            title: l10n.t('delete.title'),
            subtitle: l10n.t('delete.warningBody'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('privacy.support'),
            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textHint),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => launchUrl(
              Uri.parse('mailto:$supportEmail'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              supportEmail,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.45,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        trailing: trailingLabel == null
            ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint)
            : Text(
                trailingLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
      ),
    );
  }
}