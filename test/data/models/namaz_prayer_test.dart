import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/models/namaz_prayer.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/data/raw/namaz_prayers_raw.dart';
import 'package:rafeeq/data/raw/wudu_steps_raw.dart';

void main() {
  group('NamazPrayer serialization & loading tests', () {
    test('Verify namazPrayersJson asset exists and matches structure', () {
      final jsonStr = namazPrayersJson;
      final decodedListDynamic = jsonDecode(jsonStr) as List<dynamic>;
      expect(decodedListDynamic.length, 5);

      final decodedPrayers = decodedListDynamic
          .map((e) => NamazPrayer.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(decodedPrayers.length, 5);
      final fajr = decodedPrayers.firstWhere((p) => p.id == 'fajr');
      expect(fajr.nameEn, 'Fajr');
      expect(fajr.components.isNotEmpty, true);
    });

    test('Verify wuduStepsJson asset exists and matches structure', () {
      final jsonStr = wuduStepsJson;
      final decodedListDynamic = jsonDecode(jsonStr) as List<dynamic>;
      expect(decodedListDynamic.length, 10);

      final decodedSteps = decodedListDynamic
          .map((e) => WuduStep.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(decodedSteps.length, 10);
      expect(decodedSteps[0].titleEn, 'Intention (Niyyah)');
    });

    test(
      'Verify initializeNamazPrayers and initializeWuduSteps populates correctly',
      () {
        final namazJson = namazPrayersJson;
        final wuduJson = wuduStepsJson;

        initializeNamazPrayers(namazJson);
        initializeWuduSteps(wuduJson);

        expect(kNamazPrayers.length, 5);
        expect(kNamazPrayers[0].id, 'fajr');
        expect(kNamazPrayers[4].id, 'isha');

        expect(kWuduSteps.length, 10);
        expect(kWuduSteps[0].step, 1);
        expect(kWuduSteps[9].step, 10);
      },
    );

    test('Verify getNamazById returns correct prayer or null', () {
      final namazJson = namazPrayersJson;
      initializeNamazPrayers(namazJson);

      final fajr = getNamazById('fajr');
      expect(fajr, isNotNull);
      expect(fajr!.nameEn, 'Fajr');

      final invalid = getNamazById('invalid_id');
      expect(invalid, isNull);
    });
  });
}
