import '../database/app_database.dart';
import '../models/category_embedding.dart';
import 'package:sqflite/sqflite.dart';

class CategoryEmbeddingRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<List<CategoryEmbedding>> getAll() async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      'category_embeddings',
    );

    return rows
        .map((row) => CategoryEmbedding.fromMap(row))
        .toList();
  }

  Future<CategoryEmbedding?> getByCategoryId(
    int categoryId,
  ) async {
    final db = await _appDatabase.database;

    final rows = await db.query(
      'category_embeddings',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CategoryEmbedding.fromMap(rows.first);
  }

  Future<void> save(
    CategoryEmbedding categoryEmbedding,
  ) async {
    final db = await _appDatabase.database;

    await db.insert(
      'category_embeddings',
      categoryEmbedding.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteByCategoryId(
    int categoryId,
  ) async {
    final db = await _appDatabase.database;

    await db.delete(
      'category_embeddings',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<void> deleteAll() async {
    final db = await _appDatabase.database;

    await db.delete(
      'category_embeddings',
    );
  }

  Future<bool> existsAny() async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM category_embeddings',
    );

    final count = Sqflite.firstIntValue(result) ?? 0;

    return count > 0;
  }
}