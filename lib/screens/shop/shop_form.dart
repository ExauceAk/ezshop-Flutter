import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../l10n/app_strings.dart';
import '../../models/shop_theme.dart';
import '../../models/shop_theme_config.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_pick.dart';
import '../../utils/phone_countries.dart';
import '../../widgets/mini_theme_preview.dart';
import 'theme_preview_sheet.dart';

/// Everything the shop form collects.
class ShopFormData {
  const ShopFormData({
    this.name = '',
    this.description = '',
    this.whatsapp = '',
    this.countryCode = '221',
    this.heroTitle = '',
    this.heroSubtitle = '',
    this.aboutTitle = '',
    this.aboutText = '',
    this.slug = '',
    this.themeId = 'atelier',
    this.primaryColor = '',
    this.accentColor = '',
    this.backgroundColor = '',
    this.acceptsOnlinePayment = false,
    this.paymentFields = const ['', '', '', '', ''],
    this.logoFile,
    this.bannerFile,
  });

  final String name;
  final String description;

  /// National part of the number, entered by the seller.
  final String whatsapp;

  /// International prefix, kept apart so the seller does not have to type it.
  final String countryCode;

  final String heroTitle;
  final String heroSubtitle;
  final String aboutTitle;
  final String aboutText;
  final String slug;
  final String themeId;

  /// Optional custom seller palette overrides (`#RRGGBB`). Empty uses the
  /// chosen theme's native colours.
  final String primaryColor;
  final String accentColor;
  final String backgroundColor;

  /// Whether the seller filled in the advanced options.
  final bool acceptsOnlinePayment;

  /// The five optional detail fields of the advanced section.
  final List<String> paymentFields;

  /// Images picked during this session; null means "keep the existing one".
  final File? logoFile;
  final File? bannerFile;

  bool get hasCustomColors =>
      primaryColor.isNotEmpty ||
      accentColor.isNotEmpty ||
      backgroundColor.isNotEmpty;

  /// Builds the [ShopThemeConfig] payload for previews and API persistence.
  ShopThemeConfig get themeConfig => ShopThemeConfig(
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        heroTitle: heroTitle,
        heroSubtitle: heroSubtitle,
        aboutTitle: aboutTitle,
        aboutText: aboutText,
      );

  /// Digits of the WhatsApp number, prefix included, used to build the
  /// `wa.me` link and shown in the storefront footer.
  String get whatsappDigits {
    final national = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (national.isEmpty) return '';
    return '$countryCode$national';
  }

  String get whatsappLink =>
      whatsappDigits.isEmpty ? '' : 'https://wa.me/$whatsappDigits';

  ShopFormData copyWith({
    String? name,
    String? description,
    String? whatsapp,
    String? countryCode,
    String? heroTitle,
    String? heroSubtitle,
    String? aboutTitle,
    String? aboutText,
    String? slug,
    String? themeId,
    String? primaryColor,
    String? accentColor,
    String? backgroundColor,
    bool? acceptsOnlinePayment,
    List<String>? paymentFields,
    File? logoFile,
    File? bannerFile,
  }) {
    return ShopFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      whatsapp: whatsapp ?? this.whatsapp,
      countryCode: countryCode ?? this.countryCode,
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutText: aboutText ?? this.aboutText,
      slug: slug ?? this.slug,
      themeId: themeId ?? this.themeId,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      acceptsOnlinePayment: acceptsOnlinePayment ?? this.acceptsOnlinePayment,
      paymentFields: paymentFields ?? this.paymentFields,
      logoFile: logoFile ?? this.logoFile,
      bannerFile: bannerFile ?? this.bannerFile,
    );
  }

  /// Resets custom colours back to the theme's native defaults.
  ShopFormData clearColors() {
    return copyWith(
      primaryColor: '',
      accentColor: '',
      backgroundColor: '',
    );
  }

  /// Converts a display name into a valid subdomain slug (lowercase ASCII with
  /// single hyphens), matching the backend's `slugify`.
  static String slugify(String value) {
    const diacritics = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'æ': 'ae',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'œ': 'oe',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
    };
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(diacritics[char] ?? char);
    }
    var slug = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 60) {
      slug = slug.substring(0, 60).replaceAll(RegExp(r'-+$'), '');
    }
    return slug;
  }
}

/// The shop form, shared by the creation and the edit screen.
class ShopForm extends StatefulWidget {
  const ShopForm({
    super.key,
    required this.initial,
    required this.themes,
    required this.onChanged,
    required this.onPreview,
    this.existingLogo = '',
    this.existingBanner = '',
  });

  final ShopFormData initial;
  final List<ShopTheme> themes;

  /// Fired on every keystroke or colour/theme selection so the parent screen
  /// and preview stay in sync.
  final ValueChanged<ShopFormData> onChanged;

  final VoidCallback onPreview;

  /// Image already stored on the shop, shown until a new one is picked.
  final String existingLogo;
  final String existingBanner;

  @override
  State<ShopForm> createState() => _ShopFormState();
}

class _ShopFormState extends State<ShopForm> {
  late ShopFormData _data;

  /// True once the seller has already defined or manually edited the subdomain,
  /// so subsequent changes to the shop name no longer overwrite it.
  late bool _slugCustomised;

  late final TextEditingController _name;
  late final TextEditingController _whatsapp;
  late final TextEditingController _heroTitle;
  late final TextEditingController _heroSubtitle;
  late final TextEditingController _aboutTitle;
  late final TextEditingController _aboutText;
  late final TextEditingController _slug;
  late final List<TextEditingController> _payments;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    _slugCustomised = _data.slug.trim().isNotEmpty;
    _name = TextEditingController(text: _data.name);
    _whatsapp = TextEditingController(text: _data.whatsapp);
    _heroTitle = TextEditingController(text: _data.heroTitle);
    _heroSubtitle = TextEditingController(text: _data.heroSubtitle);
    _aboutTitle = TextEditingController(text: _data.aboutTitle);
    _aboutText = TextEditingController(text: _data.aboutText);
    _slug = TextEditingController(text: _data.slug);
    _payments = List.generate(
      _data.paymentFields.length,
      (index) => TextEditingController(text: _data.paymentFields[index]),
    );
  }

  @override
  void didUpdateWidget(covariant ShopForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initial.themeId != _data.themeId ||
        widget.initial.primaryColor != _data.primaryColor ||
        widget.initial.accentColor != _data.accentColor ||
        widget.initial.backgroundColor != _data.backgroundColor) {
      _data = _data.copyWith(
        themeId: widget.initial.themeId,
        primaryColor: widget.initial.primaryColor,
        accentColor: widget.initial.accentColor,
        backgroundColor: widget.initial.backgroundColor,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _whatsapp,
      _heroTitle,
      _heroSubtitle,
      _aboutTitle,
      _aboutText,
      _slug,
    ]) {
      controller.dispose();
    }
    for (final controller in _payments) {
      controller.dispose();
    }
    super.dispose();
  }

  ShopTheme get _currentTheme {
    return widget.themes.firstWhere(
      (theme) => theme.id == _data.themeId,
      orElse: () => widget.themes.first,
    );
  }

  ShopTheme get _activeTheme =>
      _currentTheme.applyCustomColors(_data.themeConfig);

  void _update(ShopFormData next) {
    setState(() => _data = next);
    widget.onChanged(next);
  }

  List<String> _replacePayment(int index, String value) {
    final next = List<String>.of(_data.paymentFields);
    while (next.length <= index) {
      next.add('');
    }
    next[index] = value;
    return next;
  }

  Future<void> _pick({required bool isLogo}) async {
    final l10n = context.l10n;
    final file = await pickAndCropImage(
      context,
      aspectRatio: isLogo ? 1 : 16 / 9,
      title: isLogo ? l10n.t('crop.logo') : l10n.t('crop.cover'),
    );
    if (file == null) return;
    _update(isLogo
        ? _data.copyWith(logoFile: file)
        : _data.copyWith(bannerFile: file));
  }

  Future<void> _pickColor({
    required String title,
    required Color current,
    required List<String> swatches,
    required ValueChanged<String> onSelected,
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
                    maxLength: 7,
                    decoration: InputDecoration(
                      labelText: ctx.l10n.t('preview.hexCode'),
                      hintText: '#176B55',
                      isDense: true,
                      counterText: '',
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
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(l10n.t('form.logo')),
          const SizedBox(height: 8),
          _ImageSlot(
            height: 92,
            width: 92,
            radius: 20,
            file: _data.logoFile,
            url: widget.existingLogo,
            onTap: () => _pick(isLogo: true),
          ),
          const SizedBox(height: 24),

          _field(_name, l10n.t('form.name'), lines: 1, maxLength: 20),
          _phoneField(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _domainField()),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onPreview,
                child: MiniThemePreview(
                  theme: _currentTheme,
                  config: _data.themeConfig,
                  width: 92,
                  height: 104,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _sectionTitle(l10n.t('form.coverSection')),
          _field(_heroTitle, l10n.t('form.heroTitle'), lines: 1, maxLength: 80),
          _field(
            _heroSubtitle,
            l10n.t('form.heroDescription'),
            hint: l10n.t('form.heroDescriptionHint'),
            lines: 3,
            maxLength: 1000,
          ),
          _label(l10n.t('form.coverImage')),
          const SizedBox(height: 8),
          _ImageSlot(
            height: 110,
            radius: 14,
            file: _data.bannerFile,
            url: widget.existingBanner,
            onTap: () => _pick(isLogo: false),
          ),
          const SizedBox(height: 28),

          _sectionTitle(l10n.t('form.aboutSection')),
          _field(_aboutTitle, l10n.t('form.aboutTitle'), lines: 1, maxLength: 80),
          _field(
            _aboutText,
            l10n.t('form.aboutText'),
            hint: l10n.t('form.aboutTextHint'),
            lines: 4,
            maxLength: 1000,
          ),
          const SizedBox(height: 8),

          _paymentSection(),
          const SizedBox(height: 24),

          // Custom brand colour section
          _colorSection(l10n),
          const SizedBox(height: 24),

          Row(
            children: [
              _label('${l10n.t('form.theme')} (${widget.themes.length})'),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.onPreview,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: Text(l10n.t('form.preview')),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.themes.length,
            itemBuilder: (context, index) {
              final theme = widget.themes[index];
              final isSelected = theme.id == _data.themeId;
              return _ThemeCard(
                theme: theme,
                config: isSelected ? _data.themeConfig : null,
                selected: isSelected,
                onTap: () => _update(_data.copyWith(themeId: theme.id)),
                onPreviewTap: () {
                  _update(_data.copyWith(themeId: theme.id));
                  widget.onPreview();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Brand colour customisation card with 3 colour channels, ready-made
  /// palettes, and a reset button.
  Widget _colorSection(AppStrings l10n) {
    final active = _activeTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.t('form.colors.section')),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _data.hasCustomColors ? active.primary : AppTheme.border,
              width: _data.hasCustomColors ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('form.colors.subtitle'),
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _colorPickerTile(
                      label: l10n.t('preview.colorPrimary'),
                      color: active.primary,
                      onTap: () => _pickColor(
                        title: l10n.t('preview.colorPrimary'),
                        current: active.primary,
                        swatches: kColorSwatchesPrimary,
                        onSelected: (hex) =>
                            _update(_data.copyWith(primaryColor: hex)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _colorPickerTile(
                      label: l10n.t('preview.colorAccent'),
                      color: active.accent,
                      onTap: () => _pickColor(
                        title: l10n.t('preview.colorAccent'),
                        current: active.accent,
                        swatches: kColorSwatchesAccent,
                        onSelected: (hex) =>
                            _update(_data.copyWith(accentColor: hex)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _colorPickerTile(
                      label: l10n.t('preview.colorBackground'),
                      color: active.background,
                      onTap: () => _pickColor(
                        title: l10n.t('preview.colorBackground'),
                        current: active.background,
                        swatches: kColorSwatchesBackground,
                        onSelected: (hex) =>
                            _update(_data.copyWith(backgroundColor: hex)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.t('form.colors.presets'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in kPalettePresets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _update(
                            _data.copyWith(
                              primaryColor: preset.primaryHex,
                              accentColor: preset.accentHex,
                              backgroundColor: preset.backgroundHex,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _dot(preset.primary),
                                const SizedBox(width: 3),
                                _dot(preset.accent),
                                const SizedBox(width: 3),
                                _dot(preset.background, border: true),
                                const SizedBox(width: 6),
                                Text(
                                  preset.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
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
              if (_data.hasCustomColors) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _update(_data.clearColors()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.t('form.colors.reset'),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _colorPickerTile({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              colorToHex(color),
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, {bool border = false}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.black26, width: 0.8) : null,
      ),
    );
  }

  Widget _paymentSection() {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.t('form.payment.section')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _data.acceptsOnlinePayment
                  ? AppTheme.primary
                  : AppTheme.border,
            ),
          ),
          child: CheckboxListTile(
            value: _data.acceptsOnlinePayment,
            onChanged: (value) =>
                _update(_data.copyWith(acceptsOnlinePayment: value ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primary,
            title: Text(
              l10n.t('form.payment.checkbox'),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ),
        if (_data.acceptsOnlinePayment) ...[
          const SizedBox(height: 16),
          for (var i = 0; i < _payments.length; i++)
            _field(
              _payments[i],
              l10n.t('form.payment.field${i + 1}'),
              hint: l10n.t('form.payment.hint'),
              lines: 1,
              maxLength: 100,
              fieldIndex: i,
            ),
        ],
      ],
    );
  }

  Widget _domainField() {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _slug,
        maxLines: 1,
        maxLength: 30,
        decoration: InputDecoration(
          labelText: l10n.t('form.domain'),
          hintText: l10n.t('form.domainHint'),
          suffixText: AppConfig.shopSuffix,
          suffixStyle: const TextStyle(
              color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          helperText: l10n.t('form.domainHelper', {
            'domain':
                _slug.text.isEmpty ? l10n.t('form.domainHint') : _slug.text,
            'appDomain': AppConfig.shopDomain,
          }),
          helperMaxLines: 2,
        ),
        onChanged: (value) {
          _slugCustomised = true;
          _update(_data.copyWith(slug: value));
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    int? maxLength,
    String? hint,
    String? helper,
    TextInputType? keyboard,
    int? fieldIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        maxLength: maxLength,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          helperMaxLines: 2,
          alignLabelWithHint: lines > 1,
        ),
        onChanged: (value) {
          if (controller == _name) {
            String? nextSlug;
            if (!_slugCustomised) {
              nextSlug = ShopFormData.slugify(value);
              _slug.value = TextEditingValue(
                text: nextSlug,
                selection: TextSelection.collapsed(offset: nextSlug.length),
              );
            }
            _update(_data.copyWith(name: value, slug: nextSlug));
            return;
          }
          _update(_data.copyWith(
            slug: controller == _slug ? value : null,
            heroTitle: controller == _heroTitle ? value : null,
            heroSubtitle: controller == _heroSubtitle ? value : null,
            aboutTitle: controller == _aboutTitle ? value : null,
            aboutText: controller == _aboutText ? value : null,
            paymentFields:
                fieldIndex == null ? null : _replacePayment(fieldIndex, value),
          ));
        },
      ),
    );
  }

  Widget _phoneField() {
    final l10n = context.l10n;
    final country = findPhoneCountryByDialCode(_data.countryCode);
    final isPhoneValid = isNationalPhoneValid(country, _whatsapp.text);
    const warningOrange = Color(0xFFF59E0B);

    final warningBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: warningOrange, width: 1.8),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showPhoneCountryPicker(
                    context,
                    selected: country,
                  );
                  if (picked != null) {
                    _update(_data.copyWith(countryCode: picked.dialCode));
                  }
                },
                child: Container(
                  width: 122,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPhoneValid ? AppTheme.border : warningOrange,
                      width: isPhoneValid ? 1 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          country.isoCode,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '+${country.dialCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _whatsapp,
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                  style: GoogleFonts.poppins(
                    color: isPhoneValid ? AppTheme.textPrimary : warningOrange,
                    fontWeight:
                        isPhoneValid ? FontWeight.w400 : FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.t('form.whatsapp'),
                    counterText: '',
                    enabledBorder: isPhoneValid ? null : warningBorder,
                    focusedBorder: isPhoneValid ? null : warningBorder,
                    suffixIcon: isPhoneValid
                        ? null
                        : const Icon(
                            Icons.warning_amber_rounded,
                            color: warningOrange,
                            size: 20,
                          ),
                  ),
                  onChanged: (value) => _update(_data.copyWith(whatsapp: value)),
                ),
              ),
            ],
          ),
          if (!isPhoneValid) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: warningOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.t('form.whatsappInvalid', {
                      'country': country.localizedName(l10n.language),
                      'expected': country.expectedDigitsLabel,
                    }),
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: warningOrange,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot({
    required this.height,
    required this.radius,
    required this.file,
    required this.onTap,
    this.url = '',
    this.width,
  });

  final double height;
  final double? width;
  final double radius;
  final File? file;
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: file != null ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: file != null
            ? Image.file(
                file!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            : url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => const _Placeholder(),
                  )
                : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.camera_alt_rounded, color: AppTheme.textHint, size: 24),
        const SizedBox(height: 4),
        Text(
          context.l10n.t('form.choose'),
          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    this.config,
    required this.selected,
    required this.onTap,
    required this.onPreviewTap,
  });

  final ShopTheme theme;
  final ShopThemeConfig? config;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onPreviewTap;

  @override
  Widget build(BuildContext context) {
    final active = theme.applyCustomColors(config);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? active.primaryColor : AppTheme.border,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: MiniThemePreview(
                      theme: theme,
                      config: config,
                      width: 102,
                      height: 92,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onPreviewTap,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: selected
                              ? active.primaryColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    theme.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              theme.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: active.primaryColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              theme.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                height: 1.25,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
