import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

/// Language picker.
///
/// Only the wording of the interface changes: products, shops and profiles keep
/// the language of their author, because translating them would mean writing
/// content nobody wrote. New languages are added from [AppLanguage] without
/// touching this screen.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('language.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.t('language.subtitle'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                for (var index = 0;
                    index < AppLanguage.values.length;
                    index++) ...[
                  if (index > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: AppTheme.divider),
                    ),
                  _buildLanguageTile(context, AppLanguage.values[index]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppLanguage language) {
    final l10n = context.l10n;
    final provider = context.read<AppProvider>();
    final selected = provider.language == language;

    return ListTile(
      onTap: () async {
        await provider.setLanguage(language);
        if (!context.mounted) return;

        // The sheet is rebuilt by the new language, so the confirmation reads
        // in the language that was just picked.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n.t('language.applied', {'language': language.nativeName}),
                style: GoogleFonts.poppins(),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          language.name.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
      title: Text(
        language.nativeName,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: selected
          ? Text(
              l10n.t('language.current'),
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint),
            )
          : null,
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
          : const Icon(Icons.circle_outlined, color: AppTheme.textHint, size: 22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
