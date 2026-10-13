import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/services/country_city_service.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/location_picker_screen.dart';

void main() {
  testWidgets('country picker shows selection and filters by search', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countriesProvider.overrideWith(
            (ref) async => const [
              CountryOption(name: 'Pakistan', code: 'PK', emoji: '🇵🇰'),
              CountryOption(name: 'United Kingdom', code: 'GB', emoji: '🇬🇧'),
            ],
          ),
        ],
        child: const _TestApp(
          home: CountryPickerScreen(selectedCountryCode: 'PK'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pakistanRow = tester
        .widgetList<LocationPickerRow>(find.byType(LocationPickerRow))
        .singleWhere((row) => row.title == 'Pakistan');
    expect(pakistanRow.selected, isTrue);
    expect(find.textContaining('🇵🇰'), findsNothing);
    expect(find.text('PK'), findsNothing);
    expect(
      find.text('Location data © Countries States Cities Database (ODbL)'),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField), 'kingdom');
    await tester.pump();

    expect(find.textContaining('Pakistan'), findsNothing);
    expect(find.textContaining('United Kingdom'), findsOneWidget);
  });

  testWidgets('city picker keeps the automatic city selected and searchable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          citiesProvider.overrideWith((ref, code) async {
            expect(code, 'PK');
            return const ['Islamabad', 'Karachi', 'Lahore'];
          }),
        ],
        child: const _TestApp(
          home: CityPickerScreen(
            country: CountryOption(name: 'Pakistan', code: 'PK', emoji: '🇵🇰'),
            selectedCity: 'Jhelum',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final jhelumRow = tester
        .widgetList<LocationPickerRow>(find.byType(LocationPickerRow))
        .singleWhere((row) => row.title == 'Jhelum');
    expect(jhelumRow.selected, isTrue);

    await tester.enterText(find.byType(TextField), 'lah');
    await tester.pump();

    expect(find.text('Jhelum'), findsNothing);
    expect(find.text('Lahore'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}
