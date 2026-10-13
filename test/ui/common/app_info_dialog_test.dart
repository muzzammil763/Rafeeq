import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';

void main() {
  testWidgets('shows app information as a twelve-pixel inset dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppInfoDialog.show<void>(
                context,
                title: 'Confirmation',
                iconAsset: 'assets/logo.svg',
                contentWidgets: const [Text('Dialog content')],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.insetPadding, const EdgeInsets.all(12));
    expect(find.text('Dialog content'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });
}
