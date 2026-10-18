import 'package:adhan/adhan.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/current_day_provider.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';

final prayerTimesProvider = Provider.family
    .autoDispose<PrayerTimes, UserLocation>((ref, location) {
      final settings = ref.watch(prayerTimesSettingsNotifierProvider);
      final parameters = calculationParametersFor(settings.prayerCalcMethod)
        ..madhab = madhabFor(
          settings.asrCalculationMethod,
          settings.prayerCalcMethod,
        )
        ..highLatitudeRule = highLatitudeRuleFor(
          settings.highLatitudeAdjustment,
        );
      final today = ref.watch(currentDayProvider);
      return PrayerTimes(
        Coordinates(location.latitude, location.longitude),
        DateComponents(today.year, today.month, today.day),
        parameters,
      );
    });

final prayerTimesForDateProvider = Provider.family
    .autoDispose<PrayerTimes, (UserLocation, DateTime)>((ref, args) {
      final (location, date) = args;
      final settings = ref.watch(prayerTimesSettingsNotifierProvider);
      final parameters = calculationParametersFor(settings.prayerCalcMethod)
        ..madhab = madhabFor(
          settings.asrCalculationMethod,
          settings.prayerCalcMethod,
        )
        ..highLatitudeRule = highLatitudeRuleFor(
          settings.highLatitudeAdjustment,
        );
      return PrayerTimes(
        Coordinates(location.latitude, location.longitude),
        DateComponents(date.year, date.month, date.day),
        parameters,
      );
    });

HighLatitudeRule highLatitudeRuleFor(HLAdjustment method) {
  return switch (method) {
    HLAdjustment.angleBased => HighLatitudeRule.twilight_angle,
    HLAdjustment.middleOfTheNight => HighLatitudeRule.middle_of_the_night,
    HLAdjustment.oneSeventh => HighLatitudeRule.seventh_of_the_night,
  };
}

Madhab madhabFor(
  AsrCalculationMethod method,
  PrayerCalcMethod calculationMethod,
) {
  if (calculationMethod == PrayerCalcMethod.jafari) return Madhab.shafi;
  return switch (method) {
    AsrCalculationMethod.hanafi => Madhab.hanafi,
    AsrCalculationMethod.others => Madhab.shafi,
  };
}

CalculationParameters calculationParametersFor(PrayerCalcMethod method) {
  return switch (method) {
    PrayerCalcMethod.muslim_world_league =>
      CalculationMethod.muslim_world_league.getParameters(),
    PrayerCalcMethod.egyptian => CalculationMethod.egyptian.getParameters(),
    PrayerCalcMethod.karachi => CalculationMethod.karachi.getParameters(),
    PrayerCalcMethod.umm_al_qura =>
      CalculationMethod.umm_al_qura.getParameters(),
    PrayerCalcMethod.dubai => CalculationMethod.dubai.getParameters(),
    PrayerCalcMethod.moon_sighting_committee =>
      CalculationMethod.moon_sighting_committee.getParameters(),
    PrayerCalcMethod.north_america =>
      CalculationMethod.north_america.getParameters(),
    PrayerCalcMethod.kuwait => CalculationMethod.kuwait.getParameters(),
    PrayerCalcMethod.qatar => CalculationMethod.qatar.getParameters(),
    PrayerCalcMethod.singapore => CalculationMethod.singapore.getParameters(),
    PrayerCalcMethod.turkey => CalculationMethod.turkey.getParameters(),
    PrayerCalcMethod.tehran => CalculationMethod.tehran.getParameters(),
    PrayerCalcMethod.jafari => CalculationParameters(
      fajrAngle: 16,
      ishaAngle: 14,
      maghribAngle: 4,
      method: CalculationMethod.other,
    ),
  };
}
