import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/hijri_calendar/hijri_calendar_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('uses the refreshed app bar and calendar palette', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
          home: const HijriCalendarScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RafeeqAppBar), findsOneWidget);
    expect(find.text('Hijri Calendar'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SettingsPalette.light.background);
    expect(tester.takeException(), isNull);
  });
}
