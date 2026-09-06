import '../repositories/memo_repository.dart';
import '../models/memo.dart';
import '../repositories/category_repository.dart';
import 'notification_service.dart';

class MemoSaveService {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final NotificationService notificationService;
  MemoSaveService({
    required this.notificationService,
  });

  Future<int> insertMemo(Memo memo) async {
    final category = await _categoryRepository.getCategoryById(memo.categoryId);

    if (category == null) {
      throw StateError('存在しないカテゴリです');
    }

    if (memo.notificationEnabled && memo.scheduledAt == null) {
      throw StateError('通知を有効にする場合は日時が必要です');
    }

    final id = await _memoRepository.insertMemo(memo);

    if (memo.notificationEnabled && memo.scheduledAt != null) {
      final savedMemo = await _memoRepository.getMemoById(id);
      if (savedMemo == null) {
        throw StateError('保存したメモを取得できませんでした');
      }
      await notificationService.scheduleMemoNotification(savedMemo);
    }
    return id;
  }

  Future<void> updateMemo(Memo memo) async {
    final category = await _categoryRepository.getCategoryById(memo.categoryId);

    if (category == null) {
      throw StateError('存在しないカテゴリです');
    }

    if (memo.id == null) {
      throw StateError('更新対象のメモIDがありません');
    }

    if (memo.notificationEnabled && memo.scheduledAt == null) {
      throw StateError('通知を有効にする場合は日時が必要です');
    }

    await _memoRepository.updateMemo(memo);

    await notificationService.cancelMemoNotification(memo.id!);

    if (memo.notificationEnabled && memo.scheduledAt != null) {
      await notificationService.scheduleMemoNotification(memo);
    }
  }
}
