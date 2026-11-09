import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';

/// Account deletion.
///
/// The privacy policy promises a way to delete an account and this is it. It
/// lives behind its own screen rather than inside the profile menu on purpose:
/// the action is permanent, so it should cost a deliberate navigation and then
/// a deliberate confirmation, not one tap.
///
/// The password is asked for because the deletion cannot be undone; a stolen
/// token must not be enough to destroy a shop.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _obscured = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_busy) return;
    final provider = context.read<AppProvider>();
    final navigator = Navigator.of(context);
    final l10n = context.l10n;

    if (_password.text.trim().isEmpty) {
      setState(() => _error = l10n.t('auth.login.passwordRequired'));
      AppToast.error(l10n.t('auth.login.passwordRequired'), context: context);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final deleted = await provider.deleteAccount(_password.text.trim());

    if (!mounted) return;
    setState(() => _busy = false);
    if (!deleted) {
      final msg = provider.dataError ?? l10n.t('delete.failed');
      setState(() => _error = msg);
      AppToast.error(msg, context: context);
      return;
    }

    // The session is already gone server-side: go back to the login screen
    // rather than to a profile that no longer exists.
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    AppToast.success(l10n.t('delete.done'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AppProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('delete.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── What goes ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8C9A0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF9A6412),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.t('delete.warningTitle'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9A6412),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.t('delete.warningBody'),
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    height: 1.6,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.t('delete.whatTitle'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'delete.items.account',
            'delete.items.personal',
            'delete.items.shops',
            'delete.items.orders',
            'delete.items.reviews',
            'delete.items.favorites',
            'delete.items.activity',
          ].map((key) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.t(key),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // ─── Proof of ownership ───
          Text(
            l10n.t('delete.confirmPassword'),
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _password,
            obscureText: _obscured,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: l10n.t('delete.passwordHint'),
              errorText: _error,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.t('delete.account', {'email': user.email}),
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textHint),
            ),
          ],
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _delete,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_forever_rounded, size: 20),
              label: Text(
                _busy ? l10n.t('delete.deleting') : l10n.t('delete.cta'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.error,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: Text(l10n.t('common.cancel')),
            ),
          ),
        ],
      ),
    );
  }
}