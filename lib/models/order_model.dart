class OrderItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.imageUrl,
  });

  double get total => productPrice * quantity;

  static double readAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: '${json['productId']}',
      productName: json['productName']?.toString() ?? '',
      productPrice: readAmount(json['productPrice']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime date;
  final String status; // 'pending', 'shipped', 'delivered', 'cancelled'

  /// Shop the order was placed against, so a seller can group by shop.
  final String shopId;

  /// Shop name at the time of the order.
  final String shopName;

  /// Buyer, only sent on the orders a seller received.
  final String buyerName;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = 'pending',
    this.shopId = '',
    this.shopName = '',
    this.buyerName = '',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // The buyer is nested on the received-orders route and absent on the
    // buyer's own list, so it is read defensively.
    final user = json['user'];

    return Order(
      id: '${json['id']}',
      items: (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(OrderItem.fromJson)
              .toList() ??
          const [],
      totalAmount: OrderItem.readAmount(json['totalAmount']),
      // The order payload exposes no creation date, only the last update, so
      // that stands in for it.
      date: DateTime.tryParse('${json['createdAt'] ?? json['updatedAt']}') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      shopId: json['shopId']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      buyerName: user is Map
          ? (user['username']?.toString() ?? user['name']?.toString() ?? '')
          : '',
    );
  }
}
