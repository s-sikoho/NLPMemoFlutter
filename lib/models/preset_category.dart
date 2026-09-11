import 'preset_trainingmemo.dart';

class PresetCategory {
  final String presetId;
  final String name;
  final int color;
  final List<PresetTrainingMemo> trainingMemos;

  PresetCategory({
    required this.presetId,
    required this.name,
    required this.color,
    required this.trainingMemos,
  });

  factory PresetCategory.fromJson(Map<String, dynamic> json) {
    return PresetCategory(
      presetId: json['presetId'] as String,
      name: json['name'] as String,
      color: json['color'] as int,
      trainingMemos: (json['trainingMemos'] as List<dynamic>)
          .map(
            (memoJson) =>
                PresetTrainingMemo.fromJson(memoJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
