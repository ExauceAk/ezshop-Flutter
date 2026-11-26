import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/phone_countries.dart';

/// Inline country dial-code selector placed inside a phone `TextFormField`'s
/// `prefixIcon`, separated from the national number by a vertical hairline.
class PhoneCountryPrefix extends StatelessWidget {
  const PhoneCountryPrefix({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.enabled = true,
  });

  final PhoneCountry selectedCountry;
  final ValueChanged<PhoneCountry> onCountryChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: enabled
              ? () async {
                  final picked = await showPhoneCountryPicker(
                    context,
                    selected: selectedCountry,
                  );
                  if (picked != null) {
                    onCountryChanged(picked);
                  }
                }
              : null,
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8, top: 14, bottom: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.isoCode,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '+${selectedCountry.dialCode}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 1,
          height: 24,
          margin: const EdgeInsets.only(right: 12),
          color: AppTheme.textHint.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}

/// Unified single-field international phone input with an inline country selector.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.controller,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
  });

  final PhoneCountry selectedCountry;
  final ValueChanged<PhoneCountry> onCountryChanged;
  final TextEditingController controller;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      maxLength: 15,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\s.\-()]')),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? l10n.t('auth.login.phoneHint'),
        counterText: '',
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: PhoneCountryPrefix(
          selectedCountry: selectedCountry,
          onCountryChanged: onCountryChanged,
          enabled: enabled,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
      ),
      validator: validator ??
          (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) {
              return l10n.t('auth.login.phoneRequired');
            }
            if (!isNationalPhoneValid(selectedCountry, text)) {
              return l10n.t('auth.login.phoneInvalid');
            }
            return null;
          },
    );
  }
}
