class Category {
  final int? id;
  final String name;
  final bool isSystem;

  const Category({
    this.id,
    required this.name,
    required this.isSystem,
  });

  factory Category.fromMap(
    Map<String, Object?> map,
  ) {
    return Category(
      id: map["id"] as int?,
      name: map["name"] as String,
      isSystem: map["is_system"] as bool,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "is_system": isSystem,
    };
  }
}