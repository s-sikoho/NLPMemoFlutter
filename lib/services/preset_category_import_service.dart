import '../models/preset_category.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class PresetCategoryImportService {
  final CategoryRepository _categoryRepository;

  PresetCategoryImportService(this._categoryRepository);

  Future<int?> importPresetCategory(
    PresetCategory preset,
  ) async {
    final categories =
        await _categoryRepository.getAllCategories();

    for (final category in categories) {
      if (category.presetId == preset.presetId) {
        // すでに追加済み
        return category.id;
      }
    }

    // 未登録なので追加
    final categoryId = await _categoryRepository.insertCategory(
      Category(
        name: preset.name,
        isOther: false,
        presetId: preset.presetId,
        color: preset.color,
      ),
    );

    return categoryId;
  }
}