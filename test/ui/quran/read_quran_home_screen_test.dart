import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/read_quran_home_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _IndexPlaybackTestController extends QuranAudioController {
  int toggleCount = 0;
  int nextSelectionCount = 0;

  @override
  QuranAudioState build() => const QuranAudioState();

  void setActive({required bool isPlaying, bool isComplete = false}) {
    state = QuranAudioState(
      surahNumber: 1,
      surahName: 'Al-Fatiha',
      surahArabicName: 'الفاتحة',
      playbackScope: QuranPlaybackScope.surah,
      playbackScopeNumber: 1,
      ayahs: const [
        Ayah(
          number: 1,
          numberInSurah: 1,
          text: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          juz: 1,
          surahNumber: 1,
        ),
      ],
      isPlaying: isPlaying,
      isVisible: true,
      isPlaybackComplete: isComplete,
      playbackEndRemaining: isComplete
          ? QuranAudioState.playbackEndGracePeriod
          : Duration.zero,
    );
  }

  @override
  Future<void> togglePlayPause() async {
    toggleCount++;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  @override
  Future<void> playNextSelection() async {
    nextSelectionCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final quranData = QuranData(
    surah: [
      Surah(
        surahNumber: 1,
        englishName: 'Al-Fatiha',
        englishNameTranslation: 'The Opening',
        name: 'الفاتحة',
        revelationType: 'Meccan',
        ayahs: [
          Ayah(
            number: 1,
            numberInSurah: 1,
            text: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            juz: 1,
            surahNumber: 1,
          ),
        ],
      ),
      Surah(
        surahNumber: 2,
        englishName: 'Al-Baqarah',
        englishNameTranslation: 'The Cow',
        name: 'البقرة',
        revelationType: 'Medinan',
        ayahs: [
          Ayah(
            number: 2,
            numberInSurah: 1,
            text: 'الم',
            juz: 1,
            surahNumber: 2,
          ),
        ],
      ),
    ],
  );

  ThemeData testTheme() {
    return ThemeData.dark().copyWith(
      extensions: const [
        RafeeqTheme(
          bgColor: Color(0xFF041C32),
          primaryColor: Color(0xFF064663),
          secondaryColor: Color(0xFF064663),
          textColor: Colors.white,
        ),
      ],
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool useTestAudioController = false,
    Locale locale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith((ref) async => quranData),
          if (useTestAudioController)
            quranAudioControllerProvider.overrideWith(
              _IndexPlaybackTestController.new,
            ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: testTheme(),
          home: const ReadQuranHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses the shared app bar and list-only Quran navigation', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(RafeeqAppBar), findsOneWidget);
    expect(find.text("Qur'an"), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmarks_outlined), findsNothing);
    expect(find.byIcon(Icons.grid_view_outlined), findsNothing);
    expect(find.byIcon(Icons.view_list_outlined), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Surah'), findsOneWidget);
    expect(find.text('Juz'), findsOneWidget);
    expect(find.text('Page'), findsNothing);
    expect(find.text('Topic'), findsNothing);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('Al-Fatiha'), findsOneWidget);
    expect(find.text('The Opening'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
  });

  testWidgets('search action opens the themed Quran search field', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    final searchField = find.byKey(const Key('quran-app-bar-search-field'));
    expect(searchField, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: searchField),
      findsOneWidget,
    );
    expect(
      find.text('Search Quran (Arabic or Translation)...'),
      findsOneWidget,
    );

    await tester.enterText(searchField, 'baqarah');
    await tester.pump();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('The Cow'), findsOneWidget);
    expect(find.text('Al-Fatiha'), findsNothing);
  });

  testWidgets('uses Urdu meanings and RTL-aligned tabs in Urdu', (
    tester,
  ) async {
    await pumpScreen(tester, locale: const Locale('ur'));

    expect(find.text('آغاز'), findsOneWidget);
    expect(find.text('The Opening'), findsNothing);

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.tabAlignment, TabAlignment.start);
    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.byType(TabBar),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.rtl);

    await tester.tap(find.text('جز'));
    await tester.pumpAndSettle();
    expect(find.text('پہلا سپارہ'), findsOneWidget);
    expect(find.text('Juz 1'), findsNothing);
  });

  testWidgets(
    'active Quran tile toggles in place and offers Next after completion',
    (tester) async {
      await pumpScreen(tester, useTestAudioController: true);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ReadQuranHomeScreen)),
      );
      final controller =
          container.read(quranAudioControllerProvider.notifier)
              as _IndexPlaybackTestController;

      controller.setActive(isPlaying: true);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('quran_active_playback_wave')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quran_index_next_selection_button')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('quran_active_playback_button')),
      );
      await tester.pump();

      expect(controller.toggleCount, 1);
      expect(
        find.byKey(const ValueKey('quran_active_playback_wave')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.byKey(const ValueKey('quran_active_playback_button')),
      );
      await tester.pump();

      expect(controller.toggleCount, 2);
      expect(
        find.byKey(const ValueKey('quran_active_playback_wave')),
        findsOneWidget,
      );

      controller.setActive(isPlaying: false, isComplete: true);
      await tester.pump();

      final nextButton = find.byKey(
        const ValueKey('quran_index_next_selection_button'),
      );
      expect(nextButton, findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(nextButton);
      await tester.pump();

      expect(controller.nextSelectionCount, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
