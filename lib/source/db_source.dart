import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../exceptions/custom_exception/local_db_exception.dart';

class DBSource {
  static final DBSource instance = DBSource._init();
  static Database? _database;

  DBSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(filePath: 'demo.db', createQueries: RiverpodCleanArchitecture.createQueryList);
    return _database!;
  }

  Future<Database> _initDB({
    required String filePath,
    required List<String> createQueries
  }) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: (db, version) => _createDB(
        db,
        version,
        createQueries, /// 테이블 생성을 위한 쿼리들은 여기에 위치 시킴
      ),
    );
  }

  Future _createDB(Database db, int version, List<String> queries) async {
    for(String query in queries) {
      await db.execute(query);
    }
  }

  /**
   *  await dbHelper.executeInsert(
      tableName: 'DriveDetails',
      data: {
      'driveId': 1,
      'timestamp': "2024-05-01T12:00:00Z",
      'latitude': 37.7749,
      'longitude': -122.4194,
      'speed': 55.0,
      'event': "start"
      }
      );
   * */
  Future<int> executeInsert({required String tableName, required Map<String, dynamic> data}) async {
    try {
      final db = await instance.database;
      return await db.insert(tableName, data);
    } catch(e, s) {
    	throw InsertFailException(tableName: tableName, stackTrace: s, errorMsg: e.toString());
    }
  }

  /**
   * List<Map<String, dynamic>> driveDetails = await dbHelper.executeQuerySelect(
      tableName: 'DriveDetails',
      where: 'driveId = ?',
      whereArgs: [1]
      );
   * */
  Future<List<Map<String, dynamic>>> executeQuerySelect({required String tableName, String? where, List<dynamic>? whereArgs}) async {
    try {
      final db = await instance.database;
      return db.query(tableName, where: where, whereArgs: whereArgs);
    } catch(e, s) {
    	throw SelectFailException(tableName: tableName, stackTrace: s, errorMsg: e.toString());
    }
  }

  /**
   * await dbHelper.executeUpdate(
      tableName: 'DriveDetails',
      data: {'speed': 65.0, 'event': "accelerate"},
      where: 'driveId = ? AND timestamp = ?',
      whereArgs: [1, "2024-05-01T12:00:00Z"]
      );
   * */
  Future<int> executeUpdate({required String tableName, required Map<String, dynamic> data, required String where, required List<dynamic> whereArgs}) async {
    try {
      final db = await instance.database;
      return db.update(tableName, data, where: where, whereArgs: whereArgs);
    } catch(e, s) {
    	throw UpdateFailException(tableName: tableName, errorMsg: e.toString(), stackTrace: s);
    }
  }

  /**
   *  await dbHelper.executeDelete(
      tableName: 'DriveDetails',
      where: 'driveId = ? AND timestamp = ?',
      whereArgs: [1, "2024-05-01T12:00:00Z"]
      );
   * */
  Future<int> executeDelete({required String tableName, required String where, required List<dynamic> whereArgs}) async {
    try {
      final db = await instance.database;
      return db.delete(tableName, where: where, whereArgs: whereArgs);
    } catch(e, s) {
    	throw DeleteFailException(tableName: tableName, errorMsg: e.toString(), stackTrace: s);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
