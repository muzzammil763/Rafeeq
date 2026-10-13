import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:rafeeq/data/app_database/tables/db_tables.dart';

class AppDatabase {
  final sqflite.Database _db;

  AppDatabase._(this._db);

  sqflite.Database get database => _db;

  static const int latestVersion = 2;

  static Future<AppDatabase> open({
    required String path,
    sqflite.DatabaseFactory? factory,
  }) async {
    final dbFactory = factory ?? sqflite.databaseFactory;
    final db = await dbFactory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: latestVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    for (final statement in DbTables.allCreateStatements) {
      await db.execute(statement);
    }
  }

  static Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      final migration = _migrations[v];
      if (migration != null) {
        await migration(db);
      }
    }
  }

  static final Map<int, Future<void> Function(sqflite.Database)> _migrations = {
    2: (db) async {
      await db.execute(DbTables.createQuranTextCacheEntries);
    },
  };

  Future<void> close() => _db.close();
}
