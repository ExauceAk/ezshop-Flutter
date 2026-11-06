import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_strings.dart';
import '../../models/shop_theme.dart';
import '../../models/shop_theme_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/storefront_preview.dart';

/// Swatch options offered in the colour picker modal for primary, accent and
/// background channels.
const List<String> kColorSwatchesPrimary = [
  '#176B55',
  '#0F172A',
  '#2563EB',
  '#0891B2',
  '#4F46E5',
  '#7C2D12',
  '#9A3412',
  '#B45309',
  '#C2410C',
  '#E11D48',
  '#BE123C',
  '#16A34A',
  '#0F766E',
  '#D4AF37',
  '#06B6D4',
  '#57412F',
];

const List<String> kColorSwatchesAccent = [
  '#D6A85F',
  '#F59E0B',
  '#3B82F6',
  '#10B981',
  '#EC4899',
  '#2DD4BF',
  '#FACC15',
  '#EF4444',
  '#CA8A04',
  '#06B6D4',
  '#C5A059',
  '#B91C1C',
];

const List<String> kColorSwatchesBackground = [
  '#FFFFFF',
  '#F7F5EF',
  '#FAF8F5',
  '#FDF8F3',
  '#F5EFE6',
  '#F8FAFC',
  '#F1F5F9',
  '#F0FDFA',
  '#F5F7FF',
  '#18181B',
  '#0F172A',
  '#090A0F',
];

/// Opens a full-height sheet showing an interactive preview of a storefront
/// theme, complete with a live colour customisation bar and reset button (like
/// `/preview/[theme]` on the web).
void showThemePreview(
  BuildContext context, {
  required ShopTheme theme,
  required String name,
  required String description,
  required VoidCallback onSelect,
  String slug = '',
  String logoUrl = '',
  String bannerUrl = '',
  File? logoFile,
  File? bannerFile,
  ShopThemeConfig config = const ShopThemeConfig(),
  ValueChanged<ShopThemeConfig>? onConfigChanged,
  ValueChanged<ShopTheme>? onThemeChanged,
  String actionLabel = '',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      builder: (context, scrollController) => _ThemePreviewSheet(
        initialTheme: theme,
        name: name,
        description: description,
        slug: slug,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        logoFile: logoFile,
        bannerFile: bannerFile,
        initialConfig: config,
        onConfigChanged: onConfigChanged,
        onThemeChanged: onThemeChanged,
        actionLabel: actionLabel,
        onSelect: onSelect,
        scrollController: scrollController,
      ),
    ),
  );
}

class _ThemePreviewSheet extends StatefulWidget {
  const _ThemePreviewSheet({
    required this.initialTheme,
    required this.name,
    required this.description,
    required this.slug,
    required this.logoUrl,
    required this.bannerUrl,
    this.logoFile,
    this.bannerFile,
    required this.initialConfig,
    this.onConfigChanged,
    this.onThemeChanged,
    required this.actionLabel,
    required this.onSelect,
    required this.scrollController,
  });

  final ShopTheme initialTheme;
  final String name;
  final String description;
  final String slug;
  final String logoUrl;
  final String bannerUrl;
  final File? logoFile;
  final File? bannerFile;
  final ShopThemeConfig initialConfig;
  final ValueChanged<ShopThemeConfig>? onConfigChanged;
  final ValueChanged<ShopTheme>? onThemeChanged;
  final String actionLabel;
  final VoidCallback onSelect;
  final ScrollController scrollController;

  @override
  State<_ThemePreviewSheet> createState() => _ThemePreviewSheetState();
}

