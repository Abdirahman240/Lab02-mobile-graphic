import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/shopping_item.dart';

class ShoppingItemDao {
  static final ShoppingItemDao instance = ShoppingItemDao._internal();

  static Database? _database;

  ShoppingItemDao._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _createDatabase();
    return _database!;
  }

  Future<Database> _createDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'shopping_items.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await database.execute(
          '''
          CREATE TABLE shopping_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL
          )
          ''',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'ALTER TABLE shopping_items ADD COLUMN quantity INTEGER NOT NULL DEFAULT 1',
          );
        }
      },
    );
  }

  Future<int> insertItem(ShoppingItem item) async {
    final db = await database;

    return db.insert(
      'shopping_items',
      {
        'name': item.name,
        'quantity': item.quantity,
      },
    );
  }

  Future<List<ShoppingItem>> getAllItems() async {
    final db = await database;

    final maps = await db.query(
      'shopping_items',
      orderBy: 'id ASC',
    );

    return maps.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<int> deleteItem(int id) async {
    final db = await database;

    return db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}