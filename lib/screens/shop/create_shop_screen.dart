import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/shop_theme.dart';
import '../../models/shop_theme_config.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import 'theme_preview_sheet.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _subdomainController = TextEditingController();

  // Storefront customisations, mirrored into the preview.
  final _heroEyebrowController = TextEditingController();
  final _heroTitleController = TextEditingController();
  final _heroSubtitleController = TextEditingController();
  final _aboutTitleController = TextEditingController();
  final _aboutTextController = TextEditingController();
  final _footerTextController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String _selectedThemeId = 'atelier';
  File? _logoFile;
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();

  /// Customisations as typed so far, rendered live by the preview.
  ShopThemeConfig get _previewConfig {
    return ShopThemeConfig(
      heroEyebrow: _heroEyebrowController.text.trim(),
      heroTitle: _heroTitleController.text.trim(),
      heroSubtitle: _heroSubtitleController.text.trim(),
      aboutTitle: _aboutTitleController.text.trim(),
      aboutText: _aboutTextController.text.trim(),
      footerText: _footerTextController.text.trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _whatsappController.dispose();
    _subdomainController.dispose();
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
      slug: _subdomainController.text.trim(),
      config: _previewConfig,
      onSelect: () {
        setState(() => _selectedThemeId = theme.id);
        Navigator.pop(context);
      },
    );
  }

  /// Sends one picked image and returns the URL to store, or null on failure
  /// after showing why.
  ///
  /// An empty string is returned when no image was picked, so the caller can
  /// pass the result straight to the API.
  Future<String?> _upload(AppProvider provider, File? file,
      {required String folder}) async {
    if (file == null) return '';

    final url = await provider.uploadImage(file, folder: folder);
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final phone = _whatsappController.text.trim();
    final whatsappLink = phone.isEmpty
        ? ''
        : 'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

    // Images must exist on the server before the shop references them, so
    // they are sent first and their returned URLs stored on the shop.
    final logoUrl = await _upload(provider, _logoFile, folder: 'shops');
    if (logoUrl == null) return;
    final bannerUrl = await _upload(provider, _bannerFile, folder: 'shops');
    if (bannerUrl == null) return;

    final success = await provider.createShop(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      whatsappLink: whatsappLink,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      theme: _selectedThemeId,
      themeConfig: ShopThemeConfig(
        heroEyebrow: _heroEyebrowController.text.trim(),
        heroTitle: _heroTitleController.text.trim(),
        heroSubtitle: _heroSubtitleController.text.trim(),
        aboutTitle: _aboutTitleController.text.trim(),
        aboutText: _aboutTextController.text.trim(),
        footerText: _footerTextController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
      ),
      subdomain: _subdomainController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.dataError ?? 'Impossible de créer la boutique'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Boutique créée avec succès ! 🎉'),
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
          'Créer ma boutique',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final themes = provider.themes;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // ─── Logo & banner ───
                  _buildLabel('Logo de la boutique'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildImagePicker(
                        size: 92,
                        file: _logoFile,
                        placeholder: Icons.storefront_rounded,
                        onTap: _pickLogo,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Image de couverture'),
                            const SizedBox(height: 8),
                            _buildBannerPicker(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Identity ───
                  _buildLabel('Nom de la boutique'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: 'Ma Boutique'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Décrivez votre boutique...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Description requise'
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Lien WhatsApp (optionnel)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+221 6XX XXX XXX',
                      prefixIcon: Icon(Icons.phone_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Subdomain ───
                  _buildLabel('Adresse de votre boutique web'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _subdomainController,
                          textCapitalization: TextCapitalization.none,
                          decoration:
                              const InputDecoration(hintText: 'ma-boutique'),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Sous-domaine requis';
                            if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                              return 'Minuscules, chiffres et tirets uniquement';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '.${AppConfig.shopDomain}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ─── Theme picker ───
                  _buildThemePicker(themes, provider),
                  const SizedBox(height: 28),

                  // ─── Storefront text customisation ───
                  _buildCustomisationSection(),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(
                        'Créer ma boutique',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront_rounded,
              size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            'Configurez votre boutique',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'Choisissez un thème et personnalisez vos textes',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePicker(List<ShopTheme> themes, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel('Thème de la boutique'),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openPreview(themes),
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('Aperçu'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Touchez un thème pour le prévisualiser en entier',
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: themes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildThemeCard(themes[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildThemeCard(ShopTheme theme) {
    final isSelected = theme.id == _selectedThemeId;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedThemeId = theme.id);
        _openPreview([theme]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 176,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : AppTheme.border,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? theme.primaryColor : Colors.black)
                  .withOpacity(isSelected ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 92,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: theme.previewImage.isEmpty
                        ? _buildSwatchStrip(theme)
                        : Image.network(
                            theme.previewImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildSwatchStrip(theme),
                          ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? theme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: theme.colorAt(i),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.description,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Palette preview used when the theme image cannot be loaded.
  Widget _buildSwatchStrip(ShopTheme theme) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(child: ColoredBox(color: theme.colorAt(i))),
      ),
    );
  }

  Widget _buildCustomisationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Textes de la page'),
        const SizedBox(height: 4),
        Text(
          'Laissez vide pour utiliser le texte par défaut du thème',
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heroEyebrowController,
          decoration: const InputDecoration(
            labelText: 'Sur-titre du bandeau',
            hintText: 'Boutique indépendante',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _heroTitleController,
          decoration: const InputDecoration(
            labelText: 'Titre principal',
            hintText: 'Des objets pensés pour mieux habiter',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _heroSubtitleController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Sous-titre du bandeau',
            hintText: 'La phrase qui donne envie de découvrir',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _aboutTitleController,
          decoration: const InputDecoration(
            labelText: 'Titre de la section « À propos »',
            hintText: 'Moins, mais mieux',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _aboutTextController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Texte « À propos »',
            alignLabelWithHint: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _footerTextController,
          decoration: const InputDecoration(
            labelText: 'Texte du pied de page',
            hintText: 'Objets simples · Maison durable',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        _buildLabel('Coordonnées affichées en pied de page'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contactEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'email'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _contactPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Téléphone'),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required double size,
    required File? file,
    required IconData placeholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: file != null ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(file, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded,
                      color: AppTheme.textHint, size: 26),
                  const SizedBox(height: 4),
                  Text(
                    'Ajouter',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textHint),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBannerPicker() {
    return GestureDetector(
      onTap: _pickBanner,
      child: Container(
        height: 92,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _bannerFile != null ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
        ),
        child: _bannerFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_bannerFile!, fit: BoxFit.cover),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded,
                      color: AppTheme.textHint, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Choisir une couverture',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}