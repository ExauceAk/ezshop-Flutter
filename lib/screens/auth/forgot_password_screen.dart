import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    final provider = context.read<AppProvider>();
    final success = await provider.forgotPassword(_emailController.text);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.authError ?? 'Email invalide'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.t('auth.login.forgot'),
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          "Pas de problème ! Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 32),
        Text('Email', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'votre@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleReset,
            child: const Text('Envoyer le lien'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.success, size: 50),
        ),
        const SizedBox(height: 32),
        Text(
          context.l10n.t('auth.forgot.success'),
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Un lien de réinitialisation a été envoyé à\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.t('auth.forgot.backToLogin')),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: Text("Renvoyer l'email", style: GoogleFonts.poppins(color: AppTheme.primary)),
        ),
      ],
    );
  }
}
