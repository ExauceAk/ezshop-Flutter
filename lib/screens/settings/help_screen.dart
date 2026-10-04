import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// Support number the app points users to.
///
/// Hardcoded on purpose for now: it is a test line, and the real one is set
/// here directly in the code until a support address exists server-side.
const String supportWhatsAppNumber = '221770000000';

/// Help & support.
///
/// Everything a stuck user needs is a conversation, so the page does one thing:
/// open WhatsApp with the support line.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('help.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF25D366),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('help.subtitle'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openSupport,
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: Text(
                      l10n.t('help.cta'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l10n.t('help.hours'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSupport() async {
    final url = Uri.parse('https://wa.me/$supportWhatsAppNumber');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
