import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/app_home/home/theme_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('uses the shared settings picker layout for all theme modes', (
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
          home: const ThemeScreen(),
        ),
      ),
    );

    expect(find.byType(SettingsPickerScaffold), findsOneWidget);
    expect(find.byType(ThemePickerTile), findsNWidgets(3));
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);

    final selectedTile = find.byWidgetPredicate(
      (widget) => widget is SettingsPickerTile && widget.selected,
    );
    final unselectedTile = find
        .byWidgetPredicate(
          (widget) => widget is SettingsPickerTile && !widget.selected,
        )
        .first;
    final selectedTitle = tester.widget<Text>(
      find.descendant(of: selectedTile, matching: find.byType(Text)).first,
    );
    final unselectedTitle = tester.widget<Text>(
      find.descendant(of: unselectedTile, matching: find.byType(Text)).first,
    );
    final check = tester.widget<Icon>(find.byIcon(CupertinoIcons.check_mark));
    expect(selectedTitle.style?.color, SettingsPalette.light.selectedTitle);
    expect(unselectedTitle.style?.color, SettingsPalette.light.title);
    expect(check.color, SettingsPalette.light.selectedCard);
  });

  testWidgets('theme picker tile reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final palette = SettingsPalette.of(context);
            return Scaffold(
              body: ThemePickerTile(
                mode: ThemeMode.system,
                title: 'System',
                selected: false,
                palette: palette,
                onTap: () => tapped = true,
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(SettingsPickerTile));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
