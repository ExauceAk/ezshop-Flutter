import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/product_model.dart';
import '../providers/app_provider.dart';
import '../screens/product/product_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/price_format.dart';

/// The product card used everywhere products are listed.
///
/// Home and search used to carry their own copy, which is how the search grid
/// kept a discount badge the home feed no longer had. One widget means the two
/// lists always show the same thing for the same product.
///
/// Layout: the condition badge sits on the photo, where it labels the picture,
/// while the price flag goes under the name, just above the price, so the two
/// pieces of information are read in that order.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.images.isNotEmpty ? product.images.first : '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ProductConditionBadge(product: product),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<AppProvider>().toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color:
                              product.isFavorite ? AppTheme.error : AppTheme.textHint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Not Flexible: in a short card the tag was squeezed until
                    // its text was unreadable. The card itself is taller now, so
                    // the tag can keep its natural height.
                    ProductPriceTag(product: product),
                    const Spacer(),
                    Text(
                      formatPrice(product.price),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Neuf" / "Occasion", drawn on the photo.
class ProductConditionBadge extends StatelessWidget {
  const ProductConditionBadge({super.key, required this.product, this.fontSize = 10});

  final Product product;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = product.isNeuf ? AppTheme.success : AppTheme.warning;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.6,
        vertical: fontSize * 0.3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.t(
          product.isNeuf ? 'product.tag.neuf' : 'product.tag.occasion',
        ),
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// "Négociable" / "Prix fixe", under the name and above the price.
class ProductPriceTag extends StatelessWidget {
  const ProductPriceTag({super.key, required this.product, this.fontSize = 12});

  final Product product;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = product.isNegotiable ? AppTheme.primary : AppTheme.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.7,
        vertical: fontSize * 0.4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        context.l10n.t(
          product.isNegotiable
              ? 'product.tag.negotiable'
              : 'product.tag.fixedPrice',
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}