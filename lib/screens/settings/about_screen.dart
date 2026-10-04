import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// What EZ Shop is, in one screen.
///
/// The copy is part of the translation catalog: an English speaker reads the
/// same page in English rather than a French page they have to translate in
/// their head.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Shown in the footer; kept next to the screen so bumping the release means
  /// touching one place.
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = DateTime.now().year;

    final features = <String>[
      l10n.t('about.feature.shop'),
      l10n.t('about.feature.domain'),
      l10n.t('about.feature.products'),
      l10n.t('about.feature.negotiate'),
      l10n.t('about.feature.whatsapp'),
      l10n.t('about.feature.rate'),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('about.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  'EZ Shop',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('about.tagline'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.cardDecoration,
            child: Text(
              l10n.t('about.intro'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('about.features.title'),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                for (final feature in features)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.t('about.version', {'version': appVersion}),
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.t('about.rights', {'year': '$year'}),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
