import 'package:flutter/widgets.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';

abstract final class AnalyticsScreenNames {
  static const onboarding = 'Onboarding Screen';
  static const permissions = 'Permissions Screen';

  static const home = 'Home Screen';
  static const quran = 'Quran Screen';
  static const qibla = 'Qibla Screen';
  static const settings = 'Settings Screen';
  static const language = 'Language Screen';
  static const location = 'Location Screen';
  static const countryPicker = 'Country Picker Screen';
  static const cityPicker = 'City Picker Screen';
  static const theme = 'Theme Screen';
  static const calculationMethod = 'Calculation Method Screen';
  static const juristicMethod = 'Juristic Method Screen';
  static const highLatitudeRule = 'High Latitude Rule Screen';
  static const hijriCorrection = 'Hijri Correction Screen';

  static const notificationSound = 'Notification Sound Screen';
  static const prayerNotificationSettings =
      'Prayer Notification Settings Screen';
  static const prayerNotificationEditor = 'Prayer Notification Editor Screen';
  static const notificationTiming = 'Notification Timing Screen';
  static const timeFormat = 'Time Format Screen';
  static const prayerTable = 'Prayer Table Screen';
  static const quranSectionPicker = 'Quran Section Picker Screen';
  static const quranAyahPicker = 'Quran Ayah Picker Screen';
  static const asmaulHusnaDetail = 'Asma ul Husna Detail Screen';

  static const _routeNames = <String, String>{
    Navigator.defaultRouteName: home,
    AppRoutes.prayerTimes: 'Prayer Times Screen',
    AppRoutes.ramadanCalendar: 'Ramadan Calendar Screen',
    AppRoutes.hijriCalendar: 'Hijri Calendar Screen',
    AppRoutes.asmaulHusna: 'Asma ul Husna Screen',
    AppRoutes.bookmarks: 'Bookmarks Screen',
    AppRoutes.developerSharedPrefs: 'Developer Preferences Screen',
    AppRoutes.developerPanel: 'Developer Panel Screen',
    AppRoutes.dailyPrayer: 'Daily Prayer Screen',
    AppRoutes.readQuranHome: 'Read Quran Screen',
    AppRoutes.listenQuranHome: 'Listen Quran Screen',
    AppRoutes.quranDetails: 'Quran Details Screen',
    AppRoutes.ayahFocus: 'Ayah Focus Screen',
    AppRoutes.quranViewSettings: 'Quran View Settings Screen',
    AppRoutes.chooseReciter: 'Choose Reciter Screen',
    AppRoutes.ayahPictureMaker: 'Ayah Picture Maker Screen',
    AppRoutes.translationSelection: 'Translation Selection Screen',
    AppRoutes.fontSelection: 'Font Selection Screen',
    AppRoutes.arabicFontSelection: 'Arabic Font Selection Screen',
    AppRoutes.sixteenLineQuran: 'Sixteen Line Quran Screen',
    AppRoutes.sixteenLineQuranJuzIndex: 'Quran Juz Index Screen',
    AppRoutes.namazPrayer: 'Namaz Prayer Screen',
    AppRoutes.namazPrayerDetail: 'Namaz Prayer Details Screen',
    AppRoutes.wuduProcedure: 'Wudu Procedure Screen',
    AppRoutes.wuduGuide: 'Wudu Guide Screen',
    AppRoutes.completeNamazGuide: 'Complete Namaz Guide Screen',
    AppRoutes.prayerCategory: 'Prayer Category Screen',
    AppRoutes.prayerDetail: 'Prayer Details Screen',
  };

  static String? fromRouteName(
    String? routeName, {
    String? defaultRouteScreenName,
  }) {
    if (routeName == null || routeName.isEmpty) return null;
    if (routeName == Navigator.defaultRouteName &&
        defaultRouteScreenName != null) {
      return defaultRouteScreenName;
    }
    return _routeNames[routeName] ?? routeName;
  }
}