class _ThemePreviewSheetState extends State<_ThemePreviewSheet> {
  late ShopTheme _theme;
  late ShopThemeConfig _config;
  bool _showColorBar = false;

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme;
    _config = widget.initialConfig;
  }

  void _updateConfig(ShopThemeConfig next) {
    setState(() => _config = next);
    widget.onConfigChanged?.call(next);
  }

  void _switchTheme(int delta) {
    final idx = storefrontThemes.indexWhere((t) => t.id == _theme.id);
    if (idx == -1) return;
    final nextIdx =
        (idx + delta + storefrontThemes.length) % storefrontThemes.length;
    final nextTheme = storefrontThemes[nextIdx];
    setState(() => _theme = nextTheme);
    widget.onThemeChanged?.call(nextTheme);
  }

  Future<void> _pickColorChannel({
    required String title,
    required Color current,
    required List<String> swatches,
    required ValueChanged<String> onPicked,
  }) async {
    final controller = TextEditingController(text: colorToHex(current));
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in swatches)
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, hex),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: parseHexColor(hex) ?? Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorToHex(current).toUpperCase() ==
                                  hex.toUpperCase()
                              ? AppTheme.primary
                              : Colors.black12,
                          width: colorToHex(current).toUpperCase() ==
                                  hex.toUpperCase()
                              ? 2.5
                              : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Code Hex (#RRGGBB)',
                      hintText: '#176B55',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final parsed = parseHexColor(controller.text);
                    if (parsed != null) {
                      Navigator.pop(ctx, colorToHex(parsed));
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = _theme.applyCustomColors(_config);
    final themeIndex = storefrontThemes.indexWhere((t) => t.id == _theme.id);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Top toolbar: theme switcher + palette button + apply CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Thème précédent',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _switchTheme(-1),
                  icon: const Icon(Icons.chevron_left_rounded, size: 22),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _theme.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: active.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${themeIndex + 1}/${storefrontThemes.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _theme.signature,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Thème suivant',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _switchTheme(1),
                  icon: const Icon(Icons.chevron_right_rounded, size: 22),
                ),
                // Palette toggle button
                GestureDetector(
                  onTap: () => setState(() => _showColorBar = !_showColorBar),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: _config.hasCustomColors || _showColorBar
                          ? active.primary.withValues(alpha: 0.12)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _config.hasCustomColors || _showColorBar
                            ? active.primary
                            : Colors.black12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _colorDot(active.primary),
                        const SizedBox(width: 3),
                        _colorDot(active.accent),
                        const SizedBox(width: 3),
                        _colorDot(active.background, border: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSelect();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: active.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.actionLabel.isEmpty
                        ? l10n.t('preview.apply')
                        : widget.actionLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Collapsible live colour customisation bar (mirrors /preview/[theme] on web)
          if (_showColorBar)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _channelChip(
                        label: l10n.t('preview.colorPrimary'),
                        color: active.primary,
                        onTap: () => _pickColorChannel(
                          title: l10n.t('preview.colorPrimary'),
                          current: active.primary,
                          swatches: kColorSwatchesPrimary,
                          onPicked: (hex) => _updateConfig(
                            _config.copyWith(primaryColor: hex),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _channelChip(
                        label: l10n.t('preview.colorAccent'),
                        color: active.accent,
                        onTap: () => _pickColorChannel(
                          title: l10n.t('preview.colorAccent'),
                          current: active.accent,
                          swatches: kColorSwatchesAccent,
                          onPicked: (hex) => _updateConfig(
                            _config.copyWith(accentColor: hex),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _channelChip(
                        label: l10n.t('preview.colorBackground'),
                        color: active.background,
                        onTap: () => _pickColorChannel(
                          title: l10n.t('preview.colorBackground'),
                          current: active.background,
                          swatches: kColorSwatchesBackground,
                          onPicked: (hex) => _updateConfig(
                            _config.copyWith(backgroundColor: hex),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_config.hasCustomColors)
                        TextButton(
                          onPressed: () => _updateConfig(_config.clearColors()),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.t('preview.resetColors'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final preset in kPalettePresets)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => _updateConfig(
                                _config.copyWith(
                                  primaryColor: preset.primaryHex,
                                  accentColor: preset.accentHex,
                                  backgroundColor: preset.backgroundHex,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _colorDot(preset.primary),
                                    const SizedBox(width: 2),
                                    _colorDot(preset.accent),
                                    const SizedBox(width: 2),
                                    _colorDot(preset.background, border: true),
                                    const SizedBox(width: 5),
                                    Text(
                                      preset.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            const Divider(height: 1),

          Expanded(
            child: StorefrontPreview(
              theme: _theme,
              name: widget.name,
              description: widget.description,
              slug: widget.slug,
              logoUrl: widget.logoUrl,
              bannerUrl: widget.bannerUrl,
              logoFile: widget.logoFile,
              bannerFile: widget.bannerFile,
              config: _config,
              scrollController: widget.scrollController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color, {bool border = false}) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.black26, width: 0.8) : null,
      ),
    );
  }

  Widget _channelChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _colorDot(color, border: true),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
