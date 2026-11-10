import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/shop_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_toast.dart';

/// Lets a buyer rate a shop with whole stars.
///
/// Opens immediately so the tap feels responsive, then loads the latest stats
/// and the user's previous rating inside the sheet with a subtle loader.
Future<void> showShopRatingSheet(
  BuildContext context,
  Shop shop,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ShopRatingSheet(shop: shop),
  );
}

class _ShopRatingSheet extends StatefulWidget {
  const _ShopRatingSheet({required this.shop});

  final Shop shop;

  @override
  State<_ShopRatingSheet> createState() => _ShopRatingSheetState();
}

class _ShopRatingSheetState extends State<_ShopRatingSheet> {
  int _initialRating = 0;
  int _rating = 0;
  double _average = 0;
  int _ratingCount = 0;
  bool _loadingInitial = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final cachedStats = provider.statsOfShop(widget.shop.id);
    final cachedMine = provider.myRatingOf(widget.shop.id);
    _initialRating = cachedMine;
    _rating = cachedMine;
    _average = cachedStats?.rating ?? widget.shop.rating;
    _ratingCount = cachedStats?.ratingCount ?? widget.shop.ratingCount;

    _fetchLatestStats();
  }

  Future<void> _fetchLatestStats() async {
    final provider = context.read<AppProvider>();
    await provider.loadShopStats(widget.shop.id);
    if (!mounted) return;
    final stats = provider.statsOfShop(widget.shop.id);
    final mine = provider.myRatingOf(widget.shop.id);
    setState(() {
      _initialRating = mine;
      if (_rating == 0 && mine > 0) {
        _rating = mine;
      }
      _average = stats?.rating ?? widget.shop.rating;
      _ratingCount = stats?.ratingCount ?? widget.shop.ratingCount;
      _loadingInitial = false;
    });
  }

  Future<void> _submit() async {
    if (_rating == 0 || _saving || _loadingInitial) return;

    final l10n = context.l10n;
    final provider = context.read<AppProvider>();

    setState(() => _saving = true);

    final saved = await provider.rateShop(widget.shop.id, _rating);
    if (!mounted) return;

    setState(() => _saving = false);

    final errorMessage = provider.dataError ?? l10n.t('rating.failed');
    final successMessage = _initialRating == 0
        ? l10n.t('rating.thanks')
        : l10n.t('rating.updated');

    Navigator.pop(context);

    if (!saved) {
      AppToast.error(errorMessage);
      return;
    }

    AppToast.success(successMessage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasRated = _initialRating > 0;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  hasRated ? l10n.t('rating.edit') : l10n.t('rating.new'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_loadingInitial)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _rating = star),
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
              _ratingCount == 0
                  ? l10n.t('rating.none')
                  : l10n.t('rating.summary', {
                      'average': _average.toStringAsFixed(1),
                      'count': '$_ratingCount',
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
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textHint,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _rating == 0 || _saving || _loadingInitial ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      hasRated
                          ? l10n.t('rating.update')
                          : l10n.t('rating.send'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
