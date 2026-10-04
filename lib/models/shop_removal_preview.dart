/// What deleting a shop would take with it.
///
/// The seller has to see this before confirming: the cascade removes products,
/// orders and ratings, which is not something a single "are you sure?" can
/// convey honestly.
class ShopRemovalPreview {
  const ShopRemovalPreview({
    this.productCount = 0,
    this.orderCount = 0,
    this.ratingCount = 0,
  });

  /// Listings that will disappear.
  final int productCount;

  /// Orders received by the shop, deleted with it.
  final int orderCount;

  /// Ratings left on the shop.
  final int ratingCount;

  factory ShopRemovalPreview.fromJson(Map<String, dynamic> json) {
    return ShopRemovalPreview(
      productCount: _asInt(json['productCount']),
      orderCount: _asInt(json['orderCount']),
      ratingCount: _asInt(json['ratingCount']),
    );
  }

  /// True when the shop holds nothing, so the dialog can stay short instead of
  /// listing zeros.
  bool get isEmpty =>
      productCount == 0 && orderCount == 0 && ratingCount == 0;

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}