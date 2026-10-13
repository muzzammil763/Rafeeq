import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/quran/search/transliteration_matcher.dart';

void main() {
  TransliterationMatcher matcherFor(Map<int, String> texts) =>
      TransliterationMatcher(texts);

  group('TransliterationMatcher.squash', () {
    test('removes apostrophes, hyphens, spaces and lowercases', () {
      expect(
        TransliterationMatcher.squash("Rabbil 'aalameen"),
        'rabbilaalameen',
      );
      expect(TransliterationMatcher.squash('A-anzar ilaa'), 'aanzarilaa');
      expect(TransliterationMatcher.squash('Al-Faatiha'), 'alfaatiha');
    });
  });

  group('TransliterationMatcher.maxDistanceFor', () {
    test('scales with query length', () {
      expect(TransliterationMatcher.maxDistanceFor(3), 0);
      expect(TransliterationMatcher.maxDistanceFor(4), 0);
      expect(TransliterationMatcher.maxDistanceFor(5), 1);
      expect(TransliterationMatcher.maxDistanceFor(9), 1);
      expect(TransliterationMatcher.maxDistanceFor(10), 2);
      expect(TransliterationMatcher.maxDistanceFor(20), 2);
    });
  });

  group('exact matching', () {
    test('matches joined words written with spaces in the text', () {
      final matcher = matcherFor({1: 'Bismi Allahi alrrahmani alrraheemi'});

      final results = matcher.search('bismiallahi');

      expect(results.length, 1);
      expect(results.first.entry.number, 1);
      expect(results.first.isExact, true);
      expect(results.first.distance, 0);
    });

    test('matches across apostrophes in the text', () {
      final matcher = matcherFor({2: "Alhamdu lillaahi Rabbil 'aalameen"});

      final results = matcher.search('aalameen');

      expect(results.length, 1);
      expect(results.first.isExact, true);
    });

    test('matches across hyphens and spaces in the query', () {
      final matcher = matcherFor({10: 'A-anzar ilaa alssamaa'});

      final results = matcher.search('a anzar');

      expect(results.length, 1);
      expect(results.first.isExact, true);
    });
  });

  group('fuzzy matching', () {
    test('matches one-letter-off spellings (haitalac / haitalaq)', () {
      final matcher = matcherFor({100: 'Wa qaalat haitalak bima kuntum'});

      for (final variant in ['haitalac', 'haitalaq', 'haitalak']) {
        final results = matcher.search(variant);
        expect(
          results.any((m) => m.entry.number == 100),
          true,
          reason: 'expected "$variant" to match',
        );
      }
    });

    test('matches joined words with vowel-length variants', () {
      final matcher = matcherFor({2: "Alhamdu lillaahi Rabbil 'aalameen"});

      final results = matcher.search('alhamdulillah');

      expect(results.length, 1);
      expect(results.first.entry.number, 2);
      expect(results.first.isExact, false);
      expect(results.first.distance, greaterThan(0));
    });

    test('matches vowel-length variants (waqalat ≈ wa qaalat)', () {
      final matcher = matcherFor({100: 'Wa qaalat haitalak bima kuntum'});

      final results = matcher.search('waqalat');

      expect(results.any((m) => m.entry.number == 100), true);
    });

    test('does not fuzzy-match short queries', () {
      final matcher = matcherFor({100: 'Wa qaalat haitalak bima kuntum'});

      // 'kuntun' is length 6 → distance 1 allowed... use a 4-letter query
      // with one wrong letter: fuzzy is disabled below length 5.
      expect(matcher.search('bima'), isNotEmpty); // exact still works
      expect(matcher.search('bimi'), isEmpty); // 1 wrong letter, no fuzzy
    });
  });

  group('priority and limits', () {
    test('exact matches come before fuzzy matches', () {
      final matcher = matcherFor({
        100: 'Wa qaalat haitalak bima kuntum', // exact for "haitalak"
        300: 'Haitalao qawmun', // fuzzy (distance 1) for "haitalak"
      });

      final results = matcher.search('haitalak');

      expect(results.length, 2);
      expect(results[0].entry.number, 100);
      expect(results[0].isExact, true);
      expect(results[1].entry.number, 300);
      expect(results[1].isExact, false);
    });

    test('skips fuzzy search when enough exact matches exist', () {
      final matcher = matcherFor({
        1: 'Rahmanir raheem one',
        2: 'Rahmanir raheem two',
        3: 'Rahmanir raheem three',
        4: 'Rahmanir raheem four',
        5: 'Rahmanir raheem five',
        6: 'Rahmaanir raheem fuzzy only',
      });

      final results = matcher.search('rahman');

      expect(results.length, 5);
      expect(results.every((m) => m.isExact), true);
    });

    test('respects maxFuzzy cap', () {
      final matcher = matcherFor({
        1: 'Haitalao one',
        2: 'Haitalau two',
        3: 'Haitalai three',
      });

      final results = matcher.search('haitalak', maxFuzzy: 2);

      expect(results.length, 2);
    });

    test('returns empty for short or empty queries', () {
      final matcher = matcherFor({1: 'Bismi Allahi alrrahmani alrraheemi'});

      expect(matcher.search(''), isEmpty);
      expect(matcher.search('  '), isEmpty);
      expect(matcher.search('bi'), isEmpty);
    });
  });
}
