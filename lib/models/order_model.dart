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
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime date;
  final String status; // 'pending', 'shipped', 'delivered', 'cancelled'

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = 'pending',
  });
}
