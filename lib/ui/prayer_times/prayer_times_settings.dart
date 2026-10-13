// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:rafeeq/data/services/notification_service.dart';
import 'package:rafeeq/data/storage/storage_box.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';

/// Notification keys — separate from the adhan `Prayer` enum so that
/// Suhoor and Iftar can each have their own independent toggle.
enum PrayerNotifKey {
  suhoor,
  fajr,
  sunrise,
  dhuhr,
  asr,
  iftar,
  maghrib,
  isha,
  eid,
}

extension PrayerNotifKeyExtension on PrayerNotifKey {
  bool get isDailyPrayer => switch (this) {
    PrayerNotifKey.fajr ||
    PrayerNotifKey.dhuhr ||
    PrayerNotifKey.asr ||
    PrayerNotifKey.maghrib ||
    PrayerNotifKey.isha => true,
    _ => false,
  };

  List<NotificationSound> get availableSounds => isDailyPrayer
      ? NotificationSound.values
      : const [NotificationSound.silent, NotificationSound.default_];

  bool supportsSound(NotificationSound sound) =>
      availableSounds.contains(sound);
}

/// Notification sound options
enum NotificationSound {
  silent, // No sound
  default_, // System default
  falahSound, // azan1.mp3
}

enum NotificationTiming {
  onTime(0),
  fiveMinutesEarlier(5),
  tenMinutesEarlier(10),
  fifteenMinutesEarlier(15);

  const NotificationTiming(this.minutesEarlier);

  final int minutesEarlier;

  String getLabel(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    if (minutesEarlier == 0) return isUrdu ? 'وقت پر' : 'On time';
    final unit = isUrdu ? 'منٹ پہلے' : 'minutes earlier';
    return '$minutesEarlier $unit';
  }
}

/// Volume type for custom notification sounds
enum NotificationVolumeType {
  notification, // Uses device notification volume
  alarm, // Uses device alarm volume (louder)
}

extension NotificationVolumeTypeExtension on NotificationVolumeType {
  String getLabel(BuildContext context) {
    switch (this) {
      case NotificationVolumeType.notification:
        return context.loc.volumeNotification;
      case NotificationVolumeType.alarm:
        return context.loc.volumeAlarm;
    }
  }

  String getDescription(BuildContext context) {
    switch (this) {
      case NotificationVolumeType.notification:
        return context.loc.volumeNotificationDesc;
      case NotificationVolumeType.alarm:
        return context.loc.volumeAlarmDesc;
    }
  }
}

extension NotificationSoundExtension on NotificationSound {
  String getLabel(BuildContext context) {
    switch (this) {
      case NotificationSound.silent:
        return context.loc.soundSilent;
      case NotificationSound.default_:
        return context.loc.soundDefault;
      case NotificationSound.falahSound:
        return context.loc.soundSalah;
    }
  }

  String? getAssetPath() {
    switch (this) {
      case NotificationSound.silent:
        return null;
      case NotificationSound.default_:
        return null;
      case NotificationSound.falahSound:
        return 'assets/sounds/azan1.mp3';
    }
  }

  IconData getIcon() {
    switch (this) {
      case NotificationSound.silent:
        return Icons.notifications_off;
      case NotificationSound.default_:
        return Icons.notifications;
      case NotificationSound.falahSound:
        return Icons.music_note;
    }
  }
}

final prayerTimesStorageBoxProvider = Provider<StorageBox<PrayerTimesSettings>>(
  (ref) {
    final factory = ref.watch(storageBoxProvider);
    return factory.create<PrayerTimesSettings>(
      "prayer_times_settings",
      encoder: (PrayerTimesSettings value) => jsonEncode(value.toMap()),
      decoder: (String value) => PrayerTimesSettings.fromMap(
        jsonDecode(value) as Map<String, dynamic>,
      ),
      defaultValue: PrayerTimesSettings.defaultSettings,
    );
  },
);

final prayerTimesSettingsNotifierProvider =
    NotifierProvider<PrayerTimesSettingsNotifier, PrayerTimesSettings>(
      PrayerTimesSettingsNotifier.new,
    );

class PrayerTimesSettingsNotifier extends Notifier<PrayerTimesSettings> {
  late final StorageBox<PrayerTimesSettings> _storageBox;

