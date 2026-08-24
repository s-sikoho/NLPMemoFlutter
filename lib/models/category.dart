class Category {
  final int? id;
  final String name;
  final bool isOther;

  const Category({
    this.id,
    required this.name,
    required this.isOther,
  });

  factory Category.fromMap(
    Map<String, Object?> map,
  ) {
    return Category(
      id: map["id"] as int?,
      name: map["name"] as String,
      isOther: map["is_system"] as bool,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "name": name,
      "is_system": isOther,
    };
  }
}