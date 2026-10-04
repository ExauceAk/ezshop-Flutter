import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_strings.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

/// Badges of a product card: condition, and whether the price can be
/// negotiated.
///
/// The negotiable badge sits right after the "Neuf" / "Occasion" one because
/// both answer the same question a buyer asks first: what am I getting, and
/// can I haggle over it.
class ProductTags extends StatelessWidget {
  const ProductTags({
    super.key,
    required this.product,
    this.fontSize = 12,
  });

  final Product product;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Tag(
          label: context.l10n.t(
            product.isNeuf ? 'product.tag.neuf' : 'product.tag.occasion',
          ),
          color: product.isNeuf ? AppTheme.success : AppTheme.warning,
          fontSize: fontSize,
        ),
        const SizedBox(width: 4),
        _Tag(
          label: context.l10n.t(
            product.isNegotiable
                ? 'product.tag.negotiable'
                : 'product.tag.fixedPrice',
          ),
          color: product.isNegotiable ? AppTheme.primary : AppTheme.textHint,
          fontSize: fontSize,
          // The negotiable badge is an outline, so it reads as information
          // rather than as a second "condition" flag.
          outlined: true,
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.fontSize,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final double fontSize;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.7, vertical: fontSize * 0.4),
      decoration: BoxDecoration(
        // Solid on both variants: these badges are drawn over a photo on the
        // product page, and a translucent background made the text unreadable.
        color: outlined ? Colors.white : color,
        borderRadius: BorderRadius.circular(6),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: outlined ? color : Colors.white,
        ),
      ),
    );
  }
}