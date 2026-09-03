class Memo {
  final int? id;
  final String title;
  final String content;
  final int categoryId;
  final DateTime? scheduledAt;
  final bool notificationEnabled;

  const Memo({
    this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.scheduledAt,
    required this.notificationEnabled,
  });

  factory Memo.fromMap(Map<String, Object?> map) {
    return Memo(
      id: map["id"] as int?,
      title: map["title"] as String,
      content: map["content"] as String,
      categoryId: map["category_id"] as int,
      scheduledAt: map['scheduled_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['scheduled_at'] as int),
      notificationEnabled: (map['notification_enabled'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "category_id": categoryId,
      'scheduled_at': scheduledAt?.millisecondsSinceEpoch,
      'notification_enabled': notificationEnabled ? 1 : 0,
    };
  }
}
