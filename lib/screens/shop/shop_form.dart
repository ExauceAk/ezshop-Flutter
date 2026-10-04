import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../l10n/app_strings.dart';
import '../../models/shop_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_pick.dart';
import '../../widgets/mini_theme_preview.dart';

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

  /// Whether the seller filled in the advanced options.
  ///
  /// Off by default: most sellers only negotiate on WhatsApp, and the extra
  /// fields must not appear before the seller asks for them.
  final bool acceptsOnlinePayment;

  /// The five optional detail fields of the advanced section.
  ///
  /// Their meaning and where they are stored are still to be decided, so
  /// nothing is sent to the API yet.
  final List<String> paymentFields;

  /// Images picked during this session; null means "keep the existing one".
  final File? logoFile;
  final File? bannerFile;

  /// Digits of the WhatsApp number, prefix included, used to build the
  /// `wa.me` link and shown in the storefront footer.
  ///
  /// The seller types a number, not a link: the link is derived from it.
  String get whatsappDigits =>
      '$countryCode${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}';

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
      acceptsOnlinePayment: acceptsOnlinePayment ?? this.acceptsOnlinePayment,
      paymentFields: paymentFields ?? this.paymentFields,
      logoFile: logoFile ?? this.logoFile,
      bannerFile: bannerFile ?? this.bannerFile,
    );
  }
}

/// The shop form, shared by the creation and the edit screen.
///
/// Both screens used to carry their own copy of these fields, which is how they
/// drifted apart. One widget also means one place to decide what the seller is
/// asked, and in what order.
///
/// Field order follows the storefront: identity first, then the hero, then the
/// about section, and the theme choice last because it is the only decision
/// that needs the preview to make sense.
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

  /// Fired on every keystroke so a preview can reflect what is being typed.
  final ValueChanged<ShopFormData> onChanged;

  final VoidCallback onPreview;

  /// Image already stored on the shop, shown until a new one is picked.
  ///
  /// Without this the slot looks empty while editing, which reads as if the
  /// shop had no logo.
  final String existingLogo;
  final String existingBanner;

  @override
  State<ShopForm> createState() => _ShopFormState();
}

class _ShopFormState extends State<ShopForm> {
  late ShopFormData _data;

  /// Prefixes offered for the phone number.
  static const _countryCodes = ['221', '225', '223', '226', '237', '33', '1'];

  late final TextEditingController _name;
  late final TextEditingController _whatsapp;
  late final TextEditingController _heroTitle;
  late final TextEditingController _heroSubtitle;
  late final TextEditingController _aboutTitle;
  late final TextEditingController _aboutText;
  late final TextEditingController _slug;

  /// One controller per advanced field, so the five inputs keep their own text
  /// while the section is hidden.
  late final List<TextEditingController> _payments;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
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

  /// The theme currently picked in the grid.
  ///
  /// Falls back to the first catalog theme so the domain row always has
  /// something to draw, even if the stored theme id is unknown.
  ShopTheme get _currentTheme {
    return widget.themes.firstWhere(
      (theme) => theme.id == _data.themeId,
      orElse: () => widget.themes.first,
    );
  }

  void _update(ShopFormData next) {
    setState(() => _data = next);
    widget.onChanged(next);
  }

  /// Returns the advanced fields with [index] set to [value].
  ///
  /// The list is rebuilt rather than mutated so [ShopFormData] stays a value
  /// type and `copyWith` can tell "unchanged" from "cleared".
  List<String> _replacePayment(int index, String value) {
    final next = List<String>.of(_data.paymentFields);
    while (next.length <= index) {
      next.add('');
    }
    next[index] = value;
    return next;
  }

  /// Picks an image and frames it before it is stored.
  ///
  /// The logo is cropped square because the storefront shows it in a circle,
  /// and the banner is cropped wide because it fills the hero; an uncropped
  /// photo is stretched to fit and loses whatever the seller wanted to show.
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

