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

  /// Address that actually opens a shop's storefront.
  ///
  /// The pretty `<subdomain>.<domain>` form only resolves when DNS points at
  /// this server, so it is only shown as text. Opening the shop uses the
  /// `/shop/<subdomain>` path instead: it reaches the same page from the app
  /// and from a phone, where the host is a bare IP and no subdomain can be
  /// derived from it.
  static String shopUrl(String subdomain) {
    if (subdomain.isEmpty) return webUrl;
    return '$webUrl/shop/$subdomain';
  }

  /// Pretty address displayed to the seller, e.g. `techzone.macketttz.test`.
  static String shopDisplayUrl(String subdomain) {
    if (subdomain.isEmpty) return shopDomain;
    return '$subdomain.$shopDomain';
  }
}