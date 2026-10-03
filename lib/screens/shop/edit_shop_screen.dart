import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/shop_model.dart';
import '../../models/shop_theme.dart';
import '../../models/shop_theme_config.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import 'theme_preview_sheet.dart';

/// Lets a seller revisit an existing shop: swap the theme, replace the logo or
/// the banner, and reword every storefront text.
class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key, required this.shop});

  final Shop shop;

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _heroEyebrowController;
  late final TextEditingController _heroTitleController;
  late final TextEditingController _heroSubtitleController;
  late final TextEditingController _aboutTitleController;
  late final TextEditingController _aboutTextController;
  late final TextEditingController _footerTextController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;

  late String _selectedThemeId;
  late ShopThemeConfig _themeConfig;

  File? _logoFile;
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final shop = widget.shop;

    _nameController = TextEditingController(text: shop.name);
    _descController = TextEditingController(text: shop.description);
    _whatsappController =
        TextEditingController(text: _phoneFromWhatsapp(shop.whatsappLink));

    _themeConfig = shop.themeConfig;
    _selectedThemeId = shop.theme;

    _heroEyebrowController =
        TextEditingController(text: _themeConfig.heroEyebrow);
    _heroTitleController = TextEditingController(text: _themeConfig.heroTitle);
    _heroSubtitleController =
        TextEditingController(text: _themeConfig.heroSubtitle);
    _aboutTitleController =
        TextEditingController(text: _themeConfig.aboutTitle);
    _aboutTextController = TextEditingController(text: _themeConfig.aboutText);
    _footerTextController =
        TextEditingController(text: _themeConfig.footerText);
    _contactEmailController =
        TextEditingController(text: _themeConfig.contactEmail);
    _contactPhoneController =
        TextEditingController(text: _themeConfig.contactPhone);
  }

  /// `https://wa.me/212600000001` becomes `212600000001` so the field shows
  /// something the seller recognises.
  static String _phoneFromWhatsapp(String link) {
    if (link.isEmpty) return '';
    return link.replaceFirst(RegExp(r'^https?://wa\.me/'), '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _whatsappController.dispose();
    _heroEyebrowController.dispose();
    _heroTitleController.dispose();
    _heroSubtitleController.dispose();
    _aboutTitleController.dispose();
    _aboutTextController.dispose();
    _footerTextController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) setState(() => _logoFile = File(image.path));
  }

  Future<void> _pickBanner() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 900,
    );
    if (image != null) setState(() => _bannerFile = File(image.path));
  }

  void _openPreview(List<ShopTheme> themes) {
    final theme = themes.firstWhere(
      (t) => t.id == _selectedThemeId,
      orElse: () => themes.first,
    );

    showThemePreview(
      context,
      theme: theme,
      name: _nameController.text,
      description: _descController.text,
      slug: widget.shop.subdomain,
      config: _currentConfig,
      actionLabel: 'Appliquer ce thème',
      onSelect: () {
        setState(() => _selectedThemeId = theme.id);
        Navigator.pop(context);
      },
    );
  }

  ShopThemeConfig get _currentConfig => ShopThemeConfig(
        heroEyebrow: _heroEyebrowController.text.trim(),
        heroTitle: _heroTitleController.text.trim(),
        heroSubtitle: _heroSubtitleController.text.trim(),
        aboutTitle: _aboutTitleController.text.trim(),
        aboutText: _aboutTextController.text.trim(),
        footerText: _footerTextController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        heroImageUrl: _themeConfig.heroImageUrl,
        heroCtaLabel: _themeConfig.heroCtaLabel,
        contactAddress: _themeConfig.contactAddress,
      );

  /// Sends one picked image and returns the URL to store.
  ///
  /// Returns null when the upload failed, after showing why, so the save is
  /// not attempted with a dead URL.
  Future<String?> _upload(AppProvider provider, File? file) async {
    if (file == null) return '';

    final url = await provider.uploadImage(file, folder: 'shops');
    if (url != null) return url;

    if (!mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.dataError ?? "L'image n'a pas pu être envoyée"),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return null;
  }

  void _handleSave() async {
    final provider = context.read<AppProvider>();
    final phone = _whatsappController.text.trim();

    // A newly picked image is sent first; leaving the fields empty keeps the
    // URL the shop already has.
    final logoUrl = await _upload(provider, _logoFile);
    if (logoUrl == null) return;
    final bannerUrl = await _upload(provider, _bannerFile);
    if (bannerUrl == null) return;

    final success = await provider.updateShop(
      widget.shop.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      whatsappLink: phone.isEmpty
          ? ''
          : 'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}',
      theme: _selectedThemeId,
      themeConfig: _currentConfig,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.dataError ?? 'Impossible de modifier cette boutique'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Boutique mise à jour ✅'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Personnaliser la boutique',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              'Enregistrer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final themes = provider.themes;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Logo'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _logoFile != null
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: _logoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(_logoFile!, fit: BoxFit.cover),
                          )
                        : _existingOrPlaceholder(widget.shop.logoUrl),
                  ),
                ),
                const SizedBox(height: 20),

                _label('Image de couverture'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickBanner,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _bannerFile != null
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: _bannerFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_bannerFile!, fit: BoxFit.cover),
                          )
                        : _existingOrPlaceholder(widget.shop.bannerUrl),
                  ),
                ),
                const SizedBox(height: 24),

                _label('Nom de la boutique'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                _label('Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                _label('Lien WhatsApp'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    _label('Thème'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openPreview(themes),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('Aperçu'),
                      style:
                          TextButton.styleFrom(foregroundColor: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: themes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      final isSelected = theme.id == _selectedThemeId;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedThemeId = theme.id),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : AppTheme.border,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  3,
                                  (i) => Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorAt(i),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                theme.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                theme.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                _label('Textes de la page'),
                const SizedBox(height: 12),
                _textField(_heroEyebrowController, 'Sur-titre du bandeau'),
                _textField(_heroTitleController, 'Titre principal'),
                _textField(_heroSubtitleController, 'Sous-titre', lines: 2),
                _textField(_aboutTitleController, 'Titre « À propos »'),
                _textField(_aboutTextController, 'Texte « À propos »', lines: 4),
                _textField(_footerTextController, 'Pied de page'),
                const SizedBox(height: 12),
                _textField(_contactEmailController, 'Email de contact',
                    keyboard: TextInputType.emailAddress),
                _textField(_contactPhoneController, 'Téléphone de contact',
                    keyboard: TextInputType.phone),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    child: Text(
                      'Enregistrer les modifications',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows the image already saved for the shop, or a placeholder.
  Widget _existingOrPlaceholder(String url) {
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, fit: BoxFit.cover),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_rounded, color: AppTheme.textHint, size: 24),
        const SizedBox(height: 4),
        Text(
          'Modifier',
          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int lines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: lines > 1),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}