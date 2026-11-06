import 'package:flutter/material.dart';

import '../models/shop_theme.dart';
import '../models/shop_theme_config.dart';

/// A real miniature of a storefront theme.
///
/// Draws the theme's signature architecture — header, hero shape, product area
/// — at a size small enough to sit on a picker card or next to the domain
/// field, using the theme's active palette (including any custom seller
/// colours passed in [config]).
class MiniThemePreview extends StatelessWidget {
  const MiniThemePreview({
    super.key,
    required this.theme,
    this.config,
    this.width = 96,
    this.height = 118,
  });

  final ShopTheme theme;
  final ShopThemeConfig? config;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final active = theme.applyCustomColors(config);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active.background,
            border: Border.all(color: active.border, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildArchitecture(active),
        ),
      ),
    );
  }

  Widget _buildArchitecture(ShopTheme t) {
    if (t.id == 'super-marche') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 22,
            color: t.surface,
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dot(t.primary, 7),
                const SizedBox(height: 5),
                _bar(width: 14, height: 2.5, color: t.primary),
                const SizedBox(height: 3),
                _bar(width: 12, height: 2.5, color: t.muted),
                const SizedBox(height: 3),
                _bar(width: 13, height: 2.5, color: t.muted),
              ],
            ),
          ),
          Container(width: 0.7, color: t.border),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 24,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: t.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.centerLeft,
                  child: _bar(width: 28, height: 3.5, color: Colors.white),
                ),
                Expanded(child: _products(t)),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(t),
            _hero(t),
            Expanded(child: _products(t)),
            _footer(t),
          ],
        ),
        if (t.id == 'sneaker-drop')
          Positioned(
            bottom: 4,
            left: 14,
            right: 14,
            child: Container(
              height: 9,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: t.primary, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _header(ShopTheme t) {
    if (t.id == 'gazette' || t.id == 'editorial') {
      return Container(
        height: 18,
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(bottom: BorderSide(color: t.border, width: 1)),
        ),
        alignment: Alignment.center,
        child: _bar(width: 36, height: 4, color: t.textColor),
      );
    }

    if (t.id == 'tribal') {
      return Container(
        height: 16,
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(bottom: BorderSide(color: t.textColor, width: 1.2)),
        ),
        child: Row(
          children: [
            Container(width: 24, color: t.primary),
            Expanded(child: Center(child: _bar(width: 18, height: 3, color: t.textColor))),
            Container(width: 18, color: t.accent),
          ],
        ),
      );
    }

    return Container(
      height: 16,
      color: t.surface,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          _dot(t.primary, 7),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                _bar(width: 14, color: t.textColor.withValues(alpha: 0.65)),
                const SizedBox(width: 3),
                _bar(width: 10, color: t.muted.withValues(alpha: 0.7)),
              ],
            ),
          ),
          _dot(t.accent, 5),
        ],
      ),
    );
  }

  Widget _hero(ShopTheme t) {
    switch (t.id) {
      case 'bento':
        return SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.bottomLeft,
                    child: _bar(width: 22, height: 3.5, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.border, width: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case 'vendome':
        return SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: [
                Expanded(child: _imageBlock(t)),
                const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    color: t.surface,
                    alignment: Alignment.center,
                    child: _bar(width: 16, height: 3.5, color: t.textColor),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(child: _imageBlock(t)),
              ],
            ),
          ),
        );

      case 'aqua':
      case 'orbit':
        return Container(
          height: 38,
          color: t.surface,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(width: 24, height: 4, color: t.textColor),
                    const SizedBox(height: 3),
                    _bar(width: 16, height: 3, color: t.primary),
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [t.primary, t.accent]),
                  border: Border.all(color: t.border, width: 1.5),
                ),
              ),
            ],
          ),
        );

      case 'baobab':
        return Container(
          height: 38,
          color: t.surface,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(width: 24, height: 4, color: t.textColor),
                    const SizedBox(height: 3),
                    _bar(width: 16, height: 3, color: t.primary),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(99)),
                child: SizedBox(width: 24, height: 28, child: _imageBlock(t)),
              ),
            ],
          ),
        );

      default:
        break;
    }

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _bar(width: 24, height: 4.5, color: t.textColor),
        const SizedBox(height: 3),
        _bar(width: 30, height: 3, color: t.muted),
        const SizedBox(height: 3),
        _bar(width: 16, height: 4, color: t.primary),
      ],
    );

    switch (t.heroStyle) {
      case HeroStyle.stacked:
        return Container(
          height: 36,
          color: t.surface,
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bar(width: 34, height: 4.5, color: t.textColor),
              const SizedBox(height: 3),
              _bar(width: 22, height: 3, color: t.accent),
            ],
          ),
        );
      case HeroStyle.split:
        return SizedBox(
          height: 36,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: t.surface,
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  child: text,
                ),
              ),
              Expanded(child: _imageBlock(t)),
            ],
          ),
        );
      case HeroStyle.strip:
        return Container(
          height: 24,
          color: t.primary,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              _dot(t.surface, 9),
              const SizedBox(width: 5),
              Expanded(child: _bar(width: 24, height: 3.5, color: t.surface)),
            ],
          ),
        );
      case HeroStyle.overlay:
        return SizedBox(
          height: 38,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _imageBlock(t),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _bar(width: 26, height: 4.5, color: Colors.white),
                    const SizedBox(height: 2.5),
                    _bar(width: 18, height: 3.5, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _imageBlock(ShopTheme t) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t.primary, t.accent],
          ),
        ),
      );

  Widget _products(ShopTheme t) {
    if (t.productLayout == ProductLayout.list) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) => Row(
              children: [
                Container(
                  width: 11,
                  height: 9,
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: t.border, width: 0.6),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _bar(width: 20, height: 2.5, color: t.textColor),
                ),
                const SizedBox(width: 3),
                _bar(width: 10, height: 2.5, color: t.primary),
              ],
            ),
          ),
        ),
      );
    }

    final columns = t.columns.clamp(2, 3);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GridView.count(
        crossAxisCount: columns,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          columns * 2,
          (_) => _tile(t),
        ),
      ),
    );
  }

  Widget _tile(ShopTheme t) {
    final radius = BorderRadius.circular((t.radius * 0.25).clamp(0, 8));

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: radius,
        border: Border.all(color: t.border, width: 0.6),
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.primary.withValues(alpha: 0.14),
                borderRadius: radius,
              ),
            ),
          ),
          const SizedBox(height: 1.5),
          _bar(width: double.infinity, height: 2, color: t.primary),
        ],
      ),
    );
  }

  Widget _footer(ShopTheme t) => Container(height: 6, color: t.surface);

  Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

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
