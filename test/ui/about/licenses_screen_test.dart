import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    LicenseRegistry.addLicense(
      () => Stream.fromIterable([
        const LicenseEntryWithLineBreaks(['zeta_pkg'], 'Zeta license text'),
        const LicenseEntryWithLineBreaks(['alpha_pkg'], 'Alpha license one'),
        const LicenseEntryWithLineBreaks(['alpha_pkg'], 'Alpha license two'),
      ]),
    );
  });

  Future<void> pumpLicenses(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.licenses,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists packages alphabetically with their license count', (
    tester,
  ) async {
    await pumpLicenses(tester);

    expect(find.text('Licenses'), findsOneWidget);
    final alpha = find.byKey(const ValueKey('license-alpha_pkg'));
    final zeta = find.byKey(const ValueKey('license-zeta_pkg'));
    expect(alpha, findsOneWidget);
    expect(zeta, findsOneWidget);
    expect(tester.getTopLeft(alpha).dy, lessThan(tester.getTopLeft(zeta).dy));
    expect(
      find.descendant(of: alpha, matching: find.text('2 licenses')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: zeta, matching: find.text('1 license')),
      findsOneWidget,
    );
  });

  testWidgets('opens the full license text for a package', (tester) async {
    await pumpLicenses(tester);

    await tester.tap(find.byKey(const ValueKey('license-alpha_pkg')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('license-detail')), findsOneWidget);
    expect(find.text('alpha_pkg'), findsOneWidget);
    expect(find.text('Alpha license one'), findsOneWidget);
    expect(find.text('Alpha license two'), findsOneWidget);
  });
}
