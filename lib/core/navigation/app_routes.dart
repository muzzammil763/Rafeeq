import 'package:flutter/material.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/models/daily_prayer.dart';
import 'package:rafeeq/ui/about/about_screen.dart';
import 'package:rafeeq/ui/about/version_screen.dart';
import 'package:rafeeq/ui/asma_ul_husna/asma_ul_husna_screen.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_maker_screen.dart';
import 'package:rafeeq/ui/bookmarks/bookmarks_screen.dart';
import 'package:rafeeq/ui/choose_recitor/choose_recitor_screen.dart';
import 'package:rafeeq/ui/developer/developer_panel_screen.dart';
import 'package:rafeeq/ui/developer/developer_shared_prefs_screen.dart';
import 'package:rafeeq/ui/hijri_calendar/hijri_calendar_screen.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_screen.dart';
import 'package:rafeeq/ui/prayer_times/daily_prayer_screen.dart';
import 'package:rafeeq/ui/prayer_times/prayer_category_screen.dart';
import 'package:rafeeq/ui/prayer_times/prayer_detail_screen.dart';
import 'package:rafeeq/ui/namaz/namaz_prayer_screen.dart';
import 'package:rafeeq/ui/namaz/namaz_prayer_detail_screen.dart';
import 'package:rafeeq/ui/namaz/wudu_screen.dart';
import 'package:rafeeq/ui/namaz/namaz_guide_screen.dart';
import 'package:rafeeq/ui/quran/listen_quran_home_screen.dart';
import 'package:rafeeq/ui/quran/ayah_focus_screen.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/ui/quran/read_quran_home_screen.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/sixteen_line_quran_screen.dart';
import 'package:rafeeq/ui/quran/sixteen_line_quran/quran_juz_index_screen.dart';
import 'package:rafeeq/ui/ramadan/ramadan_calendar_screen.dart';

// ---------------------------------------------------------------------------
// Route name constants — the complete navigation graph of the app
// ---------------------------------------------------------------------------
class AppRoutes {
  AppRoutes._();

  // -- General --
  static const prayerTimes = '/prayer-times';
  static const about = '/about';
  static const version = '/version';
  static const ramadanCalendar = '/ramadan-calendar';
  static const hijriCalendar = '/hijri-calendar';
  static const asmaulHusna = '/asmaul-husna';
  static const bookmarks = '/bookmarks';
  static const developerSharedPrefs = '/developer/shared-prefs';
  static const developerPanel = '/developer';
  static const dailyPrayer = '/daily-prayer';

  // -- Quran --
  static const readQuranHome = '/quran/read';
  static const listenQuranHome = '/quran/listen';

  static const quranDetails = '/quran/details';
  static const ayahFocus = '/quran/ayah-focus';
  static const quranViewSettings = '/quran/view-settings';
  static const chooseReciter = '/quran/choose-reciter';
  static const ayahPictureMaker = '/quran/ayah-picture';
  static const translationSelection = '/quran/translation-selection';
  static const fontSelection = '/quran/font-selection';
  static const arabicFontSelection = '/quran/arabic-font-selection';
  static const sixteenLineQuran = '/quran/sixteen-line-quran';
  static const sixteenLineQuranJuzIndex = '/quran/sixteen-line-quran-juz-index';

  // -- Daily Prayer / Namaz --
  static const namazPrayer = '/namaz-prayer';
  static const namazPrayerDetail = '/namaz-prayer/detail';
  static const wuduProcedure = '/wudu-procedure';
  static const wuduGuide = '/wudu-guide';
  static const completeNamazGuide = '/namaz-prayer/complete-guide';
  static const prayerCategory = '/daily-prayer/category';
  static const prayerDetail = '/daily-prayer/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case about:
        return _build(settings, const AboutScreen());

      case version:
        return _build(settings, const VersionScreen());

      case prayerTimes:
        return _build(settings, const PrayerTimesScreen());

      case ramadanCalendar:
        return _build(settings, const RamadanCalendarScreen());

      case hijriCalendar:
        return _build(settings, const HijriCalendarScreen());

      case asmaulHusna:
        return _build(settings, const AsmaulHusnaScreen());

      case bookmarks:
        return _build(settings, const BookmarksScreen());

      case developerSharedPrefs:
        return _build(settings, const DeveloperSharedPrefsScreen());

      case developerPanel:
        return _build(settings, const DeveloperPanelScreen());

      case readQuranHome:
        return _build(settings, const ReadQuranHomeScreen());

      case sixteenLineQuran:
        final args = settings.arguments as Map<String, dynamic>?;
        return _build(
          settings,
          SixteenLineQuranScreen(
            juzNumber: args?['juzNumber'] as int?,
            startPage: args?['startPage'] as int? ?? 0,
          ),
        );

      case sixteenLineQuranJuzIndex:
        return _build(settings, const QuranJuzIndexScreen());

      case listenQuranHome:
        final args = settings.arguments as ListenQuranArgs;
        return _build(settings, ListenQuranHomeScreen(args.surahList));

      case quranDetails:
        final args = settings.arguments as QuranDetailsArgs;
        return _build(
          settings,
          QuranDetailsScreen(
            args: args.detailArgs,
            initialAyahNumber: args.initialAyahNumber,
            autoPlay: args.autoPlay,
          ),
        );

      case ayahFocus:
        return _build(settings, const AyahFocusScreen());

      case quranViewSettings:
        return _build(settings, const QuranViewSettingsScreen());

      case chooseReciter:
        return _build(settings, const ChooseReciterScreen());

      case ayahPictureMaker:
        final args = settings.arguments as AyahPictureMakerArgs?;
        return _build(
          settings,
          AyahPictureMakerScreen(
            initialSurahNumber: args?.surahNumber ?? 1,
            initialAyahNumber: args?.ayahNumber ?? 1,
            initialAsmaNumber: args?.asmaNumber,
          ),
        );

      case translationSelection:
        return _build(settings, const TranslationSelectionPage());

      case dailyPrayer:
        return _build(settings, const DailyPrayerScreen());

      case namazPrayer:
        return _build(settings, const NamazPrayerScreen());

      case namazPrayerDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          NamazPrayerDetailScreen(prayerId: args['prayerId'] as String),
        );

      case wuduProcedure:
        return _build(settings, const WuduScreen());

      case wuduGuide:
        return _build(settings, const WuduScreen());

      case completeNamazGuide:
        return _build(settings, const NamazGuideScreen());

      case prayerCategory:
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          PrayerCategoryScreen(
            categoryId: args['categoryId'] as String,
            categoryName: args['categoryName'] as String,
          ),
        );

      case prayerDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _build(
          settings,
          PrayerDetailScreen(prayer: args['prayer'] as DailyPrayer),
        );

      default:
        return _build(
          settings,
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<T> _build<T>(RouteSettings settings, Widget page) {
    return MaterialPageRoute<T>(settings: settings, builder: (_) => page);
  }
}

// ---------------------------------------------------------------------------
// Argument classes for parameterized routes
// ---------------------------------------------------------------------------

class QuranDetailsArgs {
  final QuranDetailArgs detailArgs;
  final int? initialAyahNumber;
  final bool autoPlay;

  const QuranDetailsArgs(
    this.detailArgs, {
    this.initialAyahNumber,
    this.autoPlay = false,
  });
}

class AyahPictureMakerArgs {
  const AyahPictureMakerArgs.ayah({
    required this.surahNumber,
    required this.ayahNumber,
  }) : asmaNumber = null;

  const AyahPictureMakerArgs.asma({required this.asmaNumber})
    : surahNumber = null,
      ayahNumber = null;

  final int? surahNumber;
  final int? ayahNumber;
  final int? asmaNumber;
}

class ListenQuranArgs {
  final List<Surah> surahList;

  const ListenQuranArgs(this.surahList);
}
