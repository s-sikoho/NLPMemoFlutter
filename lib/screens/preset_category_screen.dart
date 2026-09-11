import 'package:flutter/material.dart';

import '../services/preset_category_service.dart';
import '../services/preset_category_import_service.dart';
import '../repositories/category_repository.dart';
import '../models/preset_category.dart';
import '../widgets/preset_card.dart';
import '../services/classifier_service.dart';

class PresetCategoryScreen extends StatefulWidget {
  final ClassifierService classifierService;
  const PresetCategoryScreen({super.key, required this.classifierService});
  @override
  State<PresetCategoryScreen> createState() => _PresetCategoryScreenState();
}

class _PresetCategoryScreenState extends State<PresetCategoryScreen> {
  final PresetCategoryService _presetCategoryService = PresetCategoryService();
  late final PresetCategoryImportService _presetCategoryImportService;
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<PresetCategory> _presets = [];
  Set<String> _addedPresetIds = {};
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _presetCategoryImportService = PresetCategoryImportService(
      _categoryRepository,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final presets = await _presetCategoryService.loadPresets();

    final categories = await _categoryRepository.getAllCategories();

    final addedPresetIds = categories
        .where((category) => category.presetId != null)
        .map((category) => category.presetId!)
        .toSet();

    if (!mounted) {
      return;
    }

    setState(() {
      _presets = presets;
      _addedPresetIds = addedPresetIds;
      _isLoading = false;
    });
  }

  Future<void> _addPreset(PresetCategory preset) async {
    try {
      await _presetCategoryImportService.importPresetCategory(preset);
      await widget.classifierService.train();
      await _loadData();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${preset.name}を追加しました')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('プリセットの追加に失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プリセットを追加')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 220,
              ),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];

                final isAdded = _addedPresetIds.contains(preset.presetId);

                return PresetWidget(
                  preset: preset,
                  isAdded: isAdded,
                  onTap: () {
                    _addPreset(preset);
                  },
                );
              },
            ),
    );
  }
}
