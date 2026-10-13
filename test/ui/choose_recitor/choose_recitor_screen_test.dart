import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/choose_recitor/choose_recitor_screen.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class _VisiblePlayerController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState(isVisible: true);
}

void main() {
  Future<void> pumpReciterPicker(
    WidgetTester tester, {
    required Locale locale,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final rxPreferences = RxSharedPreferences(
      preferences,
      const RxSharedPreferencesDefaultLogger(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rxSharedPreferencesProvider.overrideWithValue(rxPreferences),
          quranAudioControllerProvider.overrideWith(
            _VisiblePlayerController.new,
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChooseReciterScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows only English reciter names in the English locale', (
    tester,
  ) async {
    await pumpReciterPicker(tester, locale: const Locale('en'));

    final firstReciter = kAllRecitersList.first;
    expect(find.text(firstReciter.englishName), findsOneWidget);
    expect(find.text(firstReciter.name), findsNothing);

    final picker = tester.widget<SettingsPickerScaffold>(
      find.byType(SettingsPickerScaffold),
    );
    expect(picker.bottomPadding, screenBottomPaddingWithPlayer);
  });

  testWidgets('shows only native reciter names in the Urdu locale', (
    tester,
  ) async {
    await pumpReciterPicker(tester, locale: const Locale('ur'));

    final firstReciter = kAllRecitersList.first;
    expect(find.text(firstReciter.name), findsOneWidget);
    expect(find.text(firstReciter.englishName), findsNothing);
  });
}
