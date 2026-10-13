import 'dart:convert';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/prefs.dart';
import 'package:rafeeq/data/models/hijri_correction.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/services/notification_service.dart';
import 'package:rafeeq/ui/app_home/home/home_prayer_data.dart';
import 'package:rafeeq/ui/prayer_times/prayer_notification_content.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';

final prayerNotificationManagerProvider = Provider<PrayerNotificationManager>((
  ref,
) {
  return PrayerNotificationManager(ref);
});

class PrayerNotificationManager {
  final Ref _ref;
  static const double _significantLocationChangeKm = 5.0; // 5km threshold

  PrayerNotificationManager(this._ref) {
    _init();
  }

  Future<void> _init() async {
    final notificationService = _ref.read(notificationServiceProvider);
    await notificationService.init();
    await scheduleNotificationsIfNeeded();

    _ref.listen<UserLocation?>(userLocationNotifierProvider, (previous, next) {
      if (next != null) {
        _handleLocationChange(previous, next);
      }
    });

    _ref.listen<PrayerTimesSettings>(prayerTimesSettingsNotifierProvider, (
      previous,
      next,
    ) {
      scheduleNotifications(force: true);
    });

    _ref.listen<AppSettings>(appSettingsNotifierProvider, (previous, next) {
      if (previous?.language != next.language) {
        scheduleNotifications(force: true);
      }
    });
  }

  /// Checks if location change is significant enough to reschedule notifications
  void _handleLocationChange(UserLocation? previous, UserLocation next) {
    if (previous == null) {
      debugPrint('[Notif] 📍 First location set — scheduling notifications');
      scheduleNotifications(force: true);
      return;
    }

    final distance = _calculateDistance(previous, next);
    if (distance >= _significantLocationChangeKm) {
      debugPrint(
        '[Notif] 📍 Significant location change: ${distance.toStringAsFixed(2)}km — rescheduling',
      );
      scheduleNotifications(force: true);
    } else {
      debugPrint(
        '[Notif] 📍 Minor location change: ${distance.toStringAsFixed(2)}km — skipping reschedule',
      );
    }
  }

  /// Calculates distance between two locations in kilometers using Haversine formula
  double _calculateDistance(UserLocation loc1, UserLocation loc2) {
    const double earthRadiusKm = 6371.0;
    final double lat1Rad = loc1.latitude * (math.pi / 180);
    final double lat2Rad = loc2.latitude * (math.pi / 180);
    final double deltaLatRad =
        (loc2.latitude - loc1.latitude) * (math.pi / 180);
    final double deltaLonRad =
        (loc2.longitude - loc1.longitude) * (math.pi / 180);

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadiusKm * c;
  }

  /// Generates a signature for current prayer times configuration
  String _generatePrayerTimesSignature(
    UserLocation location,
    PrayerTimesSettings settings,
  ) {
    final now = DateTime.now();
    final todayPrayerTimes = _calculatePrayerTimes(now, location, settings);

    // Create a signature based on location, settings, and today's prayer times
    final signatureData = {
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'settings': {
        'method': settings.prayerCalcMethod.index,
        'madhab': settings.asrCalculationMethod.index,
        'highLat': settings.highLatitudeAdjustment.index,
        'notificationTiming': settings.notificationTiming.name,
      },
      'prayerTimes': {
        'fajr': todayPrayerTimes.fajr.millisecondsSinceEpoch,
        'sunrise': todayPrayerTimes.sunrise.millisecondsSinceEpoch,
        'dhuhr': todayPrayerTimes.dhuhr.millisecondsSinceEpoch,
        'asr': todayPrayerTimes.asr.millisecondsSinceEpoch,
        'maghrib': todayPrayerTimes.maghrib.millisecondsSinceEpoch,
        'isha': todayPrayerTimes.isha.millisecondsSinceEpoch,
      },
      'date': now.toIso8601String().split('T')[0], // Just the date part
    };

    return jsonEncode(signatureData);
  }

  /// Checks if notifications need to be rescheduled
  Future<bool> _shouldReschedule(
    UserLocation location,
    PrayerTimesSettings settings,
  ) async {
    final prefs = _ref.read(prefsProvider);
    final currentSignature = _generatePrayerTimesSignature(location, settings);
    final lastSignature = prefs.getLastPrayerTimesSignature();

    if (lastSignature == null) {
      debugPrint('[Notif] 🆕 No previous schedule found — needs scheduling');
      return true;
    }

    if (currentSignature != lastSignature) {
      debugPrint(
        '[Notif] 🔄 Prayer times signature changed — needs rescheduling',
      );
      return true;
    }

    debugPrint('[Notif] ✓ Prayer times unchanged — skipping reschedule');
    return false;
  }

  /// Saves the current prayer times signature after successful scheduling
  Future<void> _saveScheduleSignature(
    UserLocation location,
    PrayerTimesSettings settings,
  ) async {
    final prefs = _ref.read(prefsProvider);
    final signature = _generatePrayerTimesSignature(location, settings);
    await prefs.setLastPrayerTimesSignature(signature);

    // Also save the location for change detection
    final locationData = {
      'lat': location.latitude,
      'lng': location.longitude,
      'city': location.city,
      'country': location.country,
    };
    await prefs.setLastScheduleLocation(jsonEncode(locationData));
  }

  /// Main entry point for scheduling notifications
  /// Use force=true to bypass signature check (e.g., manual refresh)
  Future<void> scheduleNotifications({bool force = false}) async {
    final location = _ref.read(userLocationNotifierProvider);
    final settings = _ref.read(prayerTimesSettingsNotifierProvider);

    if (location == null) {
      debugPrint(
        '[Notif] ⚠️ No location set — skipping notification scheduling',
      );
      return;
    }

    // Check if we actually need to reschedule
    if (!force) {
      final shouldSchedule = await _shouldReschedule(location, settings);
      if (!shouldSchedule) {
        debugPrint(
          '[Notif] ⏭️ No changes detected — skipping notification scheduling',
        );
        return;
      }
    }

    debugPrint('[Notif] 🔄 Scheduling notifications (force=$force)');
    await _performScheduling(location, settings);

    // Save the signature after successful scheduling
    await _saveScheduleSignature(location, settings);
  }

  /// Public method to check and schedule if needed (used on app startup)
  Future<void> scheduleNotificationsIfNeeded() async {
    await scheduleNotifications(force: false);
  }

