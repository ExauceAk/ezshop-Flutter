import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/shop_theme.dart';
import '../../models/shop_theme_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/storefront_preview.dart';

/// Opens a full-height sheet showing a preview of a storefront theme.
///
/// The preview is rendered by [StorefrontPreview], inside the app: a seller
/// chooses a theme while filling the creation form, before anything is saved,
/// so it must not depend on the storefront server being up.
void showThemePreview(
  BuildContext context, {
  required ShopTheme theme,
  required String name,
  required String description,
  required VoidCallback onSelect,
  String slug = '',
  String logoUrl = '',
  String bannerUrl = '',
  ShopThemeConfig config = const ShopThemeConfig(),
  String actionLabel = 'Utiliser ce thème',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _ThemePreviewSheet(
        theme: theme,
        name: name,
        description: description,
        slug: slug,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        config: config,
        actionLabel: actionLabel,
        onSelect: onSelect,
        scrollController: scrollController,
      ),
    ),
  );
}

class _ThemePreviewSheet extends StatelessWidget {
  const _ThemePreviewSheet({
    required this.theme,
    required this.name,
    required this.description,
    required this.slug,
    required this.logoUrl,
    required this.bannerUrl,
    required this.config,
    required this.actionLabel,
    required this.onSelect,
    required this.scrollController,
  });

  final ShopTheme theme;
  final String name;
  final String description;
  final String slug;
  final String logoUrl;
  final String bannerUrl;
  final ShopThemeConfig config;
  final String actionLabel;
  final VoidCallback onSelect;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thème ${theme.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        theme.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelect();
                  },
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StorefrontPreview(
              theme: theme,
              name: name.trim().isEmpty ? 'Votre Boutique' : name.trim(),
              description: description.trim().isEmpty
                  ? 'Description de la boutique'
                  : description.trim(),
              slug: slug,
              logoUrl: logoUrl,
              bannerUrl: bannerUrl,
              config: config,
            ),
          ),
        ],
      ),
    );
  }
}