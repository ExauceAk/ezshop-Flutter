import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../theme/app_theme.dart';

/// Opens a full-height sheet showing a live preview of a storefront theme.
///
/// The preview is the real storefront rendered by the Next app with the
/// seller's current input as query parameters, so what is shown here is
/// exactly what will be published — no second implementation to keep in sync.
void showThemePreview(
  BuildContext context, {
  required String url,
  required String themeName,
  required VoidCallback onSelect,
  String actionLabel = 'Utiliser ce thème',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _ThemePreviewSheet(
        url: url,
        themeName: themeName,
        actionLabel: actionLabel,
        onSelect: onSelect,
      ),
    ),
  );
}

class _ThemePreviewSheet extends StatefulWidget {
  const _ThemePreviewSheet({
    required this.url,
    required this.themeName,
    required this.actionLabel,
    required this.onSelect,
  });

  final String url;
  final String themeName;
  final String actionLabel;
  final VoidCallback onSelect;

  @override
  State<_ThemePreviewSheet> createState() => _ThemePreviewSheetState();
}

class _ThemePreviewSheetState extends State<_ThemePreviewSheet> {
  final _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();

    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _failed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            // A missing image (the hero often has none yet) must not blank the
            // preview, so only a failure of the main document is reported.
            if (mounted) {
              setState(() {
                _loading = false;
                _failed = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thème ${widget.themeName}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Aperçu en direct de votre boutique',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                color: AppTheme.background,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    if (!_failed)
                      WebViewWidget(controller: _controller)
                    else
                      _PreviewUnavailable(url: widget.url),
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.actionLabel,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the storefront cannot be reached, so the seller understands why
/// the preview is blank instead of staring at an empty frame.
class _PreviewUnavailable extends StatelessWidget {
  const _PreviewUnavailable({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: AppTheme.textHint),
            const SizedBox(height: 12),
            Text(
              'Aperçu indisponible',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Le site web doit tourner pour afficher l\'aperçu.\n'
              'Vous pouvez quand même choisir le thème.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textHint),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}