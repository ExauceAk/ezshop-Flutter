/// Endpoints the app talks to.
///
/// Declared with `--dart-define` so a release build can point at production
/// without touching the source:
///
/// ```sh
/// flutter run --dart-define=API_URL=http://10.0.0.5:4024/api/v1 \
///              --dart-define=WEB_URL=http://10.0.0.5:3000
/// ```
///
/// [apiUrl] must include the `/api/v1` prefix, which the Nest app sets as its
/// global route prefix; every path built on top is relative to it.
class AppConfig {
  AppConfig._();

  /// Nest API: auth, shops, products, orders, cart and favorites.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:4024/api/v1',
  );

  /// Next storefront, used for theme previews and public shop pages.
  static const String webUrl = String.fromEnvironment(
    'WEB_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Apex domain a shop subdomain is appended to, shown to the seller.
  static const String shopDomain = String.fromEnvironment(
    'SHOP_DOMAIN',
    defaultValue: 'macketttz.test',
  );

  /// True when the storefront runs on a developer machine.
  ///
  /// A phone on the same Wi-Fi as the dev machine reaches it through its LAN IP;
  /// `*.localhost` only resolves on the machine itself, so the internal
  /// `/shop/<sub>` path is used instead of a subdomain that would fail there.
  static bool get _isLocalDev {
    final hostname = Uri.parse(webUrl).host;
    return hostname == 'localhost' ||
        hostname == '127.0.0.1' ||
        hostname.endsWith('.localhost') ||
        _isPrivateIp(hostname);
  }

  static bool _isPrivateIp(String hostname) {
    return RegExp(r'^10\.\d+\.\d+\.\d+$').hasMatch(hostname) ||
        RegExp(r'^192\.168\.\d+\.\d+$').hasMatch(hostname) ||
        RegExp(r'^172\.(1[6-9]|2\d|3[01])\.\d+\.\d+$').hasMatch(hostname);
  }

  /// Address that opens a shop's storefront.
  ///
  /// On a developer machine it goes through `/shop/<sub>` on the LAN IP, the
  /// only shape a phone can resolve. In production the subdomain is used, so
  /// the seller and their customers read the same address.
  static String shopUrl(String subdomain) {
    if (subdomain.isEmpty) return webUrl;
    final uri = Uri.parse(webUrl);

    if (_isLocalDev) {
      return '${uri.scheme}://${uri.authority}/shop/$subdomain';
    }

    return '${uri.scheme}://$subdomain.$shopDomain';
  }

  /// Pretty address displayed to the seller.
  ///
  /// Mirrors [shopUrl] in development so the link shown is the one that opens,
  /// and stays the bare domain in production.
  static String shopDisplayUrl(String subdomain) {
    if (subdomain.isEmpty) return shopDomain;
    if (_isLocalDev) return shopUrl(subdomain);
    return '$subdomain.$shopDomain';
  }
}