import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rafeeq/core/navigation/analytics_observer.dart';
import 'package:rafeeq/core/navigation/app_router.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/core/navigation/current_route_provider.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/ui/quran/ayah_focus_screen.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_overlay.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TranslationHiddenSettingsNotifier extends QuranViewSettingsNotifier {
  @override
  QuranViewSettings build() =>
      QuranViewSettings.defaultSettings.copyWith(showTranslation: false);
}

class _TestQuranAudioController extends QuranAudioController {
  int? requestedJumpAyah;
  int? requestedSurahNumber;

  @override
  QuranAudioState build() => const QuranAudioState();

  void setPlayerVisible(bool isVisible) {
    state = QuranAudioState(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      surahArabicName: 'الفاتحة',
      reciterName: 'Test reciter',
      ayahs: const [
        Ayah(
          number: 1,
          numberInSurah: 1,
          text: 'بِسْمِ اللَّهِ',
          juz: 1,
          surahNumber: 1,
        ),
      ],
      isVisible: isVisible,
    );
  }

  void setProgressState({required Duration duration, required bool isLoading}) {
    state = QuranAudioState(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      surahArabicName: 'الفاتحة',
      reciterName: 'Test reciter',
      ayahs: const [
        Ayah(
          number: 1,
          numberInSurah: 1,
          text: 'بِسْمِ اللَّهِ',
          juz: 1,
          surahNumber: 1,
        ),
      ],
      duration: duration,
      isPlaying: true,
      isLoading: isLoading,
      isVisible: true,
    );
  }

  void showFocusPlayback(List<Ayah> ayahs, {required int currentIndex}) {
    state = QuranAudioState(
      surahNumber: ayahs[currentIndex].surahNumber,
      surahName: 'Al-Fatihah',
      surahArabicName: 'الفاتحة',
      playbackScopeNumber: 1,
      ayahs: ayahs,
      currentIndex: currentIndex,
      isPlaying: true,
      isVisible: true,
    );
  }

  @override
  Future<void> jumpToAyah(int globalAyahNumber) async {
    requestedJumpAyah = globalAyahNumber;
    final index = state.ayahs.indexWhere(
      (ayah) => ayah.number == globalAyahNumber,
    );
    if (index >= 0) state = state.copyWith(currentIndex: index);
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
    state = QuranAudioState(
      surahNumber: surahNumber,
      surahName: surahName,
      surahArabicName: surahArabicName,
      playbackScopeNumber: surahNumber,
      ayahs: ayahs,
      isPlaying: true,
      isVisible: true,
    );
  }
}

class _PlaybackEndTestController extends QuranAudioController {
  int? requestedSurahNumber;
  int? requestedSurahStartAyah;
  int? requestedJuzNumber;
  int? requestedJuzStartAyah;

  @override
  QuranAudioState build() => const QuranAudioState();

  void showSurahAyah({
    required int surahNumber,
    required List<Ayah> ayahs,
    required int currentIndex,
  }) {
    state = QuranAudioState(
      surahNumber: surahNumber,
      surahName: 'Surah $surahNumber',
      surahArabicName: 'سورة',
      playbackScopeNumber: surahNumber,
      ayahs: ayahs,
      currentIndex: currentIndex,
      duration: const Duration(seconds: 5),
      isPlaying: true,
      isVisible: true,
    );
  }

  void showJuzAyah({
    required int juzNumber,
    required List<Ayah> ayahs,
    required int currentIndex,
  }) {
    state = QuranAudioState(
      surahNumber: ayahs[currentIndex].surahNumber,
      surahName: 'Surah ${ayahs[currentIndex].surahNumber}',
      surahArabicName: 'سورة',
      playbackScope: QuranPlaybackScope.juz,
      playbackScopeNumber: juzNumber,
      ayahs: ayahs,
      currentIndex: currentIndex,
      duration: const Duration(seconds: 5),
      isPlaying: true,
      isVisible: true,
    );
  }

  void completeSurah(int surahNumber) {
    state = QuranAudioState(
      surahNumber: surahNumber,
      surahName: 'Surah $surahNumber',
      surahArabicName: 'سورة',
      ayahs: [
        Ayah(
          number: surahNumber,
          numberInSurah: 1,
          text: 'آية',
          juz: 1,
          surahNumber: surahNumber,
        ),
      ],
      currentIndex: 0,
      duration: const Duration(seconds: 5),
      position: const Duration(seconds: 5),
      isPlaying: true,
      isVisible: true,
    );
    startPlaybackEndCountdown();
  }

