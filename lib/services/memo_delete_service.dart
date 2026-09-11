import '../repositories/memo_repository.dart';
import '../models/memo.dart';
import 'notification_service.dart';
import '../repositories/category_repository.dart';

class MemoDeleteService {
  final MemoRepository _memoRepository = MemoRepository();
  final NotificationService notificationService;
  final CategoryRepository _categoryRepository = CategoryRepository();

  MemoDeleteService({required this.notificationService});
  Future<void> deleteMemo(Memo memo) async {
    final id = memo.id;
    if (id == null) {
      return;
    }
    await notificationService.cancelMemoNotification(id);
    await _categoryRepository.markNeedsTraining(memo.categoryId);
    await _memoRepository.deleteMemo(id);
  }
}
