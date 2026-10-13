import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:rafeeq/utils/hijri_date_formatter.dart';

void main() {
  group('HijriDateFormatter', () {
    group('getUrduHijriMonth', () {
      test('returns correct month names for valid months', () {
        expect(HijriDateFormatter.getUrduHijriMonth(1), 'محرم');
        expect(HijriDateFormatter.getUrduHijriMonth(2), 'صفر');
        expect(HijriDateFormatter.getUrduHijriMonth(3), 'ربیع الاول');
        expect(HijriDateFormatter.getUrduHijriMonth(4), 'ربیع الثانی');
        expect(HijriDateFormatter.getUrduHijriMonth(5), 'جمادی الاول');
        expect(HijriDateFormatter.getUrduHijriMonth(6), 'جمادی الثانی');
        expect(HijriDateFormatter.getUrduHijriMonth(7), 'رجب');
        expect(HijriDateFormatter.getUrduHijriMonth(8), 'شعبان');
        expect(HijriDateFormatter.getUrduHijriMonth(9), 'رمضان');
        expect(HijriDateFormatter.getUrduHijriMonth(10), 'شوال');
        expect(HijriDateFormatter.getUrduHijriMonth(11), 'ذو القعدہ');
        expect(HijriDateFormatter.getUrduHijriMonth(12), 'ذو الحجہ');
      });

      test('throws ArgumentError for month 0', () {
        expect(
          () => HijriDateFormatter.getUrduHijriMonth(0),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for month 13', () {
        expect(
          () => HijriDateFormatter.getUrduHijriMonth(13),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for negative month', () {
        expect(
          () => HijriDateFormatter.getUrduHijriMonth(-1),
          throwsArgumentError,
        );
      });
    });

    group('formatShort', () {
      late HijriCalendar testDate;

      setUp(() {
        // 15 Ramadan 1445 = March 25, 2024
        testDate = HijriCalendar.fromDate(DateTime(2024, 3, 25));
      });

      testWidgets('formats with English locale correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatShort(
                  context,
                  testDate,
                );
                expect(result, '15 Ramadan');
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets(
        'formats with Urdu locale - uses Urdu numerals and month names',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('ur'),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: const [Locale('en'), Locale('ur')],
              home: Builder(
                builder: (context) {
                  final result = HijriDateFormatter.formatShort(
                    context,
                    testDate,
                  );
                  // Should contain Urdu numerals (۰-۹) and Urdu month name
                  expect(
                    result.contains('۱۵'),
                    true,
                    reason: 'Should contain Urdu numerals',
                  );
                  expect(
                    result.contains('رمضان'),
                    true,
                    reason: 'Should contain Urdu month name',
                  );
                  return const SizedBox();
                },
              ),
            ),
          );
        },
      );
    });

    group('formatLong', () {
      late HijriCalendar testDate;

      setUp(() {
        // 15 Ramadan 1445 = March 25, 2024
        testDate = HijriCalendar.fromDate(DateTime(2024, 3, 25));
      });

      testWidgets('formats with English locale correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatLong(context, testDate);
                expect(result, '15 Ramadan, 1445');
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets(
        'formats with Urdu locale - uses Urdu numerals and month names',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('ur'),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: const [Locale('en'), Locale('ur')],
              home: Builder(
                builder: (context) {
                  final result = HijriDateFormatter.formatLong(
                    context,
                    testDate,
                  );
                  // Should contain Urdu numerals (۰-۹) and Urdu month name
                  expect(
                    result.contains('۱۵'),
                    true,
                    reason: 'Should contain Urdu day numerals',
                  );
                  expect(
                    result.contains('۱۴۴۵'),
                    true,
                    reason: 'Should contain Urdu year numerals',
                  );
                  expect(
                    result.contains('رمضان'),
                    true,
                    reason: 'Should contain Urdu month name',
                  );
                  return const SizedBox();
                },
              ),
            ),
          );
        },
      );
    });

    group('edge cases', () {
      testWidgets('handles day 1 correctly', (tester) async {
        // 1 Muharram 1446 = July 7, 2024
        final testDate = HijriCalendar.fromDate(DateTime(2024, 7, 7));

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ur'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatLong(context, testDate);
                expect(
                  result.contains('۱'),
                  true,
                  reason: 'Should contain Urdu numeral 1',
                );
                expect(
                  result.contains('محرم'),
                  true,
                  reason: 'Should contain Muharram in Urdu',
                );
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('handles last day of year correctly', (tester) async {
        // 30 Dhu al-Hijjah 1444 = July 18, 2023
        final testDate = HijriCalendar.fromDate(DateTime(2023, 7, 18));

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ur'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatLong(context, testDate);
                expect(
                  result.contains('۳۰'),
                  true,
                  reason: 'Should contain Urdu numeral 30',
                );
                expect(
                  result.contains('ذو الحجہ'),
                  true,
                  reason: 'Should contain Dhu al-Hijjah in Urdu',
                );
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('handles leap year dates correctly', (tester) async {
        // Test with a date that might be in a leap year
        final testDate = HijriCalendar.fromDate(DateTime(2024, 2, 29));

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatLong(context, testDate);
                // February 29, 2024 should map to a valid Hijri date
                expect(result.isNotEmpty, true);
                expect(result.contains(','), true);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('localization edge cases', () {
      testWidgets('formats correctly for non-Urdu non-English locales', (
        tester,
      ) async {
        final testDate = HijriCalendar.fromDate(DateTime(2024, 3, 25));

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'), // Arabic
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en'), Locale('ur'), Locale('ar')],
            home: Builder(
              builder: (context) {
                final result = HijriDateFormatter.formatShort(
                  context,
                  testDate,
                );
                // Should use English numerals and Hijri month name from library
                expect(result, '15 Ramadan');
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });
  });
}
