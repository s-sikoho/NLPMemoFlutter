class PresetTrainingMemo {
  final String title;
  final String content;

  PresetTrainingMemo({
    required this.title,
    required this.content,
  });

  factory PresetTrainingMemo.fromJson(Map<String, dynamic> json) {
    return PresetTrainingMemo(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