  @override
  PrayerTimesSettings build() {
    _storageBox = ref.watch(prayerTimesStorageBoxProvider);
    return _storageBox.get();
  }

  @override
  set state(PrayerTimesSettings value) {
    super.state = value;
    _storageBox.set(value);
  }

  void setAsrCalculationMethod(AsrCalculationMethod asrCalculationMethod) {
    state = state.copyWith(asrCalculationMethod: asrCalculationMethod);
  }

  void setPrayerCalcMethod(PrayerCalcMethod prayerCalcMethod) {
    state = state.copyWith(prayerCalcMethod: prayerCalcMethod);
  }

  void setHighLatitudeAdjustment(HLAdjustment highLatitudeAdjustment) {
    state = state.copyWith(highLatitudeAdjustment: highLatitudeAdjustment);
  }

  void setTimeFormat(TimeFormatOption timeFormat) {
    state = state.copyWith(timeFormat: timeFormat);
  }

  Future<void> toggleNotification(PrayerNotifKey key) async {
    final currentSettings = Map<PrayerNotifKey, bool>.from(
      state.notificationSettings,
    );
    final newValue = !(currentSettings[key] ?? false);

    // When enabling a notification, request permission first.
    // This is the only place we ask for permission so the user is always
    // in control — the system dialog (or settings screen on Android) only
    // appears as a direct result of the user tapping the toggle.
    if (newValue) {
      final notificationService = ref.read(notificationServiceProvider);
      final hasPermission = await notificationService.hasPermission();
      if (!hasPermission) {
        final granted = await notificationService.requestPermissions();
        if (granted != true) {
          debugPrint('[Notif] ⚠️ Permission denied — not enabling ${key.name}');
          return;
        }
      }
    }

    currentSettings[key] = newValue;
    debugPrint('[Notif] 🔔 Toggle ${key.name} → ${newValue ? "ON" : "OFF"}');
    state = state.copyWith(notificationSettings: currentSettings);
  }

  void setNotificationSound(PrayerNotifKey key, NotificationSound sound) {
    if (!key.supportsSound(sound)) return;

    final currentSounds = Map<PrayerNotifKey, NotificationSound>.from(
      state.notificationSounds,
    );
    currentSounds[key] = sound;
    debugPrint('[Notif] 🎵 Sound ${key.name} → ${sound.name}');
    state = state.copyWith(notificationSounds: currentSounds);
  }

  NotificationSound getNotificationSound(PrayerNotifKey key) {
    return state.getSound(key);
  }

  void setNotificationVolumeType(
    PrayerNotifKey key,
    NotificationVolumeType volumeType,
  ) {
    final currentVolumeTypes = Map<PrayerNotifKey, NotificationVolumeType>.from(
      state.notificationVolumeTypes,
    );
    currentVolumeTypes[key] = volumeType;
    debugPrint('[Notif] 🔊 Volume ${key.name} → ${volumeType.name}');
    state = state.copyWith(notificationVolumeTypes: currentVolumeTypes);
  }

  void setNotificationTiming(NotificationTiming timing) {
    state = state.copyWith(notificationTiming: timing);
  }

  NotificationVolumeType getNotificationVolumeType(PrayerNotifKey key) {
    return state.notificationVolumeTypes[key] ??
        NotificationVolumeType.notification;
  }
}

class PrayerTimesSettings {
  final AsrCalculationMethod asrCalculationMethod;
  final PrayerCalcMethod prayerCalcMethod;
  final HLAdjustment highLatitudeAdjustment;
  final TimeFormatOption timeFormat;
  final Map<PrayerNotifKey, bool> notificationSettings;
  final Map<PrayerNotifKey, NotificationSound> notificationSounds;
  final Map<PrayerNotifKey, NotificationVolumeType> notificationVolumeTypes;
  final NotificationTiming notificationTiming;

