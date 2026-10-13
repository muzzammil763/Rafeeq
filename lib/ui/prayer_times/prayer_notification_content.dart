import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

/// Localized, intentionally concise notification content for prayer times.
class PrayerNotificationContent {
  PrayerNotificationContent._();

  /// Returns a short notification body for the given [key] and [language].
  static String getBody(PrayerNotifKey key, AppLanguage language) {
    return switch (language) {
      AppLanguage.ur => 'نماز کا وقت ہے۔',
      AppLanguage.en => 'It is prayer time.',
    };
  }

  /// Returns a notification title string for the given [key] and [language].
  /// [time] is used to determine if it's Friday for Jumma prayer.
  static String getTitle(
    PrayerNotifKey key,
    AppLanguage language, {
    DateTime? time,
  }) {
    switch (key) {
      case PrayerNotifKey.suhoor:
        return switch (language) {
          AppLanguage.ur => 'سحری',
          AppLanguage.en => 'Suhoor',
        };
      case PrayerNotifKey.fajr:
        return switch (language) {
          AppLanguage.ur => 'فجر',
          AppLanguage.en => 'Fajr',
        };
      case PrayerNotifKey.sunrise:
        return switch (language) {
          AppLanguage.ur => 'طلوع آفتاب',
          AppLanguage.en => 'Sunrise',
        };
      case PrayerNotifKey.dhuhr:
        // Show "Jumma" on Fridays, "Dhuhr" on other days
        final isFriday = time?.weekday == DateTime.friday;
        return switch (language) {
          AppLanguage.ur => isFriday ? 'جمعہ' : 'ظہر',
          AppLanguage.en => isFriday ? 'Jumma' : 'Dhuhr',
        };
      case PrayerNotifKey.asr:
        return switch (language) {
          AppLanguage.ur => 'عصر',
          AppLanguage.en => 'Asr',
        };
      case PrayerNotifKey.iftar:
        return switch (language) {
          AppLanguage.ur => 'افطار',
          AppLanguage.en => 'Iftar',
        };
      case PrayerNotifKey.maghrib:
        return switch (language) {
          AppLanguage.ur => 'مغرب',
          AppLanguage.en => 'Maghrib',
        };
      case PrayerNotifKey.isha:
        return switch (language) {
          AppLanguage.ur => 'عشاء',
          AppLanguage.en => 'Isha',
        };
      case PrayerNotifKey.eid:
        return switch (language) {
          AppLanguage.ur => 'عید کی نماز',
          AppLanguage.en => 'Eid Prayer',
        };
    }
  }
}
