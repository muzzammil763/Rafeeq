import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/data/raw/namaz_prayers_raw.dart';
import 'package:rafeeq/data/raw/wudu_steps_raw.dart';
import 'package:rafeeq/ui/namaz/namaz_prayer_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';

void main() {
  setUpAll(() {
    initializeNamazPrayers(namazPrayersJson);
    initializeWuduSteps(wuduStepsJson);
  });

  testWidgets('uses informational prayer flow tiles without navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const NamazPrayerScreen(),
        routes: {
          AppRoutes.completeNamazGuide: (_) =>
              const Scaffold(body: Text('Complete guide')),
        },
      ),
    );

    expect(find.byType(RafeeqAppBar), findsOneWidget);
    expect(find.text('Namaz'), findsOneWidget);
    expect(find.byKey(const ValueKey('namaz_prayer_fajr')), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(find.text('Fajr (4)'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('namaz_prayer_fajr')),
        matching: find.text('2 Sunnah'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('namaz_prayer_fajr')),
        matching: find.text('2 Fard'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('namaz_prayer_fajr')),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });

  testWidgets('opens the complete guide from its leading card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const NamazPrayerScreen(),
        routes: {
          AppRoutes.completeNamazGuide: (_) =>
              const Scaffold(body: Text('Complete guide')),
        },
      ),
    );

    await tester.tap(find.byKey(const ValueKey('complete_namaz_guide_tile')));
    await tester.pumpAndSettle();
    expect(find.text('Complete guide'), findsOneWidget);
  });
}
