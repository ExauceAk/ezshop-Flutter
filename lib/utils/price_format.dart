import 'package:intl/intl.dart';

/// Prices are shown in CFA francs, matching the public storefront.
///
/// The currency symbol is written after the amount the French way, and the
/// thousands separators are normalised to plain spaces so every screen lines up.
final NumberFormat _cfaFormat = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: 'FCFA',
  decimalDigits: 0,
);

String formatPrice(double value) =>
    _cfaFormat.format(value).replaceAll(RegExp('[\u00a0\u202f\u2007]'), ' ');