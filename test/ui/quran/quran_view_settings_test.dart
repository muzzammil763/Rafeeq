import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/model/quran_edition.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/location_picker_screen.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';

class _TestSettingsNotifier extends QuranViewSettingsNotifier {
  @override
  QuranViewSettings build() => QuranViewSettings.defaultSettings;
}

final _englishEdition = QuranEdition(
  identifier: 'en.asad',
  name: 'محمّد اسد',
  englishName: 'Muhammad Asad',
  format: 'text',
  type: 'translation',
  language: 'en',
);

final _urduEdition = QuranEdition(
  identifier: 'ur.jalandhry',
  name: 'فتح محمد جالندھری',
  englishName: 'Fateh Muhammad Jalandhry',
  format: 'text',
  type: 'translation',
  language: 'ur',
);

final _frenchEdition = QuranEdition(
  identifier: 'fr.hamidullah',
  name: 'Muhammad Hamidullah',
  englishName: 'Muhammad Hamidullah',
  format: 'text',
  type: 'translation',
  language: 'fr',
);

void main() {
  Future<void> pumpPicker(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          editionsProvider.overrideWith(
            (ref) async => [_frenchEdition, _urduEdition, _englishEdition],
          ),
          quranViewSettingsNotifierProvider.overrideWith(
            _TestSettingsNotifier.new,
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TranslationSelectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('translation tiles show one locale-appropriate title', (
    tester,
  ) async {
    await pumpPicker(tester, const Locale('en'));

    expect(find.text(_englishEdition.englishName), findsOneWidget);
    expect(find.text(_englishEdition.name), findsNothing);
    expect(find.text('French'), findsOneWidget);
    expect(find.text(_frenchEdition.englishName), findsOneWidget);
    expect(
      tester
          .widget<LocationPickerRow>(
            find.widgetWithText(LocationPickerRow, _englishEdition.englishName),
          )
          .fontFamily,
      'GoogleSans',
    );
    expect(
      tester
          .widget<LocationPickerRow>(
            find.widgetWithText(LocationPickerRow, _urduEdition.englishName),
          )
          .fontFamily,
      'Jameel Noori Nastaleeq',
    );
    expect(
      tester
          .widget<LocationPickerRow>(
            find.widgetWithText(LocationPickerRow, _frenchEdition.englishName),
          )
          .fontFamily,
      'GoogleSans',
    );
    expect(
      tester
          .widget<LocationPickerRow>(find.byType(LocationPickerRow).first)
          .subtitle,
      isNull,
    );

    await pumpPicker(tester, const Locale('ur'));

    expect(find.text(_englishEdition.name), findsOneWidget);
    expect(find.text(_englishEdition.englishName), findsNothing);
    expect(
      tester
          .widget<LocationPickerRow>(
            find.widgetWithText(LocationPickerRow, _englishEdition.name),
          )
          .fontFamily,
      'GoogleSans',
    );
    expect(
      tester
          .widget<LocationPickerRow>(
            find.widgetWithText(LocationPickerRow, _urduEdition.name),
          )
          .fontFamily,
      'Jameel Noori Nastaleeq',
    );
  });
}
