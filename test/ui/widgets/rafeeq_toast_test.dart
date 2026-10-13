import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:toastification/toastification.dart';

void main() {
  testWidgets('shows the built-in minimal toast at the top', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showRafeeqToast(context, 'Location updated'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final toast = find.byKey(rafeeqToastKey);
    expect(toast, findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(MinimalStandardToastWidget), findsOneWidget);
    expect(tester.getCenter(toast).dy, lessThan(300));
    expect(find.text('Location updated'), findsOneWidget);

    toastification.dismissAll(delayForAnimation: false);
    await tester.pumpAndSettle();
  });

  for (final testCase in [
    (Brightness.light, SettingsPalette.light),
    (Brightness.dark, SettingsPalette.dark),
  ]) {
    testWidgets('uses app colors in ${testCase.$1.name} mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: testCase.$1),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showRafeeqToast(context, 'Location updated'),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      final toastTheme = tester.widget<ToastificationTheme>(
        find.ancestor(
          of: find.byType(MinimalStandardToastWidget),
          matching: find.byType(ToastificationTheme),
        ),
      );

      expect(
        toastTheme.themeData.toastStyle!.backgroundColor.toARGB32(),
        testCase.$2.card.toARGB32(),
      );
      expect(
        toastTheme.themeData.toastStyle!.foregroundColor.toARGB32(),
        testCase.$2.title.toARGB32(),
      );
      expect(
        toastTheme.themeData.toastStyle!.primaryColor.toARGB32(),
        testCase.$2.accent.toARGB32(),
      );

      toastification.dismissAll(delayForAnimation: false);
      await tester.pumpAndSettle();
    });
  }
}
