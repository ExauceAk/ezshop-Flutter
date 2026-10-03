import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// A storefront theme offered when a seller creates or edits a shop.
///
/// Themes are defined and rendered by the Next app; this model only carries
/// what the picker needs to display them, fetched from `GET /api/themes`.
class ShopTheme {
  const ShopTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.swatch,
  });

  final String id;
  final String name;
  final String description;

  /// Representative image shown on the picker card.
  final String previewImage;

  /// Three theme colours, drawn as dots on the picker card.
  final List<String> swatch;

  factory ShopTheme.fromJson(Map<String, dynamic> json) {
    return ShopTheme(
      id: json['id'] as String? ?? 'atelier',
      name: json['name'] as String? ?? 'Standard',
      description: json['description'] as String? ?? '',
      previewImage: json['previewImage'] as String? ?? '',
      swatch:
          (json['swatch'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              const [],
    );
  }

  /// Parses a `#RRGGBB` string, falling back to a neutral grey so a malformed
  /// swatch never crashes the picker.
  Color colorAt(int index) {
    if (index >= swatch.length) return const Color(0xFFE9ECEF);
    final hex = swatch[index].replaceFirst('#', '');
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFFE9ECEF);
    return Color(0xFF000000 | value);
  }

  /// The primary colour of the theme, used to tint the seller-facing UI so the
  /// app reflects the choice they just made.
  Color get primaryColor => colorAt(0);

  /// URL of the real storefront preview, with the seller's current input passed
  /// along so what they see is exactly what will be published.
  ///
  /// @param name - Shop name being typed
  /// @param description - Shop description being typed
  /// @param config - The custom hero / about / footer texts
  String previewUrl({
    required String name,
    required String description,
    String slug = '',
    String? logoUrl,
    String? bannerUrl,
    Map<String, String?> config = const {},
  }) {
    final params = <String, String>{
      'name': name,
      'description': description,
      'slug': slug,
      if (logoUrl != null && logoUrl.isNotEmpty) 'logo': logoUrl,
      if (bannerUrl != null && bannerUrl.isNotEmpty) 'banner': bannerUrl,
      // Overrides may be null when a field is left blank; drop those so the
      // theme keeps its own default.
      for (final entry in config.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    final query = params.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final base = '${AppConfig.webUrl}/preview/$id';
    return query.isEmpty ? base : '$base?$query';
  }
}