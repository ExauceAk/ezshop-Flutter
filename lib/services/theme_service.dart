import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/shop_theme.dart';

/// Loads the storefront theme catalog from the Next app.
///
/// The themes are hardcoded in `next/lib/shop/themes.ts`, so the app asks that
/// app for them instead of keeping its own list: adding a theme there makes it
/// appear in the picker with no Dart change.
class ThemeService {
  ThemeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  List<ShopTheme>? _cache;

  /// Returns the catalog, or an empty list if the storefront cannot be reached.
  ///
  /// A network failure must not block shop creation, so the caller gets an
  /// empty list and falls back to a single built-in theme.
  Future<List<ShopTheme>> fetchThemes() async {
    if (_cache != null) return _cache!;

    try {
      final response = await _client
          .get(Uri.parse('${AppConfig.webUrl}/api/themes'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>? ?? []);

      final themes = list
          .map((e) => ShopTheme.fromJson(e as Map<String, dynamic>))
          .toList();

      _cache = themes;
      return themes;
    } catch (_) {
      // Offline or the storefront is not running: return nothing rather than
      // crashing, the picker falls back to its built-in theme.
      return const [];
    }
  }

  void dispose() => _client.close();
}