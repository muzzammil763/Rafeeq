import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/l10n/app_localizations.dart';

void main() {
  testWidgets('CancelButton renders with localizations and responds to taps', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CancelButton(
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify it renders the cancel text
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap and check action
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    expect(tapped, true);
  });
}
