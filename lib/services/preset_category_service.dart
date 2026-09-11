import '../models/preset_category.dart';

import 'package:flutter/services.dart';

import 'dart:convert';

class PresetCategoryService {
  Future<List<PresetCategory>> loadPresets() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/preset_categories.json',
    );

    final List<dynamic> data = jsonDecode(jsonString);

    final presets = data
        .map((item) => PresetCategory.fromJson(item as Map<String, dynamic>))
        .toList();

    return presets;
  }
}
