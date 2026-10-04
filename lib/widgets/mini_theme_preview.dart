import 'package:flutter/material.dart';

import '../models/shop_theme.dart';

/// A real miniature of a storefront theme.
///
/// The picker used to show three colour dots, which said nothing about the
/// thing the seller is actually choosing: three dots look the same whether the
/// hero is a full-bleed overlay or a two-column split. This draws the theme's
/// structure — header, hero shape, product area — at a size small enough to sit
/// next to a form field, using the theme's own palette, fonts and radius so the
/// choice is made on what the storefront will look like.
///
/// Deliberately built from blocks rather than from [StorefrontPreview]: that
/// widget is a full scrolling storefront and would be far too heavy to draw
/// once per theme card.
class MiniThemePreview extends StatelessWidget {
  const MiniThemePreview({
    super.key,
    required this.theme,
    this.width = 96,
    this.height = 118,
  });

  final ShopTheme theme;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: theme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              _hero(),
              Expanded(child: _products()),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo dot plus two nav dashes.
  Widget _header() {
    return Container(
      height: 18,
      color: theme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                _bar(width: 14, color: theme.textColor.withOpacity(0.55)),
                const SizedBox(width: 3),
                _bar(width: 10, color: theme.muted.withOpacity(0.7)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The hero, drawn in the shape the theme actually uses.
  Widget _hero() {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _bar(width: 26, height: 5, color: theme.textColor),
        const SizedBox(height: 3),
        _bar(width: 34, height: 4, color: theme.muted),
        const SizedBox(height: 4),
        _bar(width: 18, height: 5, color: theme.primary),
      ],
    );

    switch (theme.heroStyle) {
      case HeroStyle.stacked:
        // Text only: no image block at all, which is what tells this theme
        // apart from the others at a glance.
        return Container(
          height: 38,
          color: theme.surface,
          padding: const EdgeInsets.all(6),
          alignment: Alignment.centerLeft,
          child: text,
        );
      case HeroStyle.split:
        return SizedBox(
          height: 38,
          child: Row(
            children: [
              Expanded(child: _imageBlock()),
              Expanded(
                child: Container(
                  color: theme.surface,
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  child: text,
                ),
              ),
            ],
          ),
        );
      case HeroStyle.strip:
        // Short band: logo and text side by side.
        return Container(
          height: 24,
          color: theme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.surface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(child: _bar(width: 24, height: 4, color: theme.surface)),
            ],
          ),
        );
      case HeroStyle.overlay:
        // Text drawn over the image, which is what the real hero does.
        return SizedBox(
          height: 42,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _imageBlock(),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _bar(width: 26, height: 5, color: Colors.white),
                    const SizedBox(height: 3),
                    _bar(width: 18, height: 4, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _imageBlock() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.primary, theme.accent],
          ),
        ),
      );

  /// Grid of tiles or stacked rows, following [ShopTheme.productLayout].
  Widget _products() {
    if (theme.productLayout == ProductLayout.list) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  _tile(width: 14, height: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(width: 22, height: 3, color: theme.textColor),
                        const SizedBox(height: 2),
                        _bar(width: 14, height: 3, color: theme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Grid: the column count is the theme's, so a two-column storefront reads
    // differently from a four-column one.
    final columns = theme.columns.clamp(2, 4);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.count(
        crossAxisCount: columns,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(columns * 2, (_) => _tile(width: double.infinity, height: null)),
      ),
    );
  }

  /// One product tile, styled by [ShopTheme.cardStyle].
  Widget _tile({required double width, double? height}) {
    final radius = BorderRadius.circular(theme.radius * 0.4);

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: radius,
        // Bordered and framed draw an outline; elevated and minimal do not, so
        // the two families stay distinguishable at this size.
        border: switch (theme.cardStyle) {
          CardStyle.bordered || CardStyle.framed =>
            Border.all(color: theme.border, width: 0.5),
          _ => null,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: radius,
                // The framed style insets the image inside the card.
                border: theme.cardStyle == CardStyle.framed
                    ? Border.all(color: theme.border, width: 0.5)
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
            child: _bar(width: double.infinity, height: 2.5, color: theme.primary),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _footer() => Container(height: 8, color: theme.surface);

  /// A rounded rectangle standing in for a line of text.
  Widget _bar({
    required double width,
    double height = 3,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}