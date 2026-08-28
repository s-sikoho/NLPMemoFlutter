import '../database/app_database.dart';
import '../models/training_memo.dart';

class TraningMemoRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;
  Future<List<TrainingMemo>> getAllMemos() async {
    final db = await _appDatabase.database;

    final maps = await db.query('memos', orderBy: 'id DESC');

    return maps.map((map) => TrainingMemo.fromMap(map)).toList();
  }

  Future<TrainingMemo?> getMemoById(int id) async {
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

    return TrainingMemo.fromMap(maps.first);
  }

  // カテゴリで絞り込み
  Future<List<TrainingMemo>> getMemosByCategoryId(int categoryId) async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      'memos',
      where: 'categoryid = ?',
      whereArgs: [categoryId],
    );

    return maps.map((map) => TrainingMemo.fromMap(map)).toList();
  }

  // 単語で検索
  Future<List<TrainingMemo>> searchMemos(String keyword) async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      'memos',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );

    return maps.map((map) => TrainingMemo.fromMap(map)).toList();
  }

  Future<int> insertMemo(TrainingMemo memo) async {
    final db = await _appDatabase.database;

    return await db.insert('memos', memo.toMap());
  }

  Future<int> updateMemo(TrainingMemo memo) async {
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
}
