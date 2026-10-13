import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/language_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('uses palette-aware settings tiles for language options', (
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
          home: const LanguageScreen(),
        ),
      ),
    );

    expect(find.byType(SettingsPickerScaffold), findsOneWidget);
    final picker = tester.widget<SettingsPickerScaffold>(
      find.byType(SettingsPickerScaffold),
    );
    expect(picker.itemCount, languageOptions.length);
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);

    final english = tester.widget<Text>(find.text('English'));
    expect(english.style?.color, SettingsPalette.light.selectedTitle);
    expect(languageOptions.map((option) => option.id), ['en', 'ur']);
  });

  testWidgets('localizes the visible language names in Urdu', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'ur'});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LanguageScreen(),
        ),
      ),
    );

    expect(find.text('انگریزی'), findsOneWidget);
    expect(find.text('اردو'), findsOneWidget);
    expect(find.text('English'), findsNothing);
  });
}
