import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_config.dart';
import '../../models/shop_theme.dart';
import '../../theme/app_theme.dart';

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
  final ImagePicker _picker = ImagePicker();

  /// Prefixes offered for the phone number.
  static const _countryCodes = ['221', '225', '223', '226', '237', '33', '1'];

  late final TextEditingController _name;
  late final TextEditingController _whatsapp;
  late final TextEditingController _heroTitle;
  late final TextEditingController _heroSubtitle;
  late final TextEditingController _aboutTitle;
  late final TextEditingController _aboutText;
  late final TextEditingController _slug;

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
    super.dispose();
  }

  void _update(ShopFormData next) {
    setState(() => _data = next);
    widget.onChanged(next);
  }

  Future<void> _pick({required bool isLogo}) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (image == null) return;
    final file = File(image.path);
    _update(isLogo
        ? _data.copyWith(logoFile: file)
        : _data.copyWith(bannerFile: file));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Logo'),
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

          _field(_name, 'Nom de la boutique', lines: 1),
          _phoneField(),
          _field(
            _slug,
            'Nom de domaine',
            hint: 'maboutique',
            helper: 'Votre boutique sera visible sur '
                '${_slug.text.isEmpty ? 'maboutique' : _slug.text}.${AppConfig.shopDomain}',
          ),
          const SizedBox(height: 12),

          _sectionTitle('Section de couverture'),
          _field(_heroTitle, 'Titre principal', lines: 1),
          _field(
            _heroSubtitle,
            'Description',
            hint: 'Ce que vous vendez, en une phrase',
            lines: 3,
          ),
          _label('Image de couverture'),
          const SizedBox(height: 8),
          _ImageSlot(
            height: 110,
            radius: 14,
            file: _data.bannerFile,
            url: widget.existingBanner,
            onTap: () => _pick(isLogo: false),
          ),
          const SizedBox(height: 28),

          _sectionTitle('Section à propos'),
          _field(_aboutTitle, 'Titre', lines: 1),
          _field(
            _aboutText,
            'Texte',
            hint: 'Votre histoire, votre savoir-faire',
            lines: 4,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _label('Thème'),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.onPreview,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('Aperçu'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.themes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final theme = widget.themes[index];
                return _ThemeCard(
                  theme: theme,
                  selected: theme.id == _data.themeId,
                  onTap: () => _update(_data.copyWith(themeId: theme.id)),
                );
              },
            ),
          ),
        ],
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
              decoration: const InputDecoration(
                labelText: 'Numéro WhatsApp',
                hintText: '77 000 00 00',
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
          'Choisir',
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
        width: 140,
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
            Row(
              children: List.generate(
                theme.swatch.length,
                (index) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.colorAt(index),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
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