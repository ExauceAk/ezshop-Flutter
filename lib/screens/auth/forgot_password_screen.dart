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
import '../../widgets/phone_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  PhoneCountry _selectedCountry = findPhoneCountryByDialCode('229');
  String _targetPhone = '';
  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  Future<void> _handleSendCode() async {
    if (_isLoading) return;
    if (!_phoneFormKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final fullPhone = composeInternationalPhone(
      _selectedCountry,
      _phoneController.text,
    );

    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final success = await provider.forgotPassword(fullPhone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _codeSent = true;
        _targetPhone = fullPhone;
      });
      _startCooldown();
      AppToast.success(l10n.t('auth.forgot.sent'), context: context);
    } else {
      AppToast.error(
        provider.authError ?? l10n.t('auth.login.phoneInvalid'),
        context: context,
      );
    }
  }

  Future<void> _handleResendCode() async {
    if (_isLoading || _secondsLeft > 0 || _targetPhone.isEmpty) return;
    final l10n = context.l10n;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final ok = await provider.forgotPassword(_targetPhone);
    if (!mounted) return;
    setState(() => _isLoading = false);

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

  Future<void> _handleResetPassword() async {
    if (_isLoading) return;
    if (!_resetFormKey.currentState!.validate()) return;

    final l10n = context.l10n;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final success = await provider.resetPassword(
      phone: _targetPhone,
      code: _codeController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppToast.success(l10n.t('auth.forgot.resetSuccess'));
      Navigator.pop(context);
    } else {
      AppToast.error(
        provider.authError ?? l10n.t('auth.otp.error'),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _codeSent ? _buildResetView() : _buildPhoneView(),
        ),
      ),
    );
  }

  Widget _buildPhoneView() {
    final l10n = context.l10n;
    return Form(
      key: _phoneFormKey,
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
              Icons.lock_reset_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('auth.forgot.title'),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('auth.forgot.subtitle'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.t('auth.login.phone'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          PhoneInputField(
            selectedCountry: _selectedCountry,
            onCountryChanged: (c) => setState(() => _selectedCountry = c),
            controller: _phoneController,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendCode(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendCode,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(l10n.t('auth.forgot.cta')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetView() {
    final l10n = context.l10n;
    final displayPhone = formatDisplayPhone(_targetPhone);

    return Form(
      key: _resetFormKey,
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
            l10n.t('auth.forgot.title'),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('auth.forgot.codeSentTo', {'phone': displayPhone}),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('auth.forgot.codeLabel'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            enabled: !_isLoading,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: l10n.t('auth.otp.codeHint'),
              counterText: '',
              prefixIcon: const Icon(
                Icons.pin_outlined,
                color: AppTheme.textHint,
              ),
            ),
            validator: (v) {
              if ((v?.trim() ?? '').length != 6) {
                return l10n.t('auth.otp.codeRequired');
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          Text(
            l10n.t('auth.forgot.newPassword'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            enabled: !_isLoading,
            maxLength: 64,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: '••••••••',
              counterText: '',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppTheme.textHint,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return l10n.t('auth.signup.passwordRequired');
              }
              if (v.length < 6) return l10n.t('auth.login.passwordMin');
              return null;
            },
          ),
          const SizedBox(height: 18),
          Text(
            l10n.t('auth.forgot.confirmPassword'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            enabled: !_isLoading,
            maxLength: 64,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: InputDecoration(
              hintText: '••••••••',
              counterText: '',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppTheme.textHint,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return l10n.t('auth.signup.confirmRequired');
              }
              if (v != _passwordController.text) {
                return l10n.t('auth.signup.mismatch');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(l10n.t('auth.forgot.resetCta')),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() {
                          _codeSent = false;
                          _codeController.clear();
                        }),
                child: Text(
                  l10n.t('auth.forgot.changePhone'),
                  style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                ),
              ),
              TextButton(
                onPressed:
                    (_secondsLeft > 0 || _isLoading) ? null : _handleResendCode,
                child: Text(
                  _secondsLeft > 0
                      ? l10n.t('auth.otp.resendIn', {'seconds': '$_secondsLeft'})
                      : l10n.t('auth.otp.resend'),
                  style: GoogleFonts.poppins(
                    color: _secondsLeft > 0
                        ? AppTheme.textHint
                        : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
