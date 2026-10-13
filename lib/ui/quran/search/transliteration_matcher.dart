import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';

/// Builds (and caches for the session) the local transliteration search index
/// for the edition selected in the Quran view settings.
///
/// The underlying text comes from [QuranApiRepo.getFullEditionText], which is
/// backed by the SQLite cache — so after the very first download this works
/// fully offline.
final transliterationIndexProvider = FutureProvider<TransliterationMatcher>((
  ref,
) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 30), link.close);
  ref.onDispose(timer.cancel);

  final editionId = ref.watch(
    quranViewSettingsNotifierProvider.select((s) => s.transliterationEditionId),
  );
  final texts = await ref
      .read(quranApiRepoProvider)
      .getFullEditionText(editionId);
  return TransliterationMatcher(texts);
});

/// One searchable ayah: its transliteration text plus precomputed
/// normalized forms used for matching.
class TranslitAyahEntry {
  final int number; // global ayah number (1..6236)
  final String text; // original transliteration text
  final String squashed; // lowercase, a-z only

  TranslitAyahEntry({required this.number, required this.text})
    : squashed = TransliterationMatcher.squash(text);
}

/// A single match; [distance] is 0 for exact matches and small positive
/// numbers for fuzzy spelling-variant matches.
class TranslitMatch {
  final TranslitAyahEntry entry;
  final int distance;

  const TranslitMatch({required this.entry, required this.distance});

  bool get isExact => distance == 0;
}

/// Local fuzzy search over transliteration text.
///
/// Matching works on a "squashed" form (lowercase, everything except a-z
/// removed), which transparently handles:
///   - joined vs spaced words   ("alhamdulillah" ≈ "Alhamdu lillaahi")
///   - apostrophes              ("'ala", "Qur'aan")
///   - hyphens                  ("a-anzar")
///   - arbitrary spacing        ("wa qaalat" ≈ "waqalat")
///
/// Results come in two tiers, exact first:
///   1. exact — the squashed query is a substring of the squashed ayah.
///   2. fuzzy — the squashed query is within a small edit distance of some
///      substring of the squashed ayah. Handles one-letter-off spellings
///      ("haitalak" / "haitalac" / "haitalaq") and vowel-length variants
///      ("waqalat" ≈ "wa qaalat"). Only used to fill in when exact
///      matching found little or nothing.
class TransliterationMatcher {
  static final _nonAlphaPattern = RegExp(r'[^a-z]');

  /// Minimum squashed-query length; shorter queries are too noisy.
  static const int minQueryLength = 3;

  /// Exact hits at or above which fuzzy matching is skipped entirely.
  static const int fuzzyThreshold = 5;

  final List<TranslitAyahEntry> entries;

  TransliterationMatcher(Map<int, String> ayahTexts)
    : entries = [
        for (final e in ayahTexts.entries)
          TranslitAyahEntry(number: e.key, text: e.value),
      ]..sort((a, b) => a.number.compareTo(b.number));

  static String squash(String input) =>
      input.toLowerCase().replaceAll(_nonAlphaPattern, '');

  /// Maximum edit distance allowed for fuzzy matching, scaled by query length.
  static int maxDistanceFor(int squashedQueryLength) {
    if (squashedQueryLength >= 10) return 2;
    if (squashedQueryLength >= 5) return 1;
    return 0;
  }

  /// Returns matches ordered exact-first (by ayah number), then fuzzy
  /// (by distance, then ayah number).
  List<TranslitMatch> search(
    String rawQuery, {
    int maxExact = 50,
    int maxFuzzy = 25,
  }) {
    final squashedQuery = squash(rawQuery);
    if (squashedQuery.length < minQueryLength) return const [];

    final exact = <TranslitMatch>[];
    final exactNumbers = <int>{};
    for (final entry in entries) {
      if (entry.squashed.contains(squashedQuery)) {
        exact.add(TranslitMatch(entry: entry, distance: 0));
        exactNumbers.add(entry.number);
        if (exact.length >= maxExact) break;
      }
    }

    final maxDistance = maxDistanceFor(squashedQuery.length);
    if (exact.length >= fuzzyThreshold || maxDistance == 0) {
      return exact;
    }

    final fuzzy = <TranslitMatch>[];
    for (final entry in entries) {
      if (exactNumbers.contains(entry.number)) continue;
      final distance = _substringDistance(
        squashedQuery,
        entry.squashed,
        maxDistance,
      );
      if (distance > 0 && distance <= maxDistance) {
        fuzzy.add(TranslitMatch(entry: entry, distance: distance));
      }
    }

    fuzzy.sort((a, b) {
      final byDistance = a.distance.compareTo(b.distance);
      return byDistance != 0
          ? byDistance
          : a.entry.number.compareTo(b.entry.number);
    });

    return [...exact, ...fuzzy.take(maxFuzzy)];
  }

  /// Minimum edit distance between [query] and any substring of [text]
  /// (the match may start and end anywhere in [text]). Returns
  /// [maxDistance] + 1 as soon as the true distance is known to exceed
  /// [maxDistance], so non-matching entries bail out early.
  static int _substringDistance(String query, String text, int maxDistance) {
    final m = query.length;
    final n = text.length;

    // prev[j] = edit distance between query[:i] and the best substring of
    // text ending at or before j. Row 0 is all zeros → free match start.
    var prev = List<int>.filled(n + 1, 0);
    for (var i = 1; i <= m; i++) {
      final curr = List<int>.filled(n + 1, 0);
      curr[0] = i;
      var rowMin = i;
      final qi = query.codeUnitAt(i - 1);
      for (var j = 1; j <= n; j++) {
        final cost = qi == text.codeUnitAt(j - 1) ? 0 : 1;
        var value = prev[j] + 1; // deletion from query
        final insertion = curr[j - 1] + 1; // extra char in text
        if (insertion < value) value = insertion;
        final substitution = prev[j - 1] + cost;
        if (substitution < value) value = substitution;
        curr[j] = value;
        if (value < rowMin) rowMin = value;
      }
      if (rowMin > maxDistance) return maxDistance + 1;
      prev = curr;
    }

    var best = maxDistance + 1;
    for (final value in prev) {
      if (value < best) best = value;
    }
    return best;
  }
}
