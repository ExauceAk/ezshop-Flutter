/// Endpoints the app talks to.
///
/// Declared with `--dart-define` so a release build can point at production
/// without touching the source:
///
/// ```sh
/// flutter run --dart-define=API_URL=https://api.macketttz.test \
///              --dart-define=WEB_URL=https://macketttz.test
/// ```
class AppConfig {
  AppConfig._();

  /// Nest API, used for the theme catalog.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:4024',
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

  /// Public address of a shop, e.g. `https://techzone.macketttz.test`.
  static String shopUrl(String subdomain) {
    if (subdomain.isEmpty) return webUrl;
    // A real subdomain resolves straight to the storefront on every platform,
    // so it is preferred over the /shop/<subdomain> path.
    return '$webUrl/$subdomain';
  }
}