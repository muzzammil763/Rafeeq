import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled policies contain matching English and Urdu sections', () async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/legal.json'))
            as Map<String, dynamic>;
    for (final kind in ['privacy', 'terms']) {
      final en = data[kind]['en']['sections'] as List;
      final ur = data[kind]['ur']['sections'] as List;
      expect(en.length, greaterThan(5));
      expect(ur.length, en.length);
      for (final section in [...en, ...ur]) {
        expect(section['title'], isNotEmpty);
        expect(section['body'], isNotEmpty);
      }
    }
  });

  for (final locale in ['en', 'ur']) {
    for (final route in [AppRoutes.privacy, AppRoutes.terms]) {
      testWidgets('$route loads offline in $locale and scrolls to contact', (
        tester,
      ) async {
        // Large asset decoding uses an isolate; resolve it outside fake time.
        await tester.runAsync(() => rootBundle.loadString('assets/legal.json'));
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            theme: ThemeData(
              brightness: locale == 'ur' ? Brightness.dark : Brightness.light,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: route,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump();
        final title = route == AppRoutes.privacy
            ? (locale == 'ur' ? 'رازداری کی پالیسی' : 'Privacy Policy')
            : (locale == 'ur' ? 'شرائط و ضوابط' : 'Terms & Conditions');
        expect(find.text(title), findsOneWidget);
        expect(find.byType(SelectionArea), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('satechdev18@gmail.com'),
          600,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 70,
        );
        expect(find.text('satechdev18@gmail.com'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
