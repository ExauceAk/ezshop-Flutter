import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Error raised by [ApiClient] when the API answers with a failure status.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errors});

  /// Message safe to show to the user, already in French.
  final String message;

  /// HTTP status, or null when the request never reached the server.
  final int? statusCode;

  /// Per-field validation messages returned by the API, when present.
  final Map<String, String>? errors;

  /// True when the API could not be reached at all, as opposed to refusing the
  /// request. The UI uses this to tell "wrong password" from "server down".
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP transport for the Nest API.
///
/// Owns three things the rest of the app should not repeat: the base URL, the
/// bearer token, and the `{ statusCode, data }` envelope every Nest endpoint
/// wraps its payload in.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 15);
  static const _refreshTimeout = Duration(seconds: 10);
  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';

  final http.Client _client;

  String? _accessToken;
  String? _refreshToken;

  /// Guards against parallel refreshes: several requests can hit a 401 at the
  /// same time, and without this they would each burn the one-shot refresh
  /// token and invalidate the session.
  Future<bool>? _refreshInFlight;

  bool get hasSession => _accessToken != null;

  /// Current bearer token, needed by callers that build their own requests,
  /// such as the multipart image upload.
  String? get accessToken => _accessToken;

  /// Restores a session saved by a previous run, if any.
  ///
  /// Called once at startup so a returning user stays signed in.
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  /// Stores a token pair obtained from login or registration.
  ///
  /// Called by [MarketApi] consumers through the provider, so the client stays
  /// the only place tokens live.
  Future<void> adoptSession(String access, String refresh) =>
      _saveSession(access, refresh);

  Future<void> _saveSession(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = AppConfig.apiUrl.endsWith('/')
        ? AppConfig.apiUrl.substring(0, AppConfig.apiUrl.length - 1)
        : AppConfig.apiUrl;
    final cleaned = query == null
        ? path
        : '$path?${Uri(queryParameters: query.map((k, v) => MapEntry(k, '$v'))).query}';
    return Uri.parse('$base$cleaned');
  }

  /// Performs a request and returns the unwrapped `data` payload.
  ///
  /// Throws [ApiException] on any non-2xx status or transport failure.
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool authenticated = true,
  }) async {
    var response = await _send(method, path, query: query, body: body, authenticated: authenticated);

    // A 401 means the access token expired: refresh once, then replay. The
    // replay is not authenticated-aware to avoid recursing through refresh.
    if (response.statusCode == 401 && authenticated) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        response = await _send(method, path, query: query, body: body, authenticated: true);
      } else {
        await clearSession();
      }
    }

    return _unwrap(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required bool authenticated,
  }) async {
    final uri = _uri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    try {
      switch (method) {
        case 'GET':
          return await _client.get(uri, headers: headers).timeout(_timeout);
        case 'POST':
          return await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
        case 'PATCH':
          return await _client
              .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
        case 'DELETE':
          return await _client.delete(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(_timeout);
        default:
          throw ApiException('Méthode HTTP non supportée : $method');
      }
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre.');
    } catch (e) {
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez qu\'il est démarré et que l\'adresse est correcte.',
      );
    }
  }

  /// Exchanges the refresh token for a new access token.
  ///
  /// Returns false when there is no refresh token or the server rejects it,
  /// which means the session is over.
  Future<bool> _refreshSession() async {
    final token = _refreshToken;
    if (token == null) return false;

    // Collapse concurrent refreshes onto a single request.
    final pending = _refreshInFlight;
    if (pending != null) return pending;

    final future = _doRefresh(token);
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _doRefresh(String token) async {
    try {
      final response = await _client
          .post(
            _uri('/auth/refresh'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'refreshToken': token}),
          )
          .timeout(_refreshTimeout);

      if (response.statusCode != 200) return false;

      final data = _decodedData(response);
      if (data is! Map<String, dynamic>) return false;

      await _saveSession(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Unwraps the `{ statusCode, data }` envelope and converts failures into
  /// [ApiException].
  dynamic _unwrap(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }

    final map = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};

    // Validation errors come as { message: 'Validation failed', errors: { field: [...] } }.
    final rawErrors = map['errors'];
    if (rawErrors is Map) {
      final parsed = <String, String>{};
      rawErrors.forEach((key, value) {
        parsed['$key'] = value is List && value.isNotEmpty ? '${value.first}' : '$value';
      });
      throw ApiException(
        _messageFor(map, 'Certaines informations sont invalides.'),
        statusCode: response.statusCode,
        errors: parsed,
      );
    }

    throw ApiException(
      _messageFor(map, 'Une erreur est survenue.'),
      statusCode: response.statusCode,
    );
  }

  /// Pulls the `data` out of a refresh response, reusing the same envelope rule.
  dynamic _decodedData(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  /// Prefers the server message, but falls back to a generic one: some errors
  /// (401 on a guard, 500) carry no useful text.
  String _messageFor(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    if (body['statusCode'] == 401) return 'Session expirée, reconnectez-vous.';
    if (body['statusCode'] == 403) return 'Action non autorisée.';
    if (body['statusCode'] == 404) return 'Ressource introuvable.';

    return fallback;
  }

  void dispose() => _client.close();
}