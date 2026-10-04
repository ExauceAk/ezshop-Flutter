import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/shop_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

/// Lets a buyer rate a shop with whole stars.
///
/// A user holds one rating per shop: rating again replaces the previous one,
/// and the stars open already filled with the rating they gave before, so the
/// sheet never looks like a second vote.
Future<void> showShopRatingSheet(
  BuildContext context,
  Shop shop,
) async {
  final provider = context.read<AppProvider>();
  await provider.loadShopStats(shop.id);
  if (!context.mounted) return;

  final stats = provider.statsOfShop(shop.id);
  final mine = provider.myRatingOf(shop.id);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ShopRatingSheet(
      shop: shop,
      initialRating: mine,
      average: stats?.rating ?? shop.rating,
      ratingCount: stats?.ratingCount ?? shop.ratingCount,
    ),
  );
}

class _ShopRatingSheet extends StatefulWidget {
  const _ShopRatingSheet({
    required this.shop,
    required this.initialRating,
    required this.average,
    required this.ratingCount,
  });

  final Shop shop;
  final int initialRating;
  final double average;
  final int ratingCount;

  @override
  State<_ShopRatingSheet> createState() => _ShopRatingSheetState();
}

class _ShopRatingSheetState extends State<_ShopRatingSheet> {
  late int _rating = widget.initialRating;
  bool _saving = false;

  Future<void> _submit() async {
    if (_rating == 0 || _saving) return;

    final l10n = context.l10n;

    setState(() => _saving = true);

    final provider = context.read<AppProvider>();
    final saved = await provider.rateShop(widget.shop.id, _rating);
    if (!mounted) return;

    setState(() => _saving = false);

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.dataError ?? context.l10n.t('rating.failed'),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.initialRating == 0
              ? l10n.t('rating.thanks')
              : l10n.t('rating.updated'),
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasRated = widget.initialRating > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasRated ? l10n.t('rating.edit') : l10n.t('rating.new'),
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = star),
                iconSize: 38,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(),
                icon: Icon(
                  star <= _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFFFB300),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              widget.ratingCount == 0
                  ? l10n.t('rating.none')
                  : l10n.t('rating.summary', {
                      'average': widget.average.toStringAsFixed(1),
                      'count': '${widget.ratingCount}',
                    }),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.t('rating.hint'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _rating == 0 || _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(hasRated ? l10n.t('rating.update') : l10n.t('rating.send')),
            ),
          ),
        ],
      ),
    );
  }
}