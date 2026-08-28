class TrainingMemo {
  final int? id;
  final String title;
  final String content;
  final int categoryId;

  const TrainingMemo({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
  });

  factory TrainingMemo.fromMap(Map<String, Object?> map) {
    return TrainingMemo(
      id: map["id"] as int?,
      title: map["title"] as String,
      content: map["content"] as String,
      categoryId: map["category_id"] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "category_id": categoryId,
    };
  }
}
