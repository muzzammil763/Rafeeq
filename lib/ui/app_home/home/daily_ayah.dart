import 'package:rafeeq/data/model/quran_models.dart';

const _maximumDailyAyahLength = 280;
final _dailyAyahEpoch = DateTime.utc(2024);

Ayah selectDailyAyah(List<Ayah> ayahs, DateTime date) {
  final suitableAyahs = ayahs
      .where((ayah) => ayah.text.trim().length <= _maximumDailyAyahLength)
      .toList(growable: false);
  final candidates = suitableAyahs.isEmpty ? ayahs : suitableAyahs;
  if (candidates.isEmpty) {
    throw ArgumentError.value(ayahs, 'ayahs', 'Must not be empty');
  }

  final calendarDay = DateTime.utc(date.year, date.month, date.day);
  final elapsedDays = calendarDay.difference(_dailyAyahEpoch).inDays;
  final index =
      ((elapsedDays % candidates.length) + candidates.length) %
      candidates.length;
  return candidates[index];
}
