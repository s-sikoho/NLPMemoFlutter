import '../repositories/memo_repository.dart';
import '../models/memo.dart';
import '../repositories/category_repository.dart';
class MemoService {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<int> insertMemo(Memo memo) async {
    final category =
        await _categoryRepository.getCategoryById(memo.categoryid);

    if (category == null) {
      throw StateError('存在しないカテゴリです');
    }

    return await _memoRepository.insertMemo(memo);
  }

  Future<void> updateMemo(Memo memo) async {
    final category =
        await _categoryRepository.getCategoryById(memo.categoryid);

    if (category == null) {
      throw StateError('存在しないカテゴリです');
    }

    await _memoRepository.updateMemo(memo);
  }
}