  const PrayerTimesSettings({
    required this.asrCalculationMethod,
    required this.prayerCalcMethod,
    required this.highLatitudeAdjustment,
    this.timeFormat = TimeFormatOption.twelveHour,
    this.notificationSettings = const {
      PrayerNotifKey.suhoor: true,
      PrayerNotifKey.fajr: true,
      PrayerNotifKey.sunrise: true,
      PrayerNotifKey.dhuhr: true,
      PrayerNotifKey.asr: true,
      PrayerNotifKey.iftar: true,
      PrayerNotifKey.maghrib: true,
      PrayerNotifKey.isha: true,
      PrayerNotifKey.eid: true,
    },
    this.notificationSounds = const {
      // 5 daily prayers use Salah Sound
      PrayerNotifKey.fajr: NotificationSound.falahSound,
      PrayerNotifKey.dhuhr: NotificationSound.falahSound,
      PrayerNotifKey.asr: NotificationSound.falahSound,
      PrayerNotifKey.maghrib: NotificationSound.falahSound,
      PrayerNotifKey.isha: NotificationSound.falahSound,
      // Others use Default
      PrayerNotifKey.suhoor: NotificationSound.default_,
      PrayerNotifKey.sunrise: NotificationSound.default_,
      PrayerNotifKey.iftar: NotificationSound.default_,
      PrayerNotifKey.eid: NotificationSound.default_,
    },
    this.notificationVolumeTypes = const {
      // Default: Custom sounds use alarm volume (louder)
      PrayerNotifKey.fajr: NotificationVolumeType.alarm,
      PrayerNotifKey.dhuhr: NotificationVolumeType.alarm,
      PrayerNotifKey.asr: NotificationVolumeType.alarm,
      PrayerNotifKey.maghrib: NotificationVolumeType.alarm,
      PrayerNotifKey.isha: NotificationVolumeType.alarm,
      PrayerNotifKey.suhoor: NotificationVolumeType.notification,
      PrayerNotifKey.sunrise: NotificationVolumeType.notification,
      PrayerNotifKey.iftar: NotificationVolumeType.notification,
      PrayerNotifKey.eid: NotificationVolumeType.notification,
    },
    this.notificationTiming = NotificationTiming.onTime,
  });

  PrayerTimesSettings copyWith({
    AsrCalculationMethod? asrCalculationMethod,
    PrayerCalcMethod? prayerCalcMethod,
    HLAdjustment? highLatitudeAdjustment,
    TimeFormatOption? timeFormat,
    Map<PrayerNotifKey, bool>? notificationSettings,
    Map<PrayerNotifKey, NotificationSound>? notificationSounds,
    Map<PrayerNotifKey, NotificationVolumeType>? notificationVolumeTypes,
    NotificationTiming? notificationTiming,
  }) {
    return PrayerTimesSettings(
      asrCalculationMethod: asrCalculationMethod ?? this.asrCalculationMethod,
      prayerCalcMethod: prayerCalcMethod ?? this.prayerCalcMethod,
      highLatitudeAdjustment:
          highLatitudeAdjustment ?? this.highLatitudeAdjustment,
      timeFormat: timeFormat ?? this.timeFormat,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      notificationSounds: notificationSounds ?? this.notificationSounds,
      notificationVolumeTypes:
          notificationVolumeTypes ?? this.notificationVolumeTypes,
      notificationTiming: notificationTiming ?? this.notificationTiming,
    );
  }

  NotificationSound getSound(PrayerNotifKey key) {
    final sound = notificationSounds[key] ?? NotificationSound.default_;
    return key.supportsSound(sound) ? sound : NotificationSound.default_;
  }

  NotificationVolumeType getVolumeType(PrayerNotifKey key) {
    return notificationVolumeTypes[key] ?? NotificationVolumeType.notification;
  }

  Map<String, dynamic> toMap() {
    return {
      'asrCalculationMethod': asrCalculationMethod.name,
      'prayerCalcMethod': prayerCalcMethod.name,
      'highLatitudeAdjustment': highLatitudeAdjustment.name,
      'timeFormat': timeFormat.name,
      'notificationSettings': notificationSettings.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'notificationSounds': notificationSounds.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'notificationVolumeTypes': notificationVolumeTypes.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'notificationTiming': notificationTiming.name,
    };
  }

  static const PrayerTimesSettings defaultSettings = PrayerTimesSettings(
    asrCalculationMethod: AsrCalculationMethod.hanafi,
    prayerCalcMethod: PrayerCalcMethod.karachi,
    highLatitudeAdjustment: HLAdjustment.angleBased,
    timeFormat: TimeFormatOption.twelveHour,
  );

  factory PrayerTimesSettings.fromMap(Map<String, dynamic> map) {
    return PrayerTimesSettings(
      asrCalculationMethod: _parseEnum(
        map['asrCalculationMethod'],
        AsrCalculationMethod.values,
        AsrCalculationMethod.hanafi,
      ),
      prayerCalcMethod: _parseEnum(
        map['prayerCalcMethod'],
        PrayerCalcMethod.values,
        PrayerCalcMethod.karachi,
      ),
      highLatitudeAdjustment: _parseEnum(
        map['highLatitudeAdjustment'],
        HLAdjustment.values,
        HLAdjustment.angleBased,
      ),
      timeFormat:
          TimeFormatOption.values
              .where((element) => element.name == map['timeFormat'])
              .firstOrNull ??
          TimeFormatOption.twelveHour,
      notificationSettings: _parseNotificationSettings(
        map['notificationSettings'],
      ),
      notificationSounds: _parseNotificationSounds(map['notificationSounds']),
      notificationVolumeTypes: _parseNotificationVolumeTypes(
        map['notificationVolumeTypes'],
      ),
      notificationTiming: _parseEnum(
        map['notificationTiming'],
        NotificationTiming.values,
        NotificationTiming.onTime,
      ),
    );
  }

  static T _parseEnum<T extends Enum>(dynamic raw, List<T> values, T fallback) {
    if (raw is String) {
      return values.where((value) => value.name == raw).firstOrNull ?? fallback;
    }
    if (raw is int && raw >= 0 && raw < values.length) {
      return values[raw];
    }
    return fallback;
  }

  static Map<PrayerNotifKey, bool> _parseNotificationSettings(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) {
      return defaultSettings.notificationSettings;
    }
    final result = Map<PrayerNotifKey, bool>.from(
      defaultSettings.notificationSettings,
    );
    for (final entry in raw.entries) {
      // Try name-based keys first (new format)
      final byName = PrayerNotifKey.values
          .where((e) => e.name == entry.key)
          .firstOrNull;
      if (byName != null) {
        result[byName] = entry.value as bool;
        continue;
      }
      // Fall back to old int-index-based keys (legacy Prayer.index format)
      final idx = int.tryParse(entry.key);
      if (idx != null) {
        // Map old Prayer indices to new PrayerNotifKey values
        const legacyMapping = {
          0: PrayerNotifKey.fajr, // Prayer.fajr
          1: PrayerNotifKey.sunrise, // Prayer.sunrise
          2: PrayerNotifKey.dhuhr, // Prayer.dhuhr
          3: PrayerNotifKey.asr, // Prayer.asr
          4: PrayerNotifKey.maghrib, // Prayer.maghrib
          5: PrayerNotifKey.isha, // Prayer.isha
        };
        final mapped = legacyMapping[idx];
        if (mapped != null) {
          result[mapped] = entry.value as bool;
        }
      }
    }
    return result;
  }

  static Map<PrayerNotifKey, NotificationSound> _parseNotificationSounds(
    dynamic raw,
  ) {
    if (raw == null || raw is! Map<String, dynamic>) {
      return defaultSettings.notificationSounds;
    }
    final result = Map<PrayerNotifKey, NotificationSound>.from(
      defaultSettings.notificationSounds,
    );
    for (final entry in raw.entries) {
      final key = PrayerNotifKey.values
          .where((e) => e.name == entry.key)
          .firstOrNull;
      final sound = NotificationSound.values
          .where((e) => e.name == entry.value)
          .firstOrNull;
      if (key != null && sound != null) {
        result[key] = sound;
      }
    }
    return result;
  }

  static Map<PrayerNotifKey, NotificationVolumeType>
  _parseNotificationVolumeTypes(dynamic raw) {
    if (raw == null || raw is! Map<String, dynamic>) {
      return defaultSettings.notificationVolumeTypes;
    }
    final result = Map<PrayerNotifKey, NotificationVolumeType>.from(
      defaultSettings.notificationVolumeTypes,
    );
    for (final entry in raw.entries) {
      final key = PrayerNotifKey.values
          .where((e) => e.name == entry.key)
          .firstOrNull;
      final volumeType = NotificationVolumeType.values
          .where((e) => e.name == entry.value)
          .firstOrNull;
      if (key != null && volumeType != null) {
        result[key] = volumeType;
      }
    }
    return result;
  }
}

/// High Latitude Adjustment
enum HLAdjustment {
  angleBased,
  middleOfTheNight,
  oneSeventh;

  String getLabel(BuildContext context) {
    switch (this) {
      case angleBased:
        return context.loc.highLatAngleBased;
      case middleOfTheNight:
        return context.loc.highLatMiddleNight;
      case oneSeventh:
        return context.loc.highLatOneSeventh;
    }
  }

  String get label {
    switch (this) {
      case angleBased:
        return "Angle Based";
      case middleOfTheNight:
        return "Middle of the Night";
      case oneSeventh:
        return "1/7th of the Night";
    }
  }
}

enum PrayerCalcMethod {
  muslim_world_league,
  egyptian,
  karachi,
  umm_al_qura,
  dubai,
  moon_sighting_committee,
  north_america,
  kuwait,
  qatar,
  singapore,
  turkey,
  tehran,
  jafari;

  String getLabel(BuildContext context) {
    switch (this) {
      case muslim_world_league:
        return context.loc.calcMethodMWL;
      case egyptian:
        return context.loc.calcMethodEgyptian;
      case karachi:
        return context.loc.calcMethodKarachi;
      case umm_al_qura:
        return context.loc.calcMethodUmmAlQura;
      case dubai:
        return context.loc.calcMethodDubai;
      case moon_sighting_committee:
        return context.loc.calcMethodMoonsighting;
      case north_america:
        return context.loc.calcMethodNorthAmerica;
      case kuwait:
        return context.loc.calcMethodKuwait;
      case qatar:
        return context.loc.calcMethodQatar;
      case singapore:
        return context.loc.calcMethodSingapore;
      case turkey:
        return context.loc.calcMethodTurkey;
      case tehran:
        return context.loc.calcMethodTehran;
      case jafari:
        return context.loc.calcMethodJafari;
    }
  }

  String get label {
    switch (this) {
      case muslim_world_league:
        return "Muslim World League";
      case egyptian:
        return "Egyptian General Authority of Survey";
      case karachi:
        return "University of Islamic Sciences, Karachi";
      case umm_al_qura:
        return "Umm al-Qura University, Makkah";
      case dubai:
        return "Umm al-Qura University, Dubai";
      case moon_sighting_committee:
        return "Moonsighting Committee";
      case north_america:
        return "North American";
      case kuwait:
        return "Umm al-Qura University, Kuwait";
      case qatar:
        return "Umm al-Qura University, Qatar";
      case singapore:
        return "Singapore";
      case turkey:
        return "Turkey";
      case tehran:
        return "Tehran University";
      case jafari:
        return "Shia Ithna-Ashari (Jafari)";
    }
  }
}

enum AsrCalculationMethod {
  hanafi,
  others;

  String getLabel(BuildContext context) {
    switch (this) {
      case hanafi:
        return context.loc.asrMethodHanafi;
      case others:
        return context.loc.asrMethodStandard;
    }
  }

  String get label {
    switch (this) {
      case hanafi:
        return "Hanafi";
      case others:
        return "Shafi'i, Maliki, Hanbali";
    }
  }
}

enum TimeFormatOption {
  twelveHour,
  twentyFourHour;

  String getLabel(BuildContext context) {
    switch (this) {
      case twelveHour:
        return context.loc.timeFormat12Hour;
      case twentyFourHour:
        return context.loc.timeFormat24Hour;
    }
  }

  String get label {
    switch (this) {
      case twelveHour:
        return "12-Hour";
      case twentyFourHour:
        return "24-Hour";
    }
  }

  String formatTime(DateTime? dateTime, {String? languageCode}) {
    if (dateTime == null) return "";
    final isRtl =
        languageCode != null &&
        (languageCode == 'ur' || languageCode == 'ar' || languageCode == 'fa');

    switch (this) {
      case twelveHour:
        final value = intl.DateFormat('hh:mm a', 'en').format(dateTime);
        // Isolate the complete time as LTR so RTL layouts cannot move AM/PM
        // before the digits. The visible result remains "06:31 PM".
        return isRtl ? '\u2066$value\u2069' : value;
      case twentyFourHour:
        final value = intl.DateFormat('HH:mm', 'en').format(dateTime);
        return isRtl ? '\u2066$value\u2069' : value;
    }
  }

  /// Formats time with proper RTL handling
  String formatTimeWithContext(BuildContext context, DateTime? dateTime) {
    final locale = Localizations.localeOf(context);
    return formatTime(dateTime, languageCode: locale.languageCode);
  }
}
