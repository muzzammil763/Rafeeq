import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/data/raw/namaz_prayers_raw.dart';
import 'package:rafeeq/data/raw/wudu_steps_raw.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/namaz/namaz_guide_screen.dart';
import 'package:rafeeq/ui/namaz/wudu_screen.dart';

void main() {
  setUpAll(() {
    initializeNamazPrayers(namazPrayersJson);
    initializeWuduSteps(wuduStepsJson);
  });

  testWidgets('shows exact headings and locale-specific meanings', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const NamazGuideScreen()));

    expect(find.text('1- Takbeer'), findsOneWidget);
    expect(find.text('2- Sana'), findsOneWidget);
    expect(find.text('Allah is the Greatest.'), findsOneWidget);
    expect(find.text('Allahu Akbar'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('wudu_guide_tile')),
        matching: find.byIcon(CupertinoIcons.drop_fill),
      ),
      findsNothing,
    );

    final arabic = tester.widget<Text>(find.text('اللهُ أَكْبَرْ').first);
    expect(arabic.style?.fontSize, 30);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(arabic.textAlign, TextAlign.right);

    await tester.scrollUntilVisible(
      find.text("3- Ta'awwuz"),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("3- Ta'awwuz"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _testApp(const NamazGuideScreen(), locale: const Locale('ur')),
    );
    await tester.pumpAndSettle();

    expect(find.text('۱- تکبیر'), findsOneWidget);
    expect(find.text('اللہ سب سے بڑا ہے'), findsOneWidget);
    expect(find.text('Allah is the Greatest.'), findsNothing);
  });

  testWidgets('shows Wudu steps inline with direct larger Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const WuduScreen()));

    expect(find.text('1- Intention (Niyyah)'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    final arabic = tester.widget<Text>(find.text('بِسْمِ اللَّهِ'));
    expect(arabic.style?.fontSize, 28);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _testApp(const WuduScreen(), locale: const Locale('ur')),
    );
    await tester.pumpAndSettle();

    expect(find.text('۱- نیت'), findsOneWidget);
    expect(
      find.text('دل میں نماز کے لیے وضو کرنے کی نیت کریں'),
      findsOneWidget,
    );
    expect(
      find.text('Make intention in your heart to perform Wudu for prayer'),
      findsNothing,
    );
  });
}

Widget _testApp(Widget home, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
      routes: {AppRoutes.wuduProcedure: (_) => const WuduScreen()},
    );
