import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';
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
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.t('form.create.title')),
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
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () => _handleSubmit(context.read<AppProvider>()),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.t('form.create.cta')),
            ),
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
      logoFile: _data.logoFile,
      bannerFile: _data.bannerFile,
      config: _data.themeConfig,
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
      onSelect: () {},
    );
  }

  Future<void> _handleSubmit(AppProvider provider) async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? true)) return;

    final l10n = context.l10n;
    if (_data.name.trim().isEmpty) {
      AppToast.error(l10n.t('product.form.required'), context: context);
      return;
    }

    final navigator = Navigator.of(context);
    setState(() => _submitting = true);

    try {
      // Images must exist on the server before the shop references them.
      final logoUrl = await _upload(provider, _data.logoFile, l10n);
      if (logoUrl == null) return;
      final bannerUrl = await _upload(provider, _data.bannerFile, l10n);
      if (bannerUrl == null) return;

      final success = await provider.createShop(
        name: _data.name,
        description: _data.heroSubtitle,
        whatsappLink: _data.whatsappLink,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        theme: _data.themeId,
        themeConfig: _data.themeConfig,
        subdomain: ShopFormData.slugify(
          _data.slug.trim().isNotEmpty ? _data.slug : _data.name,
        ),
      );

      if (!mounted) return;

      if (!success) {
        AppToast.error(
          provider.dataError ?? l10n.t('form.create.failed'),
          context: context,
        );
        return;
      }

      navigator.pop();
      AppToast.success(l10n.t('form.create.success'));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  /// Sends one picked image and returns the URL to store, or null on failure
  /// after showing why.
  Future<String?> _upload(
    AppProvider provider,
    File? file,
    AppStrings l10n,
  ) async {
    if (file == null) return '';

    final url = await provider.uploadImage(file, folder: 'shops');
    if (url != null) return url;

    if (mounted) {
      AppToast.error(
        provider.dataError ?? l10n.t('form.uploadFailed'),
        context: context,
      );
    }
    return null;
  }
}
