import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localizations.dart';

void main() {
  testWidgets('shows the current release notes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.version,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version'), findsOneWidget);
    expect(find.text('1.2.21+50'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Enhancements'), findsOneWidget);
  });
}
