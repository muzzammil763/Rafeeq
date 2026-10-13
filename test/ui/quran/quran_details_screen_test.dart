import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/providers/surah_info_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestQuranViewSettingsNotifier extends QuranViewSettingsNotifier {
  @override
  QuranViewSettings build() =>
      QuranViewSettings.defaultSettings.copyWith(showTranslation: false);
}

class _TestDetailsAudioController extends QuranAudioController {
  int? requestedJuzNumber;
  int? requestedStartAyah;
  int? requestedSurahNumber;
  int? requestedSurahStartAyah;

  @override
  QuranAudioState build() => const QuranAudioState();

  @override
  Future<void> playJuz({
    required int juzNumber,
    int? startAyahGlobalNumber,
  }) async {
    requestedJuzNumber = juzNumber;
    requestedStartAyah = startAyahGlobalNumber;
  }

  @override
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required String surahArabicName,
    required List<Ayah> ayahs,
    int startAyahNumber = 1,
  }) async {
    requestedSurahNumber = surahNumber;
    requestedSurahStartAyah = startAyahNumber;
  }

  void showJuzPlayback(List<Ayah> ayahs, {required int currentIndex}) {
    final currentAyah = ayahs[currentIndex];
    state = QuranAudioState(
      surahNumber: currentAyah.surahNumber,
      surahName: currentAyah.surahNumber == 1 ? 'Al-Fatihah' : 'Al-Baqarah',
      surahArabicName: currentAyah.surahNumber == 1 ? 'الفاتحة' : 'البقرة',
      playbackScope: QuranPlaybackScope.juz,
      playbackScopeNumber: 1,
      ayahs: ayahs,
      currentIndex: currentIndex,
      isPlaying: true,
      isVisible: true,
    );
  }

  void showSurahPlayback(Surah surah, {int currentIndex = 0}) {
    state = QuranAudioState(
      surahNumber: surah.surahNumber,
      surahName: surah.englishName,
      surahArabicName: surah.name,
      playbackScopeNumber: surah.surahNumber,
      ayahs: surah.ayahs,
      currentIndex: currentIndex,
      isPlaying: true,
      isVisible: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ayahs = [
    Ayah(
      number: 1,
      numberInSurah: 1,
      text: 'بِسْمِ اللَّهِ',
      juz: 1,
      surahNumber: 1,
    ),
    Ayah(number: 8, numberInSurah: 1, text: 'الم', juz: 1, surahNumber: 2),
  ];
  const surahInfos = [
    SurahInfo(
      number: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 1,
      revelationType: 'Meccan',
    ),
    SurahInfo(
      number: 2,
      name: 'البقرة',
      englishName: 'Al-Baqarah',
      englishNameTranslation: 'The Cow',
      numberOfAyahs: 1,
      revelationType: 'Medinan',
    ),
  ];
  final surahs = [
    Surah(
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: [ayahs[0]],
    ),
    Surah(
      surahNumber: 2,
      name: 'البقرة',
      englishName: 'Al-Baqarah',
      englishNameTranslation: 'The Cow',
      revelationType: 'Medinan',
      ayahs: [ayahs[1]],
    ),
  ];

  testWidgets('Juz playback crosses Surahs and updates the app-bar counter', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(surah: surahs),
          ),
          surahInfoProvider.overrideWith((ref) => surahInfos),
          quranEditionTextProvider.overrideWith((ref, key) async => const {}),
          quranViewSettingsNotifierProvider.overrideWith(
            _TestQuranViewSettingsNotifier.new,
          ),
          quranAudioControllerProvider.overrideWith(
            _TestDetailsAudioController.new,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuranDetailsScreen(args: JuzQuranDetailArgs(Juz.first, ayahs)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuranDetailsScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestDetailsAudioController;

    await tester.tap(find.text('Play Audio').first);
    await tester.pump();

    expect(controller.requestedJuzNumber, 1);
    expect(controller.requestedStartAyah, 1);

    controller.showJuzPlayback(ayahs, currentIndex: 1);
    await tester.pump();

    expect(find.text('Ayah 2/2 • Al-Baqarah 1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quran_mini_player_content')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('quran_section_picker_action')));
    await tester.pumpAndSettle();
    expect(find.text('Choose Juz'), findsOneWidget);
    expect(find.text('Juz 1'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows playback when audio advances to the next Surah', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(surah: surahs),
          ),
          surahInfoProvider.overrideWith((ref) => surahInfos),
          quranEditionTextProvider.overrideWith((ref, key) async => const {}),
          quranViewSettingsNotifierProvider.overrideWith(
            _TestQuranViewSettingsNotifier.new,
          ),
          quranAudioControllerProvider.overrideWith(
            _TestDetailsAudioController.new,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuranDetailsScreen(
            args: SurahQuranDetailArgs(surahs[0], ayahs),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuranDetailsScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestDetailsAudioController;

    controller.showSurahPlayback(surahs[1]);
    await tester.pumpAndSettle();

    expect(find.text('2. Al-Baqarah'), findsOneWidget);
    expect(find.text('الم'), findsOneWidget);
    expect(find.text('1. Al-Fatihah'), findsNothing);
    expect(find.byTooltip('Jump To Ayah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_action')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_8')));
    await tester.pumpAndSettle();
    expect(controller.requestedSurahNumber, 2);
    expect(controller.requestedSurahStartAyah, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens section and ayah pickers from the reader app bar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(surah: surahs),
          ),
          surahInfoProvider.overrideWith((ref) => surahInfos),
          quranEditionTextProvider.overrideWith((ref, key) async => const {}),
          quranViewSettingsNotifierProvider.overrideWith(
            _TestQuranViewSettingsNotifier.new,
          ),
          quranAudioControllerProvider.overrideWith(
            _TestDetailsAudioController.new,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.ayahPictureMaker) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) =>
                    const Scaffold(body: Text('Ayah Picture destination')),
              );
            }
            return null;
          },
          home: QuranDetailsScreen(
            args: SurahQuranDetailArgs(surahs[0], ayahs),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuranDetailsScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestDetailsAudioController;

    await tester.tap(find.byKey(const ValueKey('quran_section_picker_action')));
    await tester.pumpAndSettle();

    expect(find.text('Choose Surah'), findsOneWidget);
    expect(find.text('1 - Al-Fatihah'), findsOneWidget);
    expect(find.text('2 - Al-Baqarah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_surah_picker_2')));
    await tester.pumpAndSettle();
    expect(find.text('2. Al-Baqarah'), findsOneWidget);
    expect(find.byKey(const ValueKey('surah-2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_action')));
    await tester.pumpAndSettle();
    expect(find.text('Jump To Ayah'), findsOneWidget);
    expect(find.text('Ayah 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_8')));
    await tester.pumpAndSettle();
    expect(find.text('Jump To Ayah'), findsNothing);
    expect(find.text('2. Al-Baqarah'), findsOneWidget);
    expect(controller.requestedSurahNumber, isNull);

    await tester.tap(find.byTooltip('Share ayah'));
    await tester.pumpAndSettle();
    expect(find.text('Ayah Picture destination'), findsOneWidget);
    final route = ModalRoute.of(
      tester.element(find.text('Ayah Picture destination')),
    );
    final args = route?.settings.arguments as AyahPictureMakerArgs?;
    expect(args?.surahNumber, 2);
    expect(args?.ayahNumber, 1);
    expect(tester.takeException(), isNull);
  });
}
