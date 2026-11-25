import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';
import '../../utils/phone_countries.dart';
import '../../widgets/phone_input_field.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  PhoneCountry _selectedCountry = findPhoneCountryByDialCode('229');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final fullPhone = composeInternationalPhone(
      _selectedCountry,
      _phoneController.text,
    );

    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final success = await provider.login(
      fullPhone,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
      AppToast.success(l10n.t('auth.login.success'));
      return;
    }

    if (provider.authErrorCode == 'PHONE_NOT_VERIFIED') {
      final phoneToVerify = provider.pendingVerificationPhone ?? fullPhone;
      AppToast.info(l10n.t('auth.otp.unverifiedNotice'), context: context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(phone: phoneToVerify),
        ),
      );
      return;
    }

    AppToast.error(
      provider.authError ?? l10n.t('auth.login.error'),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // ─── Logo & Title ───
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.t('about.title').isEmpty ? '' : 'EZ Shop',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.t('auth.login.subtitle'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 44),

              // ─── Form ───
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('auth.login.phone'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhoneInputField(
                      selectedCountry: _selectedCountry,
                      onCountryChanged: (c) =>
                          setState(() => _selectedCountry = c),
                      controller: _phoneController,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.t('auth.login.password'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      maxLength: 64,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.t('auth.login.passwordRequired');
                        }
                        if (v.length < 6) {
                          return l10n.t('auth.login.passwordMin');
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: Text(
                    l10n.t('auth.login.forgot'),
                    style: GoogleFonts.poppins(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Login Button ───
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(l10n.t('auth.login.cta')),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Sign Up Link ───
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: '${l10n.t('auth.login.noAccount')} ',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                      children: [
                        TextSpan(
                          text: l10n.t('auth.login.createAccount'),
                          style: GoogleFonts.poppins(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
