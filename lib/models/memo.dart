class Memo {
  final int? id;
  final String title;
  final String content;
  final int categoryid;

  const Memo({
    this.id,
    required this.title,
    required this.content,
    required this.categoryid,
  });

  factory Memo.fromMap(
    Map<String, Object?> map,
  ) {
    return Memo(
      id: map["id"] as int?,
      title: map["title"] as String,
      content: map["content"] as String,
      categoryid: map["category_d"] as int,
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