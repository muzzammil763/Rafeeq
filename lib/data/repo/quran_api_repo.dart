import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/app_database/daos/quran_text_cache_dao.dart';
import 'package:rafeeq/data/model/quran_edition.dart';
import 'package:rafeeq/data/model/quran_search_result.dart';

final quranApiRepoProvider = Provider<QuranApiRepo>(
  (ref) => QuranApiRepo(ref.read(quranTextCacheDaoProvider)),
);

/// Identifies whether we're fetching by surah or juz.
enum QuranFetchType { surah, juz }

/// Cache key passed to [quranEditionTextProvider].
typedef QuranEditionKey = ({QuranFetchType type, int number, String editionId});

/// FutureProvider that serves Quran edition text with a two-layer cache:
///
///   1. Riverpod in-memory cache  — keyed by (type, number, editionId),
///      kept alive for the whole app session via ref.keepAlive().
///   2. SQLite disk cache via sqflite — survives app restarts; the network is
///      only hit the very first time a (surah/juz + edition) combination
///      is requested.
final quranEditionTextProvider =
    FutureProvider.family<Map<int, String>, QuranEditionKey>((ref, key) {
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 30), link.close);
      ref.onDispose(timer.cancel);
      final repo = ref.read(quranApiRepoProvider);
      return switch (key.type) {
        QuranFetchType.surah => repo.getSurah(key.number, key.editionId),
        QuranFetchType.juz => repo.getJuz(key.number, key.editionId),
      };
    });

class QuranApiRepo {
  final String _baseUrl = 'https://api.alquran.cloud/v1';
  final QuranTextCacheDao _dao;

  QuranApiRepo(this._dao);

  Future<List<QuranEdition>> getEditions({
    String type = 'translation',
    String format = 'text',
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/edition?type=$type&format=$format'),
      headers: {'Accept-Encoding': 'gzip'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final editionsJson = data['data'] as List<dynamic>;
      return editionsJson
          .map((json) => QuranEdition.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load editions: ${response.statusCode}');
    }
  }

  Future<QuranSearchResult> searchTranslation(
    String query,
    String editionId,
  ) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = '$_baseUrl/search/$encodedQuery/all/$editionId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept-Encoding': 'gzip'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return QuranSearchResult.fromJson(data['data'] as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      return QuranSearchResult(count: 0, matches: []);
    } else {
      throw Exception(
        'Failed to search translation: ${response.statusCode} - URL: $url',
      );
    }
  }

  /// Returns a map of global ayah number to text for a surah edition.
  /// Reads from SQLite cache first; only hits the network on a cache miss.
  Future<Map<int, String>> getSurah(int surahNumber, String editionId) async {
    // 1. SQLite cache hit → return immediately, no network call.
    final cached = await _dao.getAll('surah', surahNumber, editionId);
    if (cached.isNotEmpty) return cached;

    // 2. Cache miss → fetch from network.
    final response = await http.get(
      Uri.parse('$_baseUrl/surah/$surahNumber/$editionId'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load surah translation: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final dataJson = data['data'] as Map<String, dynamic>;
    final ayahsJson = dataJson['ayahs'] as List<dynamic>;
    final Map<int, String> result = {
      for (final ayah in ayahsJson)
        (ayah as Map<String, dynamic>)['number'] as int: ayah['text'] as String,
    };

    // 3. Persist to SQLite so next open is instant.
    await _dao.insertAll('surah', surahNumber, editionId, result);
    return result;
  }

  /// Total number of ayahs in the Quran; used to detect a fully cached edition.
  static const int totalAyahCount = 6236;

  /// Returns every ayah text for an edition (global ayah number → text).
  ///
  /// Uses the SQLite cache when the full edition was cached before; otherwise
  /// downloads the whole edition in a single request and caches it per surah
  /// so per-surah lookups ([getSurah]) benefit from it too.
  Future<Map<int, String>> getFullEditionText(String editionId) async {
    final cachedCount = await _dao.countForEdition(editionId);
    if (cachedCount >= totalAyahCount) {
      return _dao.getAllForEdition(editionId);
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/quran/$editionId'),
      headers: {'Accept-Encoding': 'gzip'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load full edition: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final dataJson = data['data'] as Map<String, dynamic>;
    final surahsJson = dataJson['surahs'] as List<dynamic>;

    final Map<int, String> result = {};
    for (final surah in surahsJson) {
      final surahMap = surah as Map<String, dynamic>;
      final surahNumber = surahMap['number'] as int;
      final ayahsJson = surahMap['ayahs'] as List<dynamic>;
      final Map<int, String> surahAyahs = {
        for (final ayah in ayahsJson)
          (ayah as Map<String, dynamic>)['number'] as int:
              ayah['text'] as String,
      };
      result.addAll(surahAyahs);
      await _dao.insertAll('surah', surahNumber, editionId, surahAyahs);
    }
    return result;
  }

  /// Returns a map of global ayah number to text for a juz edition.
  /// Reads from SQLite cache first; only hits the network on a cache miss.
  Future<Map<int, String>> getJuz(int juzNumber, String editionId) async {
    // 1. SQLite cache hit.
    final cached = await _dao.getAll('juz', juzNumber, editionId);
    if (cached.isNotEmpty) return cached;

    // 2. Cache miss → fetch from network.
    final response = await http.get(
      Uri.parse('$_baseUrl/juz/$juzNumber/$editionId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load juz translation: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final dataJson = data['data'] as Map<String, dynamic>;
    final ayahsJson = dataJson['ayahs'] as List<dynamic>;
    final Map<int, String> result = {
      for (final ayah in ayahsJson)
        (ayah as Map<String, dynamic>)['number'] as int: ayah['text'] as String,
    };

    // 3. Persist to SQLite.
    await _dao.insertAll('juz', juzNumber, editionId, result);
    return result;
  }
}
