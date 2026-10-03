class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: '${json['id']}',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'category',
      color: json['color']?.toString() ?? '#4A90D9',
    );
  }
}
