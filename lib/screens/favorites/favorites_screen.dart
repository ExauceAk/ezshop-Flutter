import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../utils/app_toast.dart';
import '../../utils/price_format.dart';
import '../../widgets/product_tags.dart';
import '../product/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          context.l10n.t('favorites.title'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final favorites =
              provider.products.where((p) => p.isFavorite).toList();
          if (favorites.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: AppTheme.textHint.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.t('favorites.empty.title'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('favorites.empty.subtitle'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildFavoriteCard(context, provider, favorites[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    AppProvider provider,
    Product product,
  ) {
    final busy = provider.isTogglingFavorite(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F5),
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first : '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: AppTheme.textHint,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: ProductTags(product: product, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(product.price),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite, color: AppTheme.error),
              onPressed: busy
                  ? null
                  : () async {
                      final l10n = context.l10n;
                      final res = await provider.toggleFavorite(product.id);
                      if (res == null) {
                        AppToast.error(
                          provider.dataError ?? l10n.t('favorites.failed'),
                        );
                      } else if (res) {
                        AppToast.success(l10n.t('favorites.added'));
                      } else {
                        AppToast.info(l10n.t('favorites.removed'));
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
