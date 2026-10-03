import 'package:flutter/material.dart';

/// White veil laid over the top of an image that runs under the status bar.
///
/// The clock and the battery icons are drawn by the system on top of the app,
/// and they clash with a photo underneath. Fading the image towards white keeps
/// them readable without hiding what the picture shows. The veil only covers the
/// status bar plus a little of the image, so it disappears as soon as the
/// content scrolls.
class TopFade extends StatelessWidget {
  const TopFade({super.key, this.extraHeight = 16, this.color = Colors.white});

  /// Height kept below the status bar so the fade does not stop too early.
  final double extraHeight;

  /// Colour the image fades into, usually the background of the screen.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return IgnorePointer(
      child: Container(
        height: topInset + extraHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.95),
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
