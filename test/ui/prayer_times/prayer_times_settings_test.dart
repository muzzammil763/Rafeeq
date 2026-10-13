import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

void main() {
  group('PrayerTimesSettings persistence', () {
    test('round trips calculation preferences by stable enum name', () {
      final original = PrayerTimesSettings.defaultSettings.copyWith(
        asrCalculationMethod: AsrCalculationMethod.others,
        prayerCalcMethod: PrayerCalcMethod.moon_sighting_committee,
        highLatitudeAdjustment: HLAdjustment.oneSeventh,
      );

      final encoded = original.toMap();
      final decoded = PrayerTimesSettings.fromMap(encoded);

      expect(encoded['asrCalculationMethod'], 'others');
      expect(encoded['prayerCalcMethod'], 'moon_sighting_committee');
      expect(encoded['highLatitudeAdjustment'], 'oneSeventh');
      expect(decoded.asrCalculationMethod, AsrCalculationMethod.others);
      expect(
        decoded.prayerCalcMethod,
        PrayerCalcMethod.moon_sighting_committee,
      );
      expect(decoded.highLatitudeAdjustment, HLAdjustment.oneSeventh);
    });

    test('loads legacy numeric calculation preferences', () {
      final decoded = PrayerTimesSettings.fromMap({
        'asrCalculationMethod': AsrCalculationMethod.others.index,
        'prayerCalcMethod': PrayerCalcMethod.qatar.index,
        'highLatitudeAdjustment': HLAdjustment.middleOfTheNight.index,
      });

      expect(decoded.asrCalculationMethod, AsrCalculationMethod.others);
      expect(decoded.prayerCalcMethod, PrayerCalcMethod.qatar);
      expect(decoded.highLatitudeAdjustment, HLAdjustment.middleOfTheNight);
    });
  });

  group('PrayerTimesSettings notification sounds', () {
    test('non-prayer reminders reject a saved Salah sound', () {
      final settings = PrayerTimesSettings.defaultSettings.copyWith(
        notificationSounds: {
          ...PrayerTimesSettings.defaultSettings.notificationSounds,
          PrayerNotifKey.sunrise: NotificationSound.falahSound,
          PrayerNotifKey.eid: NotificationSound.falahSound,
        },
      );

      expect(
        settings.getSound(PrayerNotifKey.sunrise),
        NotificationSound.default_,
      );
      expect(settings.getSound(PrayerNotifKey.eid), NotificationSound.default_);
    });

    test('only daily prayers offer Salah Sound', () {
      const dailyPrayers = {
        PrayerNotifKey.fajr,
        PrayerNotifKey.dhuhr,
        PrayerNotifKey.asr,
        PrayerNotifKey.maghrib,
        PrayerNotifKey.isha,
      };

      for (final key in PrayerNotifKey.values) {
        expect(
          key.availableSounds.contains(NotificationSound.falahSound),
          dailyPrayers.contains(key),
          reason: key.name,
        );
        expect(key.availableSounds, contains(NotificationSound.silent));
        expect(key.availableSounds, contains(NotificationSound.default_));
      }
    });

    test('defaults use Salah Sound only for the five daily prayers', () {
      for (final key in PrayerNotifKey.values) {
        expect(
          PrayerTimesSettings.defaultSettings.getSound(key),
          key.isDailyPrayer
              ? NotificationSound.falahSound
              : NotificationSound.default_,
          reason: key.name,
        );
      }
    });
  });
}
