import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/bookmarks/bookmarks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockQuranData = QuranData(
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
    ],
  );

  ThemeData _testTheme() {
    final rafeeqTheme = const RafeeqTheme(
      bgColor: Color(0xff041c32),
      primaryColor: Color(0xff064663),
      secondaryColor: Color(0xff064663),
      textColor: Colors.white,
    );

    return ThemeData.dark().copyWith(
      extensions: [rafeeqTheme],
      scaffoldBackgroundColor: Colors.black,
      textTheme: ThemeData.dark().textTheme,
    );
  }

  Widget buildTestApp(Widget home, SharedPreferences prefs) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        quranDataProvider.overrideWith((ref) async => mockQuranData),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: _testTheme(),
        home: home,
      ),
    );
  }

  group('BookmarksScreen Widget Tests', () {
    testWidgets('renders empty state when no bookmarks are present', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(buildTestApp(const BookmarksScreen(), prefs));
        await tester.pumpAndSettle();

        expect(find.byType(BookmarksScreen), findsOneWidget);
        expect(find.text('No bookmarks yet'), findsOneWidget);
      });
    });

    testWidgets('displays list of bookmarked Ayahs', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({
          'ayah_bookmarks': ['1:1'],
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(buildTestApp(const BookmarksScreen(), prefs));
        await tester.pumpAndSettle();

        expect(find.text('الفاتحہ'), findsOneWidget);

        await tester.tap(find.text('الفاتحہ'));
        await tester.pumpAndSettle();

        expect(
          find.text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'),
          findsOneWidget,
        );
      });
    });
  });
}
