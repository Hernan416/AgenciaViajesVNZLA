class Category {
  final int id;
  final String name;
  final String iconKey;

  Category({required this.id, required this.name, required this.iconKey});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      iconKey: map['icon_key'] ?? 'place',
    );
  }
}