import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shop_theme_config.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import 'shop_form.dart';
import 'theme_preview_sheet.dart';

/// Shop creation.
///
/// The fields live in [ShopForm], shared with the edit screen so the two
/// cannot drift apart. This screen only decides what to do with the result:
/// upload the images, then create the shop.
class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  ShopFormData _data = const ShopFormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Créer ma boutique'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ShopForm(
              initial: _data,
              themes: provider.themes,
              onChanged: (data) => _data = data,
              onPreview: () => _openPreview(provider),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: () => _handleSubmit(context.read<AppProvider>()),
            child: const Text('Créer ma boutique'),
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
      slug: _data.slug,
      config: ShopThemeConfig(
        heroTitle: _data.heroTitle,
        heroSubtitle: _data.heroSubtitle,
        aboutTitle: _data.aboutTitle,
        aboutText: _data.aboutText,
      ),
      onSelect: () {},
    );
  }

  Future<void> _handleSubmit(AppProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Images must exist on the server before the shop references them.
    final logoUrl = await _upload(provider, _data.logoFile);
    if (logoUrl == null) return;
    final bannerUrl = await _upload(provider, _data.bannerFile);
    if (bannerUrl == null) return;

    final success = await provider.createShop(
      name: _data.name,
      description: _data.heroSubtitle,
      whatsappLink: _data.whatsappLink,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      theme: _data.themeId,
      themeConfig: ShopThemeConfig(
        heroTitle: _data.heroTitle,
        heroSubtitle: _data.heroSubtitle,
        aboutTitle: _data.aboutTitle,
        aboutText: _data.aboutText,
      ),
      subdomain: _data.slug,
    );

    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.dataError ?? 'Impossible de créer la boutique'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: const Text('Boutique créée avec succès ! 🎉'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    navigator.pop();
  }

  /// Sends one picked image and returns the URL to store, or null on failure
  /// after showing why.
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
}