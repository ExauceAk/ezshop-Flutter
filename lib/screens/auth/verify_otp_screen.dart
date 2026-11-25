import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';
import '../../utils/phone_countries.dart';

/// Registration OTP verification screen.
///
/// Reached immediately after `POST /auth/register` (or when logging into an
/// unverified account). Validates the 6-digit KYA SMS code via
/// `POST /auth/verify-otp` before starting the user session.
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _handleVerify() async {
    if (_verifying || _resending) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    setState(() => _verifying = true);
    final provider = context.read<AppProvider>();
    final success = await provider.verifyRegisterOtp(
      widget.phone,
      _codeController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _verifying = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      AppToast.success(l10n.t('auth.signup.success'));
      return;
    }

    AppToast.error(
      provider.authError ?? l10n.t('auth.otp.error'),
      context: context,
    );
  }

  Future<void> _handleResend() async {
    if (_secondsLeft > 0 || _resending || _verifying) return;
    final l10n = context.l10n;
    setState(() => _resending = true);
    final provider = context.read<AppProvider>();
    final ok = await provider.resendRegisterOtp(widget.phone);
    if (!mounted) return;
    setState(() => _resending = false);

    if (ok) {
      _startCooldown();
      AppToast.success(l10n.t('auth.otp.resent'), context: context);
    } else {
      AppToast.error(
        provider.authError ?? l10n.t('auth.otp.error'),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayPhone = formatDisplayPhone(widget.phone);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.t('auth.otp.title'),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.t('auth.otp.subtitle', {'phone': displayPhone}),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.t('auth.otp.codeLabel'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeController,
                  enabled: !_verifying,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 10,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.t('auth.otp.codeHint'),
                    counterText: '',
                  ),
                  onFieldSubmitted: (_) => _handleVerify(),
                  validator: (value) {
                    final digits = value?.trim() ?? '';
                    if (digits.length != 6) {
                      return l10n.t('auth.otp.codeRequired');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _handleVerify,
                    child: _verifying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(l10n.t('auth.otp.verify')),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed:
                        (_secondsLeft > 0 || _resending) ? null : _handleResend,
                    child: _resending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _secondsLeft > 0
                                ? l10n.t('auth.otp.resendIn', {
                                    'seconds': '$_secondsLeft',
                                  })
                                : l10n.t('auth.otp.resend'),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: _secondsLeft > 0
                                  ? AppTheme.textHint
                                  : AppTheme.primary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
