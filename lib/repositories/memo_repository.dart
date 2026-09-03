import '../database/app_database.dart';
import '../models/memo.dart';

class MemoRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  //memoを全て取得
  Future<List<Memo>> getAllMemos() async {
    final db = await _appDatabase.database;
    final maps = await db.query('memos', orderBy: 'id DESC');
    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  //メモをidで取得
  Future<Memo?> getMemoById(int id) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return Memo.fromMap(maps.first);
  }

  //メモを保存(通知機能がonなのにscheduledAtがnullのメモは弾く)
  Future<int> insertMemo(Memo memo) async {
    if (memo.notificationEnabled && memo.scheduledAt == null) {
      throw ArgumentError('通知を有効にする場合は scheduledAt が必要です');
    }
    final db = await _appDatabase.database;
    return await db.insert('memos', memo.toMap());
  }

  //メモを更新
  Future<int> updateMemo(Memo memo) async {
    if (memo.notificationEnabled && memo.scheduledAt == null) {
      throw ArgumentError('通知を有効にする場合は scheduledAt が必要です');
    }
    final db = await _appDatabase.database;
    return await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  //メモを削除
  Future<int> deleteMemo(int id) async {
    final db = await _appDatabase.database;

    return await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  //絞り込んだメモを取得
  Future<List<Memo>> getFilteredMemos({
    int? categoryId,
    String? keyword,
  }) async {
    final db = await AppDatabase.instance.database;
    final whereParts = <String>[];
    final whereArgs = <Object?>[];
    if (categoryId != null) {
      whereParts.add('category_id = ?');
      whereArgs.add(categoryId);
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      whereParts.add('(title LIKE ? OR content LIKE ?)');
      whereArgs.add('%${keyword.trim()}%');
      whereArgs.add('%${keyword.trim()}%');
    }
    final maps = await db.query(
      'memos',
      where: whereParts.isEmpty ? null : whereParts.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id DESC',
    );
    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  // カテゴリで絞り込み
  Future<List<Memo>> getMemosByCategoryId(int categoryId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'memos',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  // 単語で検索
  Future<List<Memo>> searchMemos(String keyword) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'memos',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => Memo.fromMap(map)).toList();
  }

  //スケジュール付きメモを絞り込み
  Future<List<Memo>> searchScheduledMemos() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'memos',
      where: 'scheduled_at IS NOT NULL',
      orderBy: 'scheduled_at ASC',
    );
    return maps.map(Memo.fromMap).toList();
  }

  //通知付きメモを絞り込み
  Future<List<Memo>> searchNotificationMemos() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'memos',
      where: '''
      scheduled_at IS NOT NULL
      AND notification_enabled = ?
    ''',
      whereArgs: [1],
      orderBy: 'scheduled_at ASC',
    );
    return maps.map(Memo.fromMap).toList();
  }

  //メモのカテゴリを変更
  Future<void> moveToCategory({
    required int fromCategoryId,
    required int toCategoryId,
  }) async {
    final db = await _appDatabase.database;
    await db.update(
      'memos',
      {'category_id': toCategoryId},
      where: 'category_id = ?',
      whereArgs: [fromCategoryId],
    );
  }
}
