import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/app_database/app_database.dart';
import 'package:rafeeq/data/app_database/daos/quran_text_cache_dao.dart';
import 'package:rafeeq/data/app_database/tables/db_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseFactory dbFactory;

  setUpAll(() {
    sqfliteFfiInit();
    dbFactory = databaseFactoryFfi;
  });

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async {
      db = await AppDatabase.open(
        path: inMemoryDatabasePath,
        factory: dbFactory,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('creates the Quran cache table on a fresh database', () async {
      final tables = await db.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables.map((table) => table['name'] as String).toSet();

      expect(tableNames, contains(DbTables.quranTextCacheEntries));
    });

    test('uses the latest schema version', () async {
      final result = await db.database.rawQuery('PRAGMA user_version');
      final version = result.first['user_version'] as int;

      expect(version, AppDatabase.latestVersion);
    });
  });

  group('AppDatabase migrations', () {
    test('migrates from version 1 and preserves existing tables', () async {
      final dbPath = '${DateTime.now().microsecondsSinceEpoch}_test.db';
      final versionOneDatabase = await dbFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE legacy_metadata (id TEXT PRIMARY KEY)',
            );
          },
        ),
      );
      await versionOneDatabase.insert('legacy_metadata', {'id': 'existing'});
      await versionOneDatabase.close();

      final upgradedDatabase = await AppDatabase.open(
        path: dbPath,
        factory: dbFactory,
      );

      final cacheTables = await upgradedDatabase.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DbTables.quranTextCacheEntries}'",
      );
      final legacyRows = await upgradedDatabase.database.query(
        'legacy_metadata',
      );

      expect(cacheTables, isNotEmpty);
      expect(legacyRows.single['id'], 'existing');

      await upgradedDatabase.close();
      await dbFactory.deleteDatabase(dbPath);
    });
  });

  group('QuranTextCacheDao', () {
    late AppDatabase db;
    late QuranTextCacheDao dao;

    setUp(() async {
      db = await AppDatabase.open(
        path: inMemoryDatabasePath,
        factory: dbFactory,
      );
      dao = QuranTextCacheDao(db.database);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertAll and getAll', () async {
      await dao.insertAll('surah', 1, 'en.asad', {
        1: 'In the name of Allah',
        2: 'All praise is due to Allah',
      });

      final result = await dao.getAll('surah', 1, 'en.asad');
      expect(result, hasLength(2));
      expect(result[1], 'In the name of Allah');
      expect(result[2], 'All praise is due to Allah');
    });

    test('getAll returns empty map for non-existent scope', () async {
      final result = await dao.getAll('surah', 999, 'nonexistent');
      expect(result, isEmpty);
    });

    test('insertAll with different editions is isolated', () async {
      await dao.insertAll('surah', 1, 'en.asad', {1: 'Surah 1 Ayah 1'});
      await dao.insertAll('juz', 1, 'en.pickthall', {1: 'Juz 1 Ayah 1'});

      final surah = await dao.getAll('surah', 1, 'en.asad');
      final juz = await dao.getAll('juz', 1, 'en.pickthall');

      expect(surah[1], 'Surah 1 Ayah 1');
      expect(juz[1], 'Juz 1 Ayah 1');
    });

    test('insertAll replaces existing entries', () async {
      await dao.insertAll('surah', 1, 'en.asad', {1: 'original'});
      await dao.insertAll('surah', 1, 'en.asad', {1: 'updated'});

      final result = await dao.getAll('surah', 1, 'en.asad');
      expect(result[1], 'updated');
      expect(result, hasLength(1));
    });
  });
}