          _field(_name, l10n.t('form.name'), lines: 1),
          _phoneField(),
          // Domain and theme preview share a row: the subdomain is what the
          // storefront will answer on, and the preview next to it shows what
          // that storefront will look like.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _domainField()),
              const SizedBox(width: 12),
              MiniThemePreview(theme: _currentTheme, width: 92, height: 104),
            ],
          ),
          const SizedBox(height: 12),

          _sectionTitle(l10n.t('form.coverSection')),
          _field(_heroTitle, l10n.t('form.heroTitle'), lines: 1),
          _field(
            _heroSubtitle,
            l10n.t('form.heroDescription'),
            hint: l10n.t('form.heroDescriptionHint'),
            lines: 3,
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
          _field(_aboutTitle, l10n.t('form.aboutTitle'), lines: 1),
          _field(
            _aboutText,
            l10n.t('form.aboutText'),
            hint: l10n.t('form.aboutTextHint'),
            lines: 4,
          ),
          const SizedBox(height: 8),

          _paymentSection(),
          const SizedBox(height: 20),

          Row(
            children: [
              _label(l10n.t('form.theme')),
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
          // Vertical grid: the catalog now holds fifteen themes, and a single
          // horizontal strip hid ten of them behind a swipe nobody makes.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.themes.length + lockedStorefrontThemes.length,
            itemBuilder: (context, index) {
              if (index < widget.themes.length) {
                final theme = widget.themes[index];
                return _ThemeCard(
                  theme: theme,
                  selected: theme.id == _data.themeId,
                  onTap: () => _update(_data.copyWith(themeId: theme.id)),
                );
              }
              final locked = lockedStorefrontThemes[index - widget.themes.length];
              return _LockedThemeCard(
                theme: locked,
                onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.t('theme.comingSoon', {'name': locked.name}),
                        style: GoogleFonts.poppins(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Optional details, hidden until the seller opts in.
  ///
  /// This is an advanced section, not a payment promise: the fields are place
  /// holders whose meaning is still undecided, so it stays collapsed by default
  /// and a shop that only sells on WhatsApp is never asked about it.
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
          // All five fields, numbered as they will appear on the storefront.
          for (var i = 0; i < _payments.length; i++)
            _field(
              _payments[i],
              l10n.t('form.payment.field${i + 1}'),
              hint: l10n.t('form.payment.hint'),
              lines: 1,
              fieldIndex: i,
            ),
        ],
      ],
    );
  }

  /// Subdomain entry, with the fixed platform suffix on the same line.
  ///
  /// The seller only ever types the part they choose, so the suffix is shown
  /// inline instead of asking them to remember it; the helper underneath still
  /// spells out the full address that will actually open.
  Widget _domainField() {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _slug,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: l10n.t('form.domain'),
          hintText: l10n.t('form.domainHint'),
          suffixText: AppConfig.shopSuffix,
          suffixStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          helperText: l10n.t('form.domainHelper', {
            'domain': _slug.text.isEmpty ? l10n.t('form.domainHint') : _slug.text,
            'appDomain': AppConfig.shopDomain,
          }),
          helperMaxLines: 2,
        ),
        onChanged: (value) => _update(_data.copyWith(slug: value)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
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
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          helperMaxLines: 2,
          alignLabelWithHint: lines > 1,
        ),
        onChanged: (value) => _update(_data.copyWith(
              name: controller == _name ? value : null,
              slug: controller == _slug ? value : null,
              heroTitle: controller == _heroTitle ? value : null,
              heroSubtitle: controller == _heroSubtitle ? value : null,
              aboutTitle: controller == _aboutTitle ? value : null,
              aboutText: controller == _aboutText ? value : null,
              paymentFields: fieldIndex == null
                  ? null
                  : _replacePayment(fieldIndex, value),
            )),
      ),
    );
  }

  /// Phone entry with a country prefix.
  ///
  /// Sellers type their national number and pick the prefix, instead of
  /// typing "+221 77..." every time; both parts end up in one stored number.
  Widget _phoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _countryCodes.contains(_data.countryCode)
                    ? _data.countryCode
                    : _countryCodes.first,
                items: [
                  for (final code in _countryCodes)
                    DropdownMenuItem(
                      value: code,
                      child: Text('+$code',
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _update(_data.copyWith(countryCode: value));
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.l10n.t('form.whatsapp'),
                hintText: context.l10n.t('form.whatsappHint'),
              ),
              onChanged: (value) =>
                  _update(_data.copyWith(whatsapp: value)),
            ),
          ),
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

  /// Groups a part of the storefront, so the seller knows where the text will
  /// end up instead of guessing.
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

/// Image picker slot.
///
/// Shows the file picked in this session, or the image already stored on the
/// shop, so editing a shop never blanks its logo by omission.
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

  /// Image already stored server-side, used until a new one is picked.
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
            ? Image.file(file!, fit: BoxFit.cover)
            : url.isNotEmpty
                // The image already saved on the shop, so editing does not
                // pretend the shop has no logo.
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
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
    required this.selected,
    required this.onTap,
  });

  final ShopTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.primaryColor : AppTheme.border,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real miniature instead of colour dots: the dots were identical
            // from one theme to the next, so the card said nothing about the
            // hero shape or product layout the seller is actually choosing.
            Expanded(
              child: Center(
                child: MiniThemePreview(theme: theme, width: 86, height: 86),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              theme.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.3,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// A theme that is announced but not built yet.
///
/// Greyed out, without palette or preview image, so nothing about it can be
/// mistaken for a theme the storefront already renders. Tapping only says when
/// it is coming.
class _LockedThemeCard extends StatelessWidget {
  const _LockedThemeCard({required this.theme, required this.onTap});

  final LockedShopTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppTheme.textHint,
                ),
              ),
            ),
            const Spacer(),
            Text(
              theme.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.t('theme.locked'),
              style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
