import '../database/app_database.dart';
import '../models/category.dart';

class CategoryRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<List<Category>> getAllCategories() async {
    final db = await _appDatabase.database;

    final maps = await db.query(
      'categories',
      orderBy: 'id ASC',
    );

    return maps
        .map((map) => Category.fromMap(map))
        .toList();
  }

  Future<Category?>getCategoryById(int id)async{
    final db = await _appDatabase.database;

    final maps = await db.query(
      'categoryis',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }
     return Category.fromMap(maps.first);
  }

  Future<int> insertCategory(Category category) async {
    final db = await _appDatabase.database;

    return await db.insert(
      'categories',
      category.toMap(),
    );
  }

  Future<int> deleteCategory(int id) async {
  final category = await getCategoryById(id);

  if (category == null) {
    throw StateError('Category not found.');
  }

  if (category.isOther) {
    throw StateError('Other category cannot be deleted.');
  }

  final db = await AppDatabase.instance.database;

  return db.delete(
    'categories',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}