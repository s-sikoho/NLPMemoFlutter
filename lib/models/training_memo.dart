class TrainingMemo {
  final int? id;
  final String title;
  final String content;
  final int categoryid;

  const TrainingMemo({
    this.id,
    required this.title,
    required this.content,
    required this.categoryid,
  });

  factory TrainingMemo.fromMap(Map<String, Object?> map) {
    return TrainingMemo(
      id: map["id"] as int?,
      title: map["title"] as String,
      content: map["content"] as String,
      categoryid: map["categoryid"] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "categoryid": categoryid,
    };
  }
}
