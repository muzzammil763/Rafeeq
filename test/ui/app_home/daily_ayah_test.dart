import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/ui/app_home/home/daily_ayah.dart';

void main() {
  const ayahs = [
    Ayah(number: 1, numberInSurah: 1, text: 'First', juz: 1, surahNumber: 1),
    Ayah(number: 2, numberInSurah: 2, text: 'Second', juz: 1, surahNumber: 1),
    Ayah(number: 3, numberInSurah: 3, text: 'Third', juz: 1, surahNumber: 1),
  ];

  test('keeps the selected ayah stable throughout the same day', () {
    final morning = selectDailyAyah(ayahs, DateTime(2026, 9, 2, 8));
    final evening = selectDailyAyah(ayahs, DateTime(2026, 9, 2, 22));

    expect(evening.number, morning.number);
  });

  test('advances the selected ayah on the next calendar day', () {
    final today = selectDailyAyah(ayahs, DateTime(2026, 9, 2));
    final tomorrow = selectDailyAyah(ayahs, DateTime(2026, 9, 3));

    expect(tomorrow.number, isNot(today.number));
  });

  test('rejects an empty Quran', () {
    expect(
      () => selectDailyAyah(const [], DateTime(2026, 9, 2)),
      throwsArgumentError,
    );
  });
}
