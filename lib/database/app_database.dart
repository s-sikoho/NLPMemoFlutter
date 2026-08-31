import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'dart:convert';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB("memo.db");

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_other INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE category_embeddings(
        category_id INTEGER PRIMARY KEY,
        embedding BLOB NOT NULL,
        FOREIGN KEY (category_id)
          REFERENCES categories(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE memos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE training_memos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category_id INTEGER NOT NULL
      )
    ''');

    await db.insert("categories", {
      "id": 0,
      "name": "その他",
      "is_other": 1,
      "color": Colors.white.toARGB32(),
    });
    await db.insert("categories", {
      "id": 1,
      "name": "大学",
      "is_other": 0,
      "color": Colors.orange.toARGB32(),
    });
    await db.insert("categories", {
      "id": 2,
      "name": "生活",
      "is_other": 0,
      "color": Colors.pink.toARGB32(),
    });
    await db.insert("categories", {
      "id": 3,
      "name": "情報",
      "is_other": 0,
      "color": Colors.purple.toARGB32(),
    });

    final jsonString = await rootBundle.loadString(
      'assets/data/default_training_data.json',
    );
    final List<dynamic> data = jsonDecode(jsonString);

    for (final item in data) {
      await db.insert('training_memos', {
        'title': item['title'],
        'content': item['content'],
        'category_id': item['categoryId'],
      });
    }
  }
}
