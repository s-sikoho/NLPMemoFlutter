import '../database/app_database.dart';
import '../models/memo.dart';

class MemoRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<List<Memo>> getAllMemos() async {
    final db = await _appDatabase.database;

    final maps = await db.query('memos', orderBy: 'id DESC');

    return maps.map((map) => Memo.fromMap(map)).toList();
  }

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

  Future<int> insertMemo(Memo memo) async {
    final db = await _appDatabase.database;

    return await db.insert('memos', memo.toMap());
  }

  Future<int> updateMemo(Memo memo) async {
    final db = await _appDatabase.database;

    return await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  Future<int> deleteMemo(int id) async {
    final db = await _appDatabase.database;

    return await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

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
