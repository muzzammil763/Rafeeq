import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/ui/widgets/themed_card.dart';

void main() {
  testWidgets('ThemedCard renders child and applies theme decoration', (
    WidgetTester tester,
  ) async {
    const mockTheme = RafeeqTheme(
      bgColor: Colors.white,
      primaryColor: Colors.blue,
      secondaryColor: Colors.green,
      textColor: Colors.black,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [mockTheme]),
        home: const Scaffold(body: ThemedCard(child: Text('Card Content'))),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);

    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    final gradient = decoration.gradient as LinearGradient;
    expect(gradient.colors[0], Colors.blue);
    expect(gradient.colors[1], Colors.green);
    expect(decoration.boxShadow, isNotNull);
  });

  testWidgets('ThemedCard does not apply shadow when showShadow is false', (
    WidgetTester tester,
  ) async {
    const mockTheme = RafeeqTheme(
      bgColor: Colors.white,
      primaryColor: Colors.blue,
      secondaryColor: Colors.green,
      textColor: Colors.black,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [mockTheme]),
        home: const Scaffold(
          body: ThemedCard(showShadow: false, child: Text('No Shadow Content')),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.boxShadow, isNull);
  });
}
