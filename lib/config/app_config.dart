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
  /// Uses the real subdomain so the seller sees the address their customers
  /// will type, and `proxy.ts` resolves it to the same page as `/shop/<sub>`.
  static String shopUrl(String subdomain) {
    if (subdomain.isEmpty) return webUrl;
    final scheme = Uri.parse(webUrl).scheme;
    final port = Uri.parse(webUrl).port;
    // `.localhost` resolves to the loopback in every browser, so
    // `techzone.localhost:3000` works locally exactly like the production
    // subdomain will.
    return '$scheme://$subdomain.localhost:$port';
  }

  /// Pretty address displayed to the seller, e.g. `techzone.macketttz.test`.
  static String shopDisplayUrl(String subdomain) {
    if (subdomain.isEmpty) return shopDomain;
    return '$subdomain.$shopDomain';
  }
}