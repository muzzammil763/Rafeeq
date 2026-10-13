import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/models/fasting_data.dart';
import 'package:rafeeq/data/models/hijri_correction.dart';
import 'package:rafeeq/data/models/ramadan_day_info.dart';
import 'package:rafeeq/ui/app_home/home/home_prayer_data.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';

final ramadanDaysProvider = Provider<List<RamadanDayInfo>>((ref) {
  final userLocation = ref.watch(userLocationNotifierProvider);
  final hijriCorrection = ref.watch(
    appSettingsNotifierProvider.select((e) => e.hijriCorrection),
  );

  if (userLocation == null) return [];

  final today = DateTime.now();
  DateTime startDate = today;

  // Find 1st Ramadan logic
  for (int i = 0; i < 35; i++) {
    final date = today.subtract(Duration(days: i));
    // Apply correction
    final hDate = HijriCalendar.fromDate(date.getAdjusted(hijriCorrection));

    if (hDate.hMonth == 9 && hDate.hDay == 1) {
      startDate = date;
      break;
    }
  }

  // If strict check fails, maybe check forward? (not implemented in original, keeping it same)

  final days = <RamadanDayInfo>[];
  for (int i = 0; i < 30; i++) {
    final date = startDate.add(Duration(days: i));
    final hDate = HijriCalendar.fromDate(date.getAdjusted(hijriCorrection));
    if (hDate.hMonth != 9) break;

    final prayerTimes = ref.read(
      prayerTimesForDateProvider((userLocation, date)),
    );

    days.add(
      RamadanDayInfo(
        date: date,
        hijriDate: hDate,
        suhoor: prayerTimes.fajr,
        iftar: prayerTimes.maghrib,
      ),
    );
  }
  return days;
});

// Stats Provider
final ramadanStatsProvider = FutureProvider<Map<FastingStatus, int>>((
  ref,
) async {
  final days = ref.watch(ramadanDaysProvider);
  if (days.isEmpty) return {};

  final repo = ref.watch(fastingRepositoryProvider);
  final dates = days.map((e) => e.date).toList();
  return repo.getStatsForRange(dates);
});
