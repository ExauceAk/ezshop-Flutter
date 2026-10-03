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