import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';

void main() {
  test('uses a clear name for the default route', () {
    expect(
      AnalyticsScreenNames.fromRouteName(Navigator.defaultRouteName),
      'Home Screen',
    );
  });

  test('allows the initial screen to override the default route name', () {
    expect(
      AnalyticsScreenNames.fromRouteName(
        Navigator.defaultRouteName,
        defaultRouteScreenName: AnalyticsScreenNames.onboarding,
      ),
      AnalyticsScreenNames.onboarding,
    );
  });

  test('maps registered route paths to readable screen names', () {
    const registeredRoutes = <String>[
      AppRoutes.prayerTimes,
      AppRoutes.ramadanCalendar,
      AppRoutes.hijriCalendar,
      AppRoutes.asmaulHusna,
      AppRoutes.developerSharedPrefs,
      AppRoutes.developerPanel,
      AppRoutes.dailyPrayer,
      AppRoutes.readQuranHome,
      AppRoutes.listenQuranHome,
      AppRoutes.quranDetails,
      AppRoutes.quranViewSettings,
      AppRoutes.chooseReciter,
      AppRoutes.ayahPictureMaker,
      AppRoutes.translationSelection,
      AppRoutes.fontSelection,
      AppRoutes.arabicFontSelection,
      AppRoutes.sixteenLineQuran,
      AppRoutes.sixteenLineQuranJuzIndex,
      AppRoutes.namazPrayer,
      AppRoutes.namazPrayerDetail,
      AppRoutes.wuduProcedure,
      AppRoutes.wuduGuide,
      AppRoutes.completeNamazGuide,
      AppRoutes.prayerCategory,
      AppRoutes.prayerDetail,
    ];

    for (final route in registeredRoutes) {
      final screenName = AnalyticsScreenNames.fromRouteName(route);
      expect(screenName, isNot(startsWith('/')), reason: route);
      expect(screenName, endsWith('Screen'), reason: route);
    }
  });

  test('preserves an explicitly supplied readable screen name', () {
    expect(
      AnalyticsScreenNames.fromRouteName(AnalyticsScreenNames.language),
      'Language Screen',
    );
  });

  test('uses readable names for settings picker screens', () {
    expect(AnalyticsScreenNames.calculationMethod, 'Calculation Method Screen');
    expect(AnalyticsScreenNames.location, 'Location Screen');
    expect(AnalyticsScreenNames.juristicMethod, 'Juristic Method Screen');
    expect(AnalyticsScreenNames.highLatitudeRule, 'High Latitude Rule Screen');
    expect(AnalyticsScreenNames.hijriCorrection, 'Hijri Correction Screen');
    expect(
      AnalyticsScreenNames.prayerNotificationSettings,
      'Prayer Notification Settings Screen',
    );
    expect(
      AnalyticsScreenNames.quranSectionPicker,
      'Quran Section Picker Screen',
    );
    expect(AnalyticsScreenNames.quranAyahPicker, 'Quran Ayah Picker Screen');
  });

  test('ignores missing route names', () {
    expect(AnalyticsScreenNames.fromRouteName(null), isNull);
    expect(AnalyticsScreenNames.fromRouteName(''), isNull);
  });
}
