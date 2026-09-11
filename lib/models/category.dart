class Category {
  final int? id;
  final String name;
  final bool isOther;
  final int color;
  final String? presetId;
  final bool needsTraining;

  const Category({this.id, required this.name, required this.isOther, required this.color,this.presetId,this.needsTraining = true,});

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map["id"] as int?,
      name: map["name"] as String,
      isOther: (map['is_other'] as int) == 1,
      color: map['color'] as int,
      presetId: map['preset_id']as String?,
      needsTraining: map['needs_training'] == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {"id": id, "name": name, 'is_other': isOther ? 1 : 0, 'color': color, 'preset_id':presetId,'needs_training': needsTraining ? 1 : 0,};
  }
}
