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

  /// Address that opens a shop's storefront.
  ///
  /// The subdomain is put in front of the storefront host: `couz.localhost:3000`
  /// on a desktop browser, `couz.10.122.244.88:3000` from a phone on the same
  /// network, `couz.macketttz.test` once the domain is live. A shop only
  /// answers on its own subdomain, never on a path.
  static String shopUrl(String subdomain) {
    if (subdomain.isEmpty) return webUrl;
    final uri = Uri.parse(webUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://$subdomain.${uri.host}$port';
  }

  /// Address shown to the seller, always the one that actually opens.
  static String shopDisplayUrl(String subdomain) {
    if (subdomain.isEmpty) return shopDomain;
    return shopUrl(subdomain);
  }
}