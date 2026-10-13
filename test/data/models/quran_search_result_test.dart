import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/model/quran_search_result.dart';

void main() {
  group('SearchMatch.fromJson', () {
    Map<String, dynamic> buildMatchJson({String? editionIdentifier}) {
      return {
        'number': 2,
        'text': "Alhamdu lillaahi Rabbil 'aalameen",
        'numberInSurah': 2,
        'surah': {
          'number': 1,
          'name': 'سُورَةُ ٱلْفَاتِحَةِ',
          'englishName': 'Al-Faatiha',
          'englishNameTranslation': 'The Opening',
          'revelationType': 'Meccan',
        },
        if (editionIdentifier != null)
          'edition': {
            'identifier': editionIdentifier,
            'language': 'en',
            'name': 'Transliteration',
            'englishName': 'English Transliteration',
            'type': 'transliteration',
          },
      };
    }

    test('parses edition.identifier when present', () {
      final match = SearchMatch.fromJson(
        buildMatchJson(editionIdentifier: 'en.transliteration'),
      );

      expect(match.number, 2);
      expect(match.numberInSurah, 2);
      expect(match.surah.number, 1);
      expect(match.editionIdentifier, 'en.transliteration');
    });

    test('leaves editionIdentifier null when edition key is absent', () {
      final match = SearchMatch.fromJson(buildMatchJson());

      expect(match.editionIdentifier, isNull);
    });

    test('QuranSearchResult.fromJson parses matches with editions', () {
      final result = QuranSearchResult.fromJson({
        'count': 2,
        'matches': [
          buildMatchJson(editionIdentifier: 'en.transliteration'),
          buildMatchJson(editionIdentifier: 'en.asad'),
        ],
      });

      expect(result.count, 2);
      expect(result.matches.length, 2);
      expect(result.matches[0].editionIdentifier, 'en.transliteration');
      expect(result.matches[1].editionIdentifier, 'en.asad');
    });
  });
}
