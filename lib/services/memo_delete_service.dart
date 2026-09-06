import '../repositories/memo_repository.dart';
import '../models/memo.dart';
import 'notification_service.dart';
class MemoDeleteService {
  final MemoRepository _memoRepository = MemoRepository();
  final NotificationService notificationService;

  MemoDeleteService({
    required this.notificationService,
  });
  Future<void> deleteMemo(Memo memo) async {
    final id = memo.id;
    if (id == null) {
      return;
    }
    await notificationService.cancelMemoNotification(id);
    await _memoRepository.deleteMemo(id);
  }
}
