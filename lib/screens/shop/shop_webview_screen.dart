import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_config.dart';
import '../../models/shop_model.dart';
import '../../theme/app_theme.dart';

/// Displays a shop's public storefront inside the app.
///
/// The page is loaded on the shop's own subdomain, the address customers will
/// type. A button in the app bar hands the page over to the device browser.
class ShopWebViewScreen extends StatefulWidget {
  const ShopWebViewScreen({super.key, required this.shop});

  final Shop shop;

  @override
  State<ShopWebViewScreen> createState() => _ShopWebViewScreenState();
}

class _ShopWebViewScreenState extends State<ShopWebViewScreen> {
  late final WebViewController _controller;
  late final String _url;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _url = AppConfig.shopUrl(widget.shop.subdomain);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          // A shop with no subdomain has no storefront to show, and a dead host
          // is reported here rather than leaving a blank white page.
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _loading = false;
              _error = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  void _openInBrowser() {
    launchUrl(Uri.parse(_url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            _buildLogo(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.shop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppConfig.shopDisplayUrl(widget.shop.subdomain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_error != null || _loading)
            IconButton(
              tooltip: 'Recharger',
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () {
                setState(() => _error = null);
                _controller.loadRequest(Uri.parse(_url));
              },
            ),
          IconButton(
            tooltip: 'Ouvrir dans le navigateur',
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_loading)
            const LinearProgressIndicator(minHeight: 2),

          // L'erreur est posée par-dessus la vue : sans domaine, ou avec un
          // hôte qui ne résout pas, la page resterait blanche sans explication.
          if (_error != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      size: 32,
                      color: AppTheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Boutique injoignable',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.shop.subdomain.isEmpty
                        ? 'Cette boutique n\'a pas encore de nom de domaine.'
                        : 'Impossible d\'afficher $_url',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(
                      'Ouvrir dans le navigateur',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final logoUrl = widget.shop.logoUrl;

    if (logoUrl.isEmpty) {
      return const Icon(Icons.storefront_rounded, color: AppTheme.primary);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        logoUrl,
        width: 34,
        height: 34,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.storefront_rounded,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}