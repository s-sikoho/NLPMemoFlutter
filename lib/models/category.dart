class Category {
  final int? id;
  final String name;
  final bool isOther;

  const Category({this.id, required this.name, required this.isOther});

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map["id"] as int?,
      name: map["name"] as String,
      isOther: (map['isOther'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {"id": id, "name": name, 'isOther': isOther ? 1 : 0,};
  }
}