  Future<void> _performScheduling(
    UserLocation location,
    PrayerTimesSettings settings,
  ) async {
    final language = _ref.read(appSettingsNotifierProvider).language;
    final notificationService = _ref.read(notificationServiceProvider);

    debugPrint('[Notif] 🔄 _performScheduling() called');
    debugPrint(
      '[Notif]   Enabled keys: ${settings.notificationSettings.entries.where((e) => e.value).map((e) => e.key.name).join(', ')}',
    );

    final anyNotificationEnabled = settings.notificationSettings.values.any(
      (enabled) => enabled,
    );

    if (!anyNotificationEnabled) {
      debugPrint('[Notif] 🔕 All notifications disabled — cancelling all');
      await notificationService.cancelAll();
      return;
    }

    // Check if we already have permission — do NOT auto-request here.
    // Requesting permission (especially exact alarms on Android) can open
    // the phone's Settings app, which is jarring when the user didn't ask
    // for it. Permission is only requested when the user explicitly enables
    // a notification toggle.
    bool hasPermission = await notificationService.hasPermission();
    if (!hasPermission) {
      debugPrint('[Notif] ⚠️ No permission — skipping scheduling');
      return;
    }

    // Cancel all previous notifications
    debugPrint('[Notif] 🗑️ Cancelling all previous notifications');
    await notificationService.cancelAll();

    // Schedule notifications for 10 days in advance.
    // Every time the user opens the app, this window is refreshed.
    // iOS has a limit of 64 pending notifications, so 10 days is safe.
    const daysToSchedule = 10;

    final now = DateTime.now();
    final hijriCorrection = _ref.read(
      appSettingsNotifierProvider.select((e) => e.hijriCorrection),
    );

    for (int i = 0; i < daysToSchedule; i++) {
      final date = now.add(Duration(days: i));
      final prayerTimes = _calculatePrayerTimes(date, location, settings);

      // Check Hijri date for special notifications
      final hijriDate = HijriCalendar.fromDate(
        date.getAdjusted(hijriCorrection),
      );
      final isRamadan = hijriDate.hMonth == 9;
      // Show Eid notification on 29, 30 of Ramadan and 1 Shawwal
      final showEidNotification =
          (isRamadan && (hijriDate.hDay == 29 || hijriDate.hDay == 30)) ||
          (hijriDate.hMonth == 10 && hijriDate.hDay == 1);

      if (isRamadan) {
        // Suhoor reminder follows the configured notification lead time.
        _scheduleByKey(
          notificationService,
          _adjustNotificationTime(prayerTimes.fajr, settings),
          PrayerNotifKey.suhoor,
          settings,
          language,
          i,
        );
        // Iftar: at Maghrib time
        _scheduleByKey(
          notificationService,
          _adjustNotificationTime(prayerTimes.maghrib, settings),
          PrayerNotifKey.iftar,
          settings,
          language,
          i,
        );
      }

      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.fajr, settings),
        PrayerNotifKey.fajr,
        settings,
        language,
        i,
      );
      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.sunrise, settings),
        PrayerNotifKey.sunrise,
        settings,
        language,
        i,
      );
      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.dhuhr, settings),
        PrayerNotifKey.dhuhr,
        settings,
        language,
        i,
      );
      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.asr, settings),
        PrayerNotifKey.asr,
        settings,
        language,
        i,
      );
      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.maghrib, settings),
        PrayerNotifKey.maghrib,
        settings,
        language,
        i,
      );
      _scheduleByKey(
        notificationService,
        _adjustNotificationTime(prayerTimes.isha, settings),
        PrayerNotifKey.isha,
        settings,
        language,
        i,
      );

      // Schedule Eid notification if applicable (days 29, 30 of Ramadan and 1 Shawwal)
      if (showEidNotification) {
        final eidPrayerTime = prayerTimes.sunrise.add(
          const Duration(minutes: 30),
        ); // Eid prayer is 30 minutes after sunrise
        _scheduleByKey(
          notificationService,
          _adjustNotificationTime(eidPrayerTime, settings),
          PrayerNotifKey.eid,
          settings,
          language,
          i,
        );
      }
    }
    debugPrint('[Notif] ✅ Scheduling complete');
  }

  void _scheduleByKey(
    NotificationService service,
    DateTime time,
    PrayerNotifKey key,
    PrayerTimesSettings settings,
    AppLanguage language,
    int dayOffset,
  ) {
    if (time.isBefore(DateTime.now())) {
      if (dayOffset == 0) {
        debugPrint(
          '[Notif]   ⏭️ ${key.name} (day $dayOffset) — skipped (time already passed: $time)',
        );
      }
      return;
    }
    if (settings.notificationSettings[key] != true) {
      if (dayOffset == 0) {
        debugPrint(
          '[Notif]   🔕 ${key.name} (day $dayOffset) — skipped (disabled)',
        );
      }
      return;
    }

    // Unique ID: dayOffset * 10 + key index
    // PrayerNotifKey has fewer than 10 values, so multiplier of 10 is safe.
    final id = dayOffset * 10 + key.index;

    final title = PrayerNotificationContent.getTitle(key, language, time: time);
    final body = PrayerNotificationContent.getBody(key, language);

    // Get the sound setting for this notification
    final sound = settings.getSound(key);
    final assetPath = sound.getAssetPath();

    // Convert to notification service format
    String? soundForNotification;
    if (sound == NotificationSound.silent) {
      soundForNotification = null; // No sound
    } else if (sound == NotificationSound.default_) {
      soundForNotification = ''; // Empty string for default
    } else {
      soundForNotification = assetPath; // Custom sound path
    }

    // Get volume type for custom sounds
    String? volumeType;
    if (sound == NotificationSound.falahSound) {
      final volumeTypeSetting = settings.getVolumeType(key);
      volumeType = volumeTypeSetting.name; // 'notification' or 'alarm'
    }

    debugPrint(
      '[Notif]   🔔 ${key.name} (day $dayOffset, id=$id, sound=${sound.name}, volume=${volumeType ?? 'default'}) — scheduled for $time',
    );

    service.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: time,
      soundAsset: soundForNotification,
      volumeType: volumeType,
    );
  }

  DateTime _adjustNotificationTime(
    DateTime time,
    PrayerTimesSettings settings,
  ) {
    return time.subtract(
      Duration(minutes: settings.notificationTiming.minutesEarlier),
    );
  }

  PrayerTimes _calculatePrayerTimes(
    DateTime date,
    UserLocation location,
    PrayerTimesSettings settings,
  ) {
    final CalculationParameters params = calculationParametersFor(
      settings.prayerCalcMethod,
    );
    params.madhab = madhabFor(
      settings.asrCalculationMethod,
      settings.prayerCalcMethod,
    );
    params.highLatitudeRule = highLatitudeRuleFor(
      settings.highLatitudeAdjustment,
    );

    return PrayerTimes(
      Coordinates(location.latitude, location.longitude),
      DateComponents(date.year, date.month, date.day),
      params,
    );
  }
}
