import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider = Provider<Prefs>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return Prefs(sharedPreferences);
});

class Prefs {
  final SharedPreferences _prefs;

  const Prefs(this._prefs);

  bool get isQuranAutoScrollEnabled =>
      _prefs.getBool("isQuranAutoScrollEnabled") ?? true;

  Future<bool> setQuranAutoScrollEnabled(bool value) =>
      _prefs.setBool("isQuranAutoScrollEnabled", value);

  // Ramadan confetti tracking - stores the Hijri year when confetti was shown
  int? get lastRamadanConfettiYear =>
      _prefs.getInt("last_ramadan_confetti_year");

  Future<bool> setLastRamadanConfettiYear(int year) =>
      _prefs.setInt("last_ramadan_confetti_year", year);

  // Eid confetti tracking - stores the date string (yyyy-MM-dd) when confetti was shown
  String? get lastEidConfettiDate => _prefs.getString("last_eid_confetti_date");

  Future<bool> setLastEidConfettiDate(String date) =>
      _prefs.setString("last_eid_confetti_date", date);

  // Jumma (Friday) confetti tracking - stores the date string (yyyy-MM-dd) when confetti was shown
  String? get lastJummaConfettiDate =>
      _prefs.getString("last_jumma_confetti_date");

  Future<bool> setLastJummaConfettiDate(String date) =>
      _prefs.setString("last_jumma_confetti_date", date);

  // Prayer times notification scheduling optimization
  String? getLastPrayerTimesSignature() =>
      _prefs.getString("prayer_times.last_schedule_signature");

  Future<bool> setLastPrayerTimesSignature(String signature) =>
      _prefs.setString("prayer_times.last_schedule_signature", signature);

  String? getLastScheduleLocation() =>
      _prefs.getString("prayer_times.last_schedule_location");

  Future<bool> setLastScheduleLocation(String locationData) =>
      _prefs.setString("prayer_times.last_schedule_location", locationData);
}
