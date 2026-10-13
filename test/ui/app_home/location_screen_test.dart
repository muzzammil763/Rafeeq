import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows automatic and manual location options', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LocationScreen(),
        ),
      ),
    );

    expect(find.byType(SettingsPickerScaffold), findsOneWidget);
    expect(find.byType(LocationOptionCard), findsNWidgets(2));
    expect(find.text('Allow Location'), findsOneWidget);
    expect(find.text('Manual Location'), findsOneWidget);
    expect(find.byType(ManualLocationSelector), findsNothing);

    await tester.tap(find.text('Manual Location'));
    await tester.pump();

    expect(find.byType(ManualLocationSelector), findsOneWidget);
    expect(find.text('Select Country'), findsOneWidget);
    expect(find.text('Select City'), findsOneWidget);
  });

  testWidgets('selected location card uses high-contrast palette colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationOptionCard(
            icon: Icons.location_on_outlined,
            title: 'Manual Location',
            description: 'Selected location description',
            selected: true,
            palette: SettingsPalette.light,
            onTap: () {},
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Manual Location'));
    final description = tester.widget<Text>(
      find.text('Selected location description'),
    );
    final locationIcon = tester.widget<Icon>(
      find.byIcon(Icons.location_on_outlined),
    );
    final check = tester.widget<Icon>(find.byIcon(Icons.check_rounded));

    expect(title.style?.color, SettingsPalette.light.selectedTitle);
    expect(description.style?.color, SettingsPalette.light.selectedSubtitle);
    expect(locationIcon.color, SettingsPalette.light.selectedCard);
    expect(check.color, SettingsPalette.light.selectedCard);
  });

  testWidgets('manual selection starts with the automatic location values', (
    tester,
  ) async {
    const automaticLocation = UserLocation(
      32.9405,
      73.7276,
      country: 'Pakistan',
      countryCode: 'PK',
      city: 'Jhelum',
    );
    SharedPreferences.setMockInitialValues({
      UserLocation.prefsKey: jsonEncode(automaticLocation.toMap()),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LocationScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Manual Location'));
    await tester.pump();

    expect(find.text('Pakistan'), findsOneWidget);
    expect(find.text('Jhelum'), findsOneWidget);
  });
}
