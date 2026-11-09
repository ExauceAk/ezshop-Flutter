import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Root key attached to [MaterialApp.scaffoldMessengerKey] so toasts survive
/// route pops (`Navigator.pop`), modal dismissals and page replacements.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Unified floating toast helper for every mutation and async action.
class AppToast {
  const AppToast._();

  static void success(String message, {BuildContext? context}) {
    _show(
      message,
      backgroundColor: AppTheme.success,
      icon: Icons.check_circle_rounded,
      context: context,
    );
  }

  static void error(String message, {BuildContext? context}) {
    _show(
      message,
      backgroundColor: AppTheme.error,
      icon: Icons.error_outline_rounded,
      context: context,
    );
  }

  static void info(String message, {BuildContext? context}) {
    _show(
      message,
      backgroundColor: AppTheme.textPrimary,
      icon: Icons.info_outline_rounded,
      context: context,
    );
  }

  static void _show(
    String message, {
    required Color backgroundColor,
    required IconData icon,
    BuildContext? context,
  }) {
    if (message.trim().isEmpty) return;

    ScaffoldMessengerState? messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null && context != null && context.mounted) {
      messenger = ScaffoldMessenger.maybeOf(context);
    }
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
