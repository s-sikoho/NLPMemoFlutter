class Category {
  final int? id;
  final String name;
  final bool isOther;
  final int color;

  const Category({this.id, required this.name, required this.isOther, required this.color,});

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map["id"] as int?,
      name: map["name"] as String,
      isOther: (map['is_other'] as int) == 1,
      color: map['color'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {"id": id, "name": name, 'is_other': isOther ? 1 : 0, 'color': color,};
  }
}
