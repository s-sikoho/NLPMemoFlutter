import '../repositories/category_embedding_repository.dart';
import '../repositories/memo_repository.dart';
import '../repositories/category_repository.dart';

class CategoryDeleteService {
  final CategoryEmbeddingRepository _categoryEmbeddingRepository =
      CategoryEmbeddingRepository();
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  Future<void> deleteCategory(int categoryId) async {
    // 1. 「その他」カテゴリを取得
    final otherCategory = await _categoryRepository.getOtherCategory();

    // 2. 「その他」自体は削除させない
    if (otherCategory.id == categoryId) {
      throw StateError('その他カテゴリは削除できません');
    }

    // 3. 通常メモは削除せず「その他」へ移動
    await _memoRepository.moveToCategory(
      fromCategoryId: categoryId,
      toCategoryId: otherCategory.id!,
    );

    // 4. そのカテゴリの代表embeddingを削除
    await _categoryEmbeddingRepository.deleteByCategoryId(categoryId);

    // 5. 最後にカテゴリ本体を削除
    await _categoryRepository.deleteCategory(categoryId);
  }
}
