import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/shop_model.dart';
import '../../models/shop_theme_config.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import 'shop_form.dart';
import 'theme_preview_sheet.dart';

/// Shop editing.
///
/// Same [ShopForm] as the creation screen, pre-filled with what the shop
/// already has. Picking no new image leaves the stored one untouched.
class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key, required this.shop});

  final Shop shop;

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  ShopFormData _data = const ShopFormData();

  @override
  void initState() {
    super.initState();
    // The stored link is split back into prefix and national number so the
    // seller edits a number rather than a URL.
    final phone = _phoneParts(widget.shop.whatsappLink);

    _data = ShopFormData(
      name: widget.shop.name,
      countryCode: phone.$1,
      whatsapp: phone.$2,
      heroTitle: widget.shop.themeConfig.heroTitle,
      heroSubtitle:
          widget.shop.themeConfig.heroSubtitle.isNotEmpty
              ? widget.shop.themeConfig.heroSubtitle
              : widget.shop.description,
      aboutTitle: widget.shop.themeConfig.aboutTitle,
      aboutText: widget.shop.themeConfig.aboutText,
      slug: widget.shop.subdomain,
      themeId: widget.shop.theme,
      primaryColor: widget.shop.themeConfig.primaryColor,
      accentColor: widget.shop.themeConfig.accentColor,
      backgroundColor: widget.shop.themeConfig.backgroundColor,
    );
  }

  /// Splits a stored `wa.me` link back into prefix and national number.
  static (String, String) _phoneParts(String link) {
    final digits = link.replaceAll(RegExp(r'[^0-9]'), '');
    for (final code in const [
      '221',
      '225',
      '223',
      '226',
      '237',
      '33',
      '1',
    ]) {
      if (digits.startsWith(code) && digits.length > code.length) {
        return (code, digits.substring(code.length));
      }
    }
    return ('221', digits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.t('form.update.title')),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return ShopForm(
            initial: _data,
            themes: provider.themes,
            existingLogo: widget.shop.logoUrl,
            existingBanner: widget.shop.bannerUrl,
            onChanged: (data) => _data = data,
            onPreview: () => _openPreview(provider),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: () => _handleSave(context.read<AppProvider>()),
            child: Text(context.l10n.t('form.update.cta')),
          ),
        ),
      ),
    );
  }

  void _openPreview(AppProvider provider) {
    showThemePreview(
      context,
      theme: provider.themeFor(_data.themeId),
      name: _data.name,
      description: _data.heroSubtitle,
      slug: widget.shop.subdomain,
      logoUrl: widget.shop.logoUrl,
      bannerUrl: widget.shop.bannerUrl,
      logoFile: _data.logoFile,
      bannerFile: _data.bannerFile,
      config: _config,
      onConfigChanged: (cfg) {
        setState(() {
          _data = _data.copyWith(
            primaryColor: cfg.primaryColor,
            accentColor: cfg.accentColor,
            backgroundColor: cfg.backgroundColor,
          );
        });
      },
      onThemeChanged: (theme) {
        setState(() {
          _data = _data.copyWith(themeId: theme.id);
        });
      },
      actionLabel: context.l10n.t('form.preview.apply'),
      onSelect: () {},
    );
  }

  ShopThemeConfig get _config => _data.themeConfig;

  Future<void> _handleSave(AppProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // null means "no new image": the provider then leaves the stored URL
    // alone, instead of blanking the logo by omission.
    final logoUrl = await _upload(provider, _data.logoFile);
    if (logoUrl == null) return;
    final bannerUrl = await _upload(provider, _data.bannerFile);
    if (bannerUrl == null) return;

    final success = await provider.updateShop(
      widget.shop.id,
      name: _data.name,
      description: _data.heroSubtitle,
      whatsappLink: _data.whatsappLink,
      // An empty string means no new image was picked, which must leave the
      // stored URL alone rather than overwrite it with nothing.
      logoUrl: logoUrl.isEmpty ? null : logoUrl,
      bannerUrl: bannerUrl.isEmpty ? null : bannerUrl,
      theme: _data.themeId,
      themeConfig: _config,
      subdomain: _data.slug,
    );

    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.dataError ?? context.l10n.t('form.update.failed'),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.t('form.update.success')),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    navigator.pop();
  }

  /// Uploads a picked image.
  ///
  /// @returns the new URL, an empty string when the seller picked nothing and
  /// therefore keeps the existing image, or null when the upload failed.
  Future<String?> _upload(AppProvider provider, File? file) async {
    if (file == null) return '';

    final url = await provider.uploadImage(file, folder: 'shops');
    if (url != null) return url;

    if (!mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.dataError ?? context.l10n.t('form.uploadFailed')),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return null;
  }
}