  void completeJuz(int juzNumber) {
    state = QuranAudioState(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      surahArabicName: 'الفاتحة',
      playbackScope: QuranPlaybackScope.juz,
      playbackScopeNumber: juzNumber,
      ayahs: const [
        Ayah(number: 1, numberInSurah: 1, text: 'آية', juz: 1, surahNumber: 1),
      ],
      duration: const Duration(seconds: 5),
      position: const Duration(seconds: 5),
      isPlaying: true,
      isVisible: true,
    );
    startPlaybackEndCountdown();
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
    state = QuranAudioState(
      surahNumber: surahNumber,
      surahName: surahName,
      surahArabicName: surahArabicName,
      ayahs: ayahs,
      isPlaying: true,
      isVisible: true,
    );
  }

  @override
  Future<void> playJuz({
    required int juzNumber,
    int? startAyahGlobalNumber,
  }) async {
    requestedJuzNumber = juzNumber;
    requestedJuzStartAyah = startAyahGlobalNumber;
    state = QuranAudioState(
      playbackScope: QuranPlaybackScope.juz,
      playbackScopeNumber: juzNumber,
      isPlaying: true,
      isVisible: true,
    );
  }
}

Surah _testSurah(int number) {
  return Surah(
    surahNumber: number,
    name: 'سورة',
    englishName: 'Surah $number',
    englishNameTranslation: 'Test Surah',
    revelationType: 'Meccan',
    ayahs: [
      Ayah(
        number: number,
        numberInSurah: 1,
        text: 'آية',
        juz: 1,
        surahNumber: number,
      ),
    ],
  );
}

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  testWidgets('Ayah Focus hides translation when its view setting is off', (
    tester,
  ) async {
    var translationRequests = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranViewSettingsNotifierProvider.overrideWith(
            _TranslationHiddenSettingsNotifier.new,
          ),
          quranEditionTextProvider.overrideWith((ref, key) async {
            translationRequests++;
            return const {1: 'In the name of Allah'};
          }),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: const MaterialApp(home: AyahFocusScreen()),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AyahFocusScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setPlayerVisible(true);
    await tester.pumpAndSettle();

    expect(find.text('بِسْمِ اللَّهِ'), findsOneWidget);
    expect(find.text('In the name of Allah'), findsNothing);
    expect(translationRequests, 0);
  });

  testWidgets('keeps Ayah Focus reading-only and opens view settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranEditionTextProvider.overrideWith(
            (ref, key) async => const {1: 'In the name of Allah'},
          ),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: MaterialApp(
          home: const AyahFocusScreen(),
          routes: {
            AppRoutes.quranViewSettings: (_) =>
                const Scaffold(body: Text('View settings')),
          },
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AyahFocusScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;

    controller.setProgressState(
      duration: const Duration(minutes: 7),
      isLoading: true,
    );
    await tester.pump();

    expect(find.byType(Slider), findsNothing);
    expect(find.byTooltip('Quran audio settings'), findsNothing);
    expect(find.byTooltip('Quran view settings'), findsOneWidget);

    await tester.tap(find.byTooltip('Quran view settings'));
    await tester.pumpAndSettle();
    expect(find.text('View settings'), findsOneWidget);
  });

  testWidgets('focus app bar picks a Surah and jumps to a selected ayah', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const focusAyahs = [
      Ayah(
        number: 1,
        numberInSurah: 1,
        text: 'الآية الأولى',
        juz: 1,
        surahNumber: 1,
      ),
      Ayah(
        number: 2,
        numberInSurah: 2,
        text: 'الآية الثانية',
        juz: 1,
        surahNumber: 1,
      ),
    ];
    final surahOne = Surah(
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: focusAyahs,
    );
    final surahTwo = _testSurah(2);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(surah: [surahOne, surahTwo]),
          ),
          quranEditionTextProvider.overrideWith(
            (ref, key) async => const {1: 'First', 2: 'Second'},
          ),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: const MaterialApp(home: AyahFocusScreen()),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AyahFocusScreen)),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.showFocusPlayback(focusAyahs, currentIndex: 1);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_action')));
    await tester.pumpAndSettle();
    expect(find.text('Ayah 1'), findsOneWidget);
    expect(find.text('Ayah 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_ayah_picker_1')));
    await tester.pumpAndSettle();
    expect(controller.requestedJumpAyah, 1);

    await tester.tap(find.byKey(const ValueKey('quran_section_picker_action')));
    await tester.pumpAndSettle();
    expect(find.text('Choose Surah'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quran_surah_picker_2')));
    await tester.pumpAndSettle();
    expect(controller.requestedSurahNumber, 2);
    expect(find.text('2. Surah 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keeps one aligned control and crosses Surah boundaries immediately',
    (tester) async {
      const surahOneAyahs = [
        Ayah(number: 1, numberInSurah: 1, text: 'آية', juz: 1, surahNumber: 1),
        Ayah(number: 2, numberInSurah: 2, text: 'آية', juz: 1, surahNumber: 1),
      ];
      const surahTwoAyahs = [
        Ayah(number: 3, numberInSurah: 1, text: 'آية', juz: 1, surahNumber: 2),
        Ayah(number: 4, numberInSurah: 2, text: 'آية', juz: 2, surahNumber: 2),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quranDataProvider.overrideWith(
              (ref) async => QuranData(
                surah: [
                  Surah(
                    surahNumber: 1,
                    name: 'سورة',
                    englishName: 'Surah 1',
                    englishNameTranslation: 'One',
                    revelationType: 'Meccan',
                    ayahs: surahOneAyahs,
                  ),
                  Surah(
                    surahNumber: 2,
                    name: 'سورة',
                    englishName: 'Surah 2',
                    englishNameTranslation: 'Two',
                    revelationType: 'Medinan',
                    ayahs: surahTwoAyahs,
                  ),
                ],
              ),
            ),
            quranAudioControllerProvider.overrideWith(
              _PlaybackEndTestController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(bottomNavigationBar: QuranMiniPlayer()),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuranMiniPlayer)),
      );
      final controller =
          container.read(quranAudioControllerProvider.notifier)
              as _PlaybackEndTestController;
      controller.showSurahAyah(
        surahNumber: 1,
        ayahs: surahOneAyahs,
        currentIndex: 0,
      );
      await tester.pumpAndSettle();

      final previousControl = find.byKey(
        const ValueKey('quran_previous_ayah_control'),
      );
      final playPauseControl = find.byKey(
        const ValueKey('quran_play_pause_control'),
      );
      final previousCenter = tester.getCenter(previousControl);
      final pauseCenter = tester.getCenter(playPauseControl);
      final nextControl = find.byKey(const ValueKey('quran_next_ayah_control'));
      final nextCenter = tester.getCenter(nextControl);
      expect(
        find.byKey(const ValueKey('quran_next_ayah_control')),
        findsOneWidget,
      );

      controller.showSurahAyah(
        surahNumber: 1,
        ayahs: surahOneAyahs,
        currentIndex: 1,
      );
      await tester.pumpAndSettle();

      expect(tester.getCenter(previousControl), previousCenter);
      expect(tester.getCenter(playPauseControl), pauseCenter);
      expect(tester.getCenter(nextControl), nextCenter);

      await tester.tap(nextControl);
      await tester.pumpAndSettle();
      expect(controller.requestedSurahNumber, 2);
      expect(controller.requestedSurahStartAyah, 1);

      controller.showSurahAyah(
        surahNumber: 2,
        ayahs: surahTwoAyahs,
        currentIndex: 0,
      );
      await tester.pumpAndSettle();
      await tester.tap(previousControl);
      await tester.pumpAndSettle();
      expect(controller.requestedSurahNumber, 1);
      expect(controller.requestedSurahStartAyah, 2);

      controller.showJuzAyah(
        juzNumber: 1,
        ayahs: const [
          Ayah(
            number: 1,
            numberInSurah: 1,
            text: 'آية',
            juz: 1,
            surahNumber: 1,
          ),
          Ayah(
            number: 2,
            numberInSurah: 2,
            text: 'آية',
            juz: 1,
            surahNumber: 1,
          ),
          Ayah(
            number: 3,
            numberInSurah: 1,
            text: 'آية',
            juz: 1,
            surahNumber: 2,
          ),
        ],
        currentIndex: 2,
      );
      await tester.pumpAndSettle();
      await tester.tap(nextControl);
      await tester.pumpAndSettle();
      expect(controller.requestedJuzNumber, 2);
      expect(controller.requestedJuzStartAyah, isNull);

      controller.showJuzAyah(
        juzNumber: 2,
        ayahs: const [
          Ayah(
            number: 4,
            numberInSurah: 2,
            text: 'آية',
            juz: 2,
            surahNumber: 2,
          ),
        ],
        currentIndex: 0,
      );
      await tester.pumpAndSettle();
      await tester.tap(previousControl);
      await tester.pumpAndSettle();
      expect(controller.requestedJuzNumber, 1);
      expect(controller.requestedJuzStartAyah, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'offers available adjacent Quran sections for ten seconds after completion',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quranDataProvider.overrideWith(
              (ref) async => QuranData(
                surah: [
                  _testSurah(1),
                  _testSurah(2),
                  _testSurah(113),
                  _testSurah(114),
                ],
              ),
            ),
            quranAudioControllerProvider.overrideWith(
              _PlaybackEndTestController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(bottomNavigationBar: QuranMiniPlayer()),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuranMiniPlayer)),
      );
      final controller =
          container.read(quranAudioControllerProvider.notifier)
              as _PlaybackEndTestController;

      controller.completeSurah(1);
      await tester.pump();

      expect(find.text('Surah complete'), findsOneWidget);
      expect(find.text('Surah 1 • 10s'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quran_previous_selection_button')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('quran_next_selection_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.pause_rounded), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('quran_next_selection_button')),
      );
      await tester.pumpAndSettle();
      expect(controller.requestedSurahNumber, 2);

      controller.completeSurah(114);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('quran_previous_selection_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quran_next_selection_button')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('quran_previous_selection_button')),
      );
      await tester.pumpAndSettle();
      expect(controller.requestedSurahNumber, 113);

      controller.completeJuz(1);
      await tester.pump();
      expect(find.text('Juz complete'), findsOneWidget);
      expect(find.text('Juz 1 • 10s'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quran_previous_selection_button')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('quran_next_selection_button')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('quran_next_selection_button')),
      );
      await tester.pumpAndSettle();
      expect(controller.requestedJuzNumber, 2);

      controller.completeJuz(30);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('quran_previous_selection_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quran_next_selection_button')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('quran_previous_selection_button')),
      );
      await tester.pumpAndSettle();
      expect(controller.requestedJuzNumber, 29);

      controller.completeSurah(2);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('quran_previous_selection_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('quran_next_selection_button')),
        findsOneWidget,
      );
      expect(
        container.read(quranAudioControllerProvider).playbackEndProgress,
        0,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(
        container.read(quranAudioControllerProvider).playbackEndProgress,
        closeTo(0.4, 0.02),
      );
      expect(find.text('Surah 2 • 6s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      expect(container.read(quranAudioControllerProvider).isVisible, isFalse);
      expect(
        find.byKey(const ValueKey('quran_mini_player_content')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps the Navigator mounted when the mini player appears', (
    tester,
  ) async {
    final analytics = _MockFirebaseAnalytics();
    when(
      () => analytics.logScreenView(
        screenClass: any(named: 'screenClass'),
        screenName: any(named: 'screenName'),
        callOptions: any(named: 'callOptions'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(analytics),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) => MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [AnalyticsNavigatorObserver(ref)],
            initialRoute: '/reader',
            builder: (context, child) =>
                QuranPlayerHost(child: child ?? const SizedBox.shrink()),
            routes: {
              '/reader': (_) => const Scaffold(body: Text('Reader')),
              '/second': (_) => const Scaffold(body: Text('Second route')),
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Reader'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Reader')),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setPlayerVisible(true);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Reader'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsOneWidget);

    container.read(currentRouteNameProvider.notifier).state =
        AppRoutes.ayahFocus;
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(QuranMiniPlayer), findsOneWidget);
    expect(find.text('Test reciter • 1'), findsOneWidget);
    expect(find.text('Tap to read • 1'), findsNothing);

    container.read(currentRouteNameProvider.notifier).state =
        AppRoutes.quranDetails;
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(QuranMiniPlayer), findsNothing);

    navigatorKey.currentState!.pushReplacementNamed('/second');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Reader'), findsNothing);
    expect(find.text('Second route'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsOneWidget);

    controller.setPlayerVisible(false);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Second route'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsNothing);
  });

  testWidgets('shows one mini player after returning to the app home route', (
    tester,
  ) async {
    final analytics = _MockFirebaseAnalytics();
    when(
      () => analytics.logScreenView(
        screenClass: any(named: 'screenClass'),
        screenName: any(named: 'screenName'),
        callOptions: any(named: 'callOptions'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(analytics),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) => MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [AnalyticsNavigatorObserver(ref)],
            builder: (context, child) =>
                QuranPlayerHost(child: child ?? const SizedBox.shrink()),
            routes: {
              '/': (_) => const Scaffold(
                body: Text('Quran list'),
                bottomNavigationBar: QuranMiniPlayer(),
              ),
              AppRoutes.quranDetails: (_) => const Scaffold(
                body: Text('Quran details'),
                bottomNavigationBar: QuranMiniPlayer(
                  onQuranDetailsScreen: true,
                ),
              ),
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.text('Quran list')),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setPlayerVisible(true);
    await tester.pumpAndSettle();

    expect(find.byType(QuranMiniPlayer), findsOneWidget);

    navigatorKey.currentState!.pushNamed(AppRoutes.quranDetails);
    await tester.pumpAndSettle();

    expect(find.text('Quran details'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(find.text('Quran list'), findsOneWidget);
    expect(find.byType(QuranMiniPlayer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the current ayah for reading and then expansion', (
    tester,
  ) async {
    final analytics = _MockFirebaseAnalytics();
    when(
      () => analytics.logScreenView(
        screenClass: any(named: 'screenClass'),
        screenName: any(named: 'screenName'),
        callOptions: any(named: 'callOptions'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    final surah = Surah(
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: const [
        Ayah(
          number: 1,
          numberInSurah: 1,
          text: 'بِسْمِ اللَّهِ',
          juz: 1,
          surahNumber: 1,
        ),
      ],
    );
    QuranDetailsArgs? openedDetails;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(analytics),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(surah: [surah]),
          ),
          quranAudioControllerProvider.overrideWith(
            _TestQuranAudioController.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) => MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [AnalyticsNavigatorObserver(ref)],
            builder: (context, child) =>
                QuranPlayerHost(child: child ?? const SizedBox.shrink()),
            initialRoute: '/other',
            onGenerateRoute: (settings) {
              if (settings.name == '/other') {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const Scaffold(body: Text('Other screen')),
                );
              }
              if (settings.name == AppRoutes.quranDetails) {
                openedDetails = settings.arguments! as QuranDetailsArgs;
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const Scaffold(
                    body: Text('Quran details target'),
                    bottomNavigationBar: QuranMiniPlayer(
                      onQuranDetailsScreen: true,
                    ),
                  ),
                );
              }
              if (settings.name == AppRoutes.ayahFocus) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) =>
                      const Scaffold(body: Text('Ayah focus target')),
                );
              }
              if (settings.name == AppRoutes.chooseReciter) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) =>
                      const Scaffold(body: Text('Reciter selection target')),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.text('Other screen')),
    );
    final controller =
        container.read(quranAudioControllerProvider.notifier)
            as _TestQuranAudioController;
    controller.setPlayerVisible(true);
    await tester.pumpAndSettle();

    expect(find.text('Tap to view • 1'), findsOneWidget);
    await tester.tap(find.text('Tap to view • 1'));
    await tester.pumpAndSettle();

    expect(find.text('Quran details target'), findsOneWidget);
    expect(openedDetails?.initialAyahNumber, 1);
    expect(find.text('Tap to expand • 1'), findsOneWidget);

    await tester.tap(find.text('Tap to expand • 1'));
    await tester.pumpAndSettle();

    expect(find.text('Ayah focus target'), findsOneWidget);
    expect(find.text('Test reciter • 1'), findsOneWidget);

    await tester.tap(find.text('Test reciter • 1'));
    await tester.pumpAndSettle();

    expect(find.text('Reciter selection target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
