import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/home_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool showAllCards = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (showAllCards)
        'app_settings': jsonEncode({
          'language': 'en',
          'hijriCorrection': 'none',
          'themeMode': 'light',
          'themeIndex': 0,
          'ramadanViewMode': 0,
          'showAllCards': true,
        }),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          quranDataProvider.overrideWith(
            (ref) async => QuranData(
              surah: [
                Surah(
                  surahNumber: 1,
                  name: 'Al-Fatihah',
                  englishName: 'Al-Fatihah',
                  englishNameTranslation: 'The Opening',
                  revelationType: 'Meccan',
                  ayahs: const [
                    Ayah(
                      number: 1,
                      numberInSurah: 1,
                      text: 'Dynamic daily ayah',
                      juz: 1,
                      surahNumber: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
          quranEditionTextProvider.overrideWith(
            (ref, key) async => {1: 'Dynamic daily translation'},
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
          home: const HomeScreen(),
          routes: {
            AppRoutes.namazPrayer: (_) =>
                const Scaffold(body: Text('Namaz destination')),
            AppRoutes.ayahPictureMaker: (_) =>
                const Scaffold(body: Text('Ayah Picture destination')),
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders the redesigned home sections', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester);

    final title = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Rafeeq'),
    );
    expect(title, findsOneWidget);
    expect(
      tester.widget<Text>(title).style?.color,
      SettingsPalette.light.title,
    );
    expect(find.byKey(const Key('home-app-logo')), findsNothing);
    expect(find.byKey(const Key('home-calligraphy')), findsNothing);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('New Look'), findsNothing);
    expect(find.text('Namaz'), findsOneWidget);
    expect(find.text('Dua & Zikr'), findsNothing);
    expect(find.text('Mosques'), findsNothing);
    expect(find.byType(HomePrayerFocusCard), findsOneWidget);
    final locationAction = find.byType(HomeLocationAction);
    expect(locationAction, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: locationAction),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(ListView), matching: locationAction),
      findsNothing,
    );

    await tester.dragUntilVisible(
      find.text('Today'),
      find.byType(ListView).first,
      const Offset(0, -100),
    );
    final today = find.text('Today');
    expect(today, findsOneWidget);

    await tester.dragUntilVisible(
      find.byType(HomePrayerTimeline),
      find.byType(ListView).first,
      const Offset(0, -100),
    );
    expect(find.byType(HomePrayerTimeline), findsOneWidget);

    await tester.dragUntilVisible(
      find.byType(ForbiddenPrayerTimesCard),
      find.byType(ListView).first,
      const Offset(0, -100),
    );
    final forbiddenTitle = find.text('Forbidden Salat Times');
    final forbiddenCards = find.byType(ForbiddenPrayerTimesCard);
    expect(forbiddenTitle, findsOneWidget);
    expect(forbiddenCards, findsOneWidget);
    expect(
      find.descendant(
        of: forbiddenCards,
        matching: find.byType(ForbiddenPrayerTimeCard),
      ),
      findsNWidgets(3),
    );
    expect(
      tester.getTopLeft(forbiddenCards).dy -
          tester.getBottomLeft(forbiddenTitle).dy,
      12,
    );
  });

  testWidgets('shows Hijri, Gregorian and weekday stacked without greeting', (
    tester,
  ) async {
    await pumpHome(tester);

    final today = DateTime.now();
    final dates = find.byKey(const Key('home-today-dates'));
    expect(dates, findsOneWidget);
    expect(find.text('السلام عليكم'), findsNothing);
    final texts = tester
        .widgetList<Text>(
          find.descendant(of: dates, matching: find.byType(Text)),
        )
        .map((text) => text.data)
        .toList();
    expect(texts, hasLength(3));
    expect(
      texts[1],
      '${today.day} ${DateFormat.MMMM('en').format(today)}, ${today.year}',
    );
    expect(texts[2], DateFormat.EEEE('en').format(today));
  });

  testWidgets('opens Namaz from the Explore grid', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Namaz'));
    await tester.pumpAndSettle();

    expect(find.text('Namaz destination'), findsOneWidget);
  });

  testWidgets('shows no Daily Ayah or Daily Dua card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.text('Daily Ayah'), findsNothing);
    expect(find.text('Dynamic daily translation'), findsNothing);
    expect(find.text('Daily Dua'), findsNothing);
  });

  testWidgets('opens Ayah Picture from the Explore grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpHome(tester);

    final ayahPictureCard = find.byKey(
      const ValueKey('explore-card-Ayah Picture'),
    );
    expect(
      find.descendant(of: ayahPictureCard, matching: find.text('NEW')),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Ayah Picture'),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayah Picture destination'), findsOneWidget);

    Navigator.of(tester.element(find.text('Ayah Picture destination'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('NEW'), findsNothing);
  });

  testWidgets('shows the Urdu app name as plain text in Urdu', (tester) async {
    await pumpHome(tester, locale: const Locale('ur'));

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('رفیق')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home-calligraphy')), findsNothing);
  });

  testWidgets('prayer focus artwork and countdown stay fixed in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: HomePrayerFocusCard(
              previousPrayer: 'Fajr',
              previousTime: '5:00 AM',
              nextPrayer: 'Dhuhr',
              nextTime: '12:30 PM',
              countdown: '02:15:00',
              progress: 0.5,
              palette: SettingsPalette.light,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final card = find.byType(HomePrayerFocusCard);
    final image = find.byKey(const Key('home-prayer-focus-image'));
    final countdown = find.byKey(const Key('home-prayer-focus-countdown'));

    expect(tester.getRect(image).right, tester.getRect(card).right);
    expect(tester.getRect(countdown).left, tester.getRect(card).left + 12);
  });

  testWidgets('show-all setting previews every event card and auto advances', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHome(tester, showAllCards: true);

    expect(find.byKey(const Key('home-focus-carousel')), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      expect(
        find.byKey(Key('home-focus-page-indicator-$index')),
        findsOneWidget,
      );
    }
    expect(tester.getSize(find.byType(HomePrayerFocusCard)).height, 176);

    final pageView = tester.widget<PageView>(
      find.byKey(const Key('home-focus-carousel')),
    );
    expect(pageView.controller?.page, 0);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 450));

    expect(pageView.controller?.page, 1);
    expect(find.byKey(const Key('home-friday-card')), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 450));

    expect(pageView.controller?.page, 2);
    expect(find.byKey(const Key('home-ramadan-card')), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 450));

    expect(pageView.controller?.page, 3);
    expect(find.byKey(const Key('home-eid-card')), findsOneWidget);
  });
}
