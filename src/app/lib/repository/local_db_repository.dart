import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../domain/store_item.dart';


class LocalDBRepository {
  final Database database;
  int id = 0;


  LocalDBRepository(this.database) {
    database.query('Item', orderBy: 'id DESC').then((value) {
      if (value.isNotEmpty) {
        id = value.first['id'] as int;
      }
    });
  }


  static Future<LocalDBRepository> create() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'store_inventory.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE Item (
             id INTEGER PRIMARY KEY,
             name TEXT NOT NULL,
             quantity INTEGER NOT NULL,
             cost INTEGER NOT NULL,
             supplier TEXT NOT NULL,
             expiration_date TEXT NOT NULL
          )''',
        );

        await db.execute(
          '''CREATE TABLE LocalAdd (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             item_id INTEGER NOT NULL,
             name TEXT NOT NULL,
             quantity INTEGER NOT NULL,
             cost INTEGER NOT NULL,
             supplier TEXT NOT NULL,
             expiration_date TEXT NOT NULL
          )''',
        );

        await db.execute(
          '''CREATE TABLE LocalUpdate (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             item_id INTEGER NOT NULL,
             name TEXT NOT NULL,
             quantity INTEGER NOT NULL,
             cost INTEGER NOT NULL,
             supplier TEXT NOT NULL,
             expiration_date TEXT NOT NULL
          )''',
        );

        await db.execute(
          '''CREATE TABLE LocalRemove (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             item_id INTEGER NOT NULL
          )''',
        );
      },
      version: 1,
    );
    return LocalDBRepository(database);
  }


  Future<List<StoreItem>> getItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('Item');
      return List.generate(maps.length, (i) {
        return StoreItem(
          providedId: maps[i]['id'],
          name: maps[i]['name'],
          quantity: maps[i]['quantity'],
          cost: maps[i]['cost'],
          supplier: maps[i]['supplier'],
          expirationDate: maps[i]['expiration_date'],
        );
      });
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }


  Future<StoreItem> addItem(StoreItem item, {bool log = true}) async {
    try {
      id += 1;
      await database.insert(
        'Item',
        {
          'id': id,
          'name': item.name,
          'quantity': item.quantity,
          'cost': item.cost,
          'supplier': item.supplier,
          'expiration_date': item.expirationDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (log) {
        await database.insert(
          'LocalAdd',
          {
            'item_id': id,
            'name': item.name,
            'quantity': item.quantity,
            'cost': item.cost,
            'supplier': item.supplier,
            'expiration_date': item.expirationDate,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return StoreItem(
        providedId: id,
        name: item.name,
        quantity: item.quantity,
        cost: item.cost,
        supplier: item.supplier,
        expirationDate: item.expirationDate,
      );
    } catch (e) {
      throw Exception('Error adding item: $e');
    }
  }


  Future<void> removeItem(int id, {bool log = true}) async {
    try {
      await database.delete(
        'Item',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (log) {
        final rowsDeleted = await database.delete(
          'LocalAdd',
          where: 'item_id = ?',
          whereArgs: [id],
        );

        if (rowsDeleted == 0) {
          await database.insert(
              'LocalRemove',
              {
                'item_id': id,
              },
              conflictAlgorithm: ConflictAlgorithm.replace
          );
        }

        await database.delete(
          'LocalUpdate',
          where: 'item_id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      throw Exception('Error removing item: $e');
    }
  }


  Future<StoreItem> updateItem(StoreItem item, {bool log = true}) async {
    try {
      await database.update(
        'Item',
        {
          'name': item.name,
          'quantity': item.quantity,
          'cost': item.cost,
          'supplier': item.supplier,
          'expiration_date': item.expirationDate,
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );

      if (log) {
        await database.delete(
          'LocalUpdate',
          where: 'item_id = ?',
          whereArgs: [item.id],
        );

        final rowsDeleted = await database.delete(
          'LocalAdd',
          where: 'item_id = ?',
          whereArgs: [item.id],
        );

        if (rowsDeleted == 0) {
          await database.insert(
              'LocalUpdate',
              {
                'item_id': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'cost': item.cost,
                'supplier': item.supplier,
                'expiration_date': item.expirationDate,
              },
              conflictAlgorithm: ConflictAlgorithm.replace
          );
        }

        else {
          await database.insert(
              'LocalAdd',
              {
                'item_id': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'cost': item.cost,
                'supplier': item.supplier,
                'expiration_date': item.expirationDate,
              },
              conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
      }

      final updatedItem = await searchItem(item.id);
      if (updatedItem == null) {
        throw Exception('Item not found');
      }

      return updatedItem;
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }


  Future<StoreItem?> searchItem(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'Item',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final row = maps.first;
        return StoreItem(
          providedId: row['id'],
          name: row['name'],
          quantity: row['quantity'],
          cost: row['cost'],
          supplier: row['supplier'],
          expirationDate: row['expiration_date'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error searching for item: $e');
    }
  }


  Future<List<List<Map<String, dynamic>>>?> getSynchronizationLogs() async {
    try {
      final List<Map<String, dynamic>> addLogs = await database.query('LocalAdd');
      final List<Map<String, dynamic>> updateLogs = await database.query('LocalUpdate');
      final List<Map<String, dynamic>> removeLogs = await database.query('LocalRemove');

      return [addLogs, updateLogs, removeLogs];
    } catch (e) {
      throw Exception('Error fetching synchronization logs: $e');
    }
  }


  Future<void> clearSynchronizationLogs() async {
    try {
      await database.delete('LocalAdd');
      await database.delete('LocalUpdate');
      await database.delete('LocalRemove');
    } catch (e) {
      throw Exception('Error clearing synchronization logs: $e');
    }
  }


  Future<void> syncWithRemote(List<StoreItem> items) async {
    await database.delete('Item');

    for (final item in items) {
      await database.insert(
        'Item',
        {
          'id': item.id,
          'name': item.name,
          'quantity': item.quantity,
          'cost': item.cost,
          'supplier': item.supplier,
          'expiration_date': item.expirationDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}

