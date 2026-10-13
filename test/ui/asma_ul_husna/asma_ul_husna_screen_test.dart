import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/providers/asma_ul_husna_provider.dart';
import 'package:rafeeq/ui/asma_ul_husna/asma_ul_husna_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';

const _testAsmaList = [
  AsmaUlHusna(
    name: 'الرَّحْمَنُ',
    transliteration: 'Ar Rahmaan',
    number: 1,
    found: '(1:3) (17:110)',
    meaning: 'The Beneficent',
    desc: 'He who wills goodness and mercy for all His creatures',
    videoIds: ['dn-oVlmwVqk'],
  ),
  AsmaUlHusna(
    name: 'الرَّحِيمُ',
    transliteration: 'Ar Raheem',
    number: 2,
    found: '(2:163) (3: 31) (4:100) (5:3)',
    meaning: 'The Merciful',
    desc: 'He who acts with extreme kindness',
    videoIds: ['dn-oVlmwVqk'],
  ),
];

Widget createTestableWidget({required Widget child}) {
  return ProviderScope(
    overrides: [asmaUlHusnaProvider.overrideWith((ref) => _testAsmaList)],
    child: MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: [
          RafeeqTheme(
            bgColor: Colors.grey[900]!,
            primaryColor: Colors.blue,
            secondaryColor: Colors.blueAccent,
            textColor: Colors.white,
          ),
        ],
      ),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AsmaulHusnaScreen', () {
    testWidgets('renders screen with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );

      expect(find.byType(AsmaulHusnaScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text("Asma'ul Husna"), findsOneWidget);
    });

    testWidgets('renders the shared Rafeeq app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );

      expect(find.byType(RafeeqAppBar), findsOneWidget);
    });

    testWidgets('renders ListView with names', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays both names correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );
      await tester.pumpAndSettle();

      // Arabic names
      expect(find.text("الرَّحْمَنُ"), findsOneWidget);
      expect(find.text("الرَّحِيمُ"), findsOneWidget);
      // Meanings
      expect(find.text("The Beneficent"), findsOneWidget);
      expect(find.text("The Merciful"), findsOneWidget);
      // Number and transliteration headings
      expect(find.text("1- Ar Rahmaan"), findsOneWidget);
      expect(find.text("2- Ar Raheem"), findsOneWidget);
    });

    testWidgets('displays number badges', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('asma_name_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('asma_name_2')), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('has share icon for each card', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.share), findsNWidgets(2));
    });

    testWidgets('opens the picture maker with the selected Asma number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [asmaUlHusnaProvider.overrideWith((ref) => _testAsmaList)],
          child: MaterialApp(
            home: const AsmaulHusnaScreen(),
            onGenerateRoute: (settings) {
              if (settings.name != AppRoutes.ayahPictureMaker) return null;
              final args = settings.arguments! as AyahPictureMakerArgs;
              return MaterialPageRoute<void>(
                builder: (_) => Text('Asma ${args.asmaNumber} picture'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.share).first);
      await tester.pumpAndSettle();

      expect(find.text('Asma 1 picture'), findsOneWidget);
    });

    testWidgets('screen completes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(child: const AsmaulHusnaScreen()),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
