class DbTables {
  DbTables._();

  static const String quranTextCacheEntries = 'quran_text_cache_entries';

  static const String createQuranTextCacheEntries =
      '''
    CREATE TABLE $quranTextCacheEntries (
      edition_id TEXT NOT NULL,
      fetch_type TEXT NOT NULL,
      fetch_number INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      ayah_text TEXT NOT NULL,
      PRIMARY KEY (edition_id, ayah_number)
    )
  ''';

  static const String createQuranTextCacheLookupIndex =
      '''
    CREATE INDEX idx_quran_text_cache_lookup
    ON $quranTextCacheEntries (edition_id, fetch_type, fetch_number)
  ''';

  static const List<String> allCreateStatements = [
    createQuranTextCacheEntries,
    createQuranTextCacheLookupIndex,
  ];
}
