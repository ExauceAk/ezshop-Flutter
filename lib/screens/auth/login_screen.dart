import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final success = await provider.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
      AppToast.success(l10n.t('auth.login.success'));
      return;
    }
    if (!success && mounted) {
      AppToast.error(
        provider.authError ?? l10n.t('auth.login.error'),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  context.l10n.t('about.title').isEmpty ? '' : 'EZ Shop',
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
                  context.l10n.t('auth.login.subtitle'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ─── Form ───
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.t('auth.login.email'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      maxLength: 100,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: context.l10n.t('auth.login.emailHint'),
                        counterText: '',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.l10n.t('auth.login.emailRequired');
                        if (!v.contains('@')) return context.l10n.t('auth.login.emailRequired');
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(context.l10n.t('auth.login.password'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      maxLength: 64,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.textHint,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return context.l10n.t('auth.login.passwordRequired');
                        if (v.length < 6) return context.l10n.t('auth.login.passwordMin');
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
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: Text(
                    context.l10n.t('auth.login.forgot'),
                    style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w500),
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
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(context.l10n.t('auth.login.cta')),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Divider ───
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ou', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Social Login ───
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: Text(context.l10n.t('auth.login.google'), style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Sign Up Link ───
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                      children: [
                        TextSpan(
                          text: "S'inscrire",
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
