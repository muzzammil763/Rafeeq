import 'package:sqflite/sqflite.dart';
import 'package:rafeeq/data/app_database/tables/db_tables.dart';

class QuranTextCacheDao {
  final Database _db;

  QuranTextCacheDao(this._db);

  /// Returns all cached ayah texts for a given edition + fetch scope,
  /// or an empty map if nothing is cached yet.
  Future<Map<int, String>> getAll(
    String fetchType,
    int fetchNumber,
    String editionId,
  ) async {
    final rows = await _db.query(
      DbTables.quranTextCacheEntries,
      where: 'edition_id = ? AND fetch_type = ? AND fetch_number = ?',
      whereArgs: [editionId, fetchType, fetchNumber],
    );

    return {
      for (final r in rows) r['ayah_number'] as int: r['ayah_text'] as String,
    };
  }

  /// Returns the number of cached ayah rows for a given edition
  /// across all fetch scopes.
  Future<int> countForEdition(String editionId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM ${DbTables.quranTextCacheEntries} WHERE edition_id = ?',
      [editionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns every cached ayah text for a given edition across all
  /// fetch scopes, keyed by global ayah number.
  Future<Map<int, String>> getAllForEdition(String editionId) async {
    final rows = await _db.query(
      DbTables.quranTextCacheEntries,
      where: 'edition_id = ?',
      whereArgs: [editionId],
    );

    return {
      for (final r in rows) r['ayah_number'] as int: r['ayah_text'] as String,
    };
  }

  /// Inserts or replaces all ayah texts for a given edition + fetch scope.
  Future<void> insertAll(
    String fetchType,
    int fetchNumber,
    String editionId,
    Map<int, String> data,
  ) async {
    final batch = _db.batch();
    for (final entry in data.entries) {
      batch.insert(
        DbTables.quranTextCacheEntries,
        {
          'edition_id': editionId,
          'fetch_type': fetchType,
          'fetch_number': fetchNumber,
          'ayah_number': entry.key,
          'ayah_text': entry.value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
