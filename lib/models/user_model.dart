class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  String address;
  String avatarUrl;
  bool hasShop;
  String? shopId;
  List<String> favorites;
  List<String> cartItems;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.avatarUrl = '',
    this.hasShop = false,
    this.shopId,
    this.favorites = const [],
    this.cartItems = const [],
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    bool? hasShop,
    String? shopId,
    List<String>? favorites,
    List<String>? cartItems,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasShop: hasShop ?? this.hasShop,
      shopId: shopId ?? this.shopId,
      favorites: favorites ?? this.favorites,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: '${json['id']}',
      // The API names the display field "username"; the app calls it "name".
      name: json['username']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
    );
  }
}
