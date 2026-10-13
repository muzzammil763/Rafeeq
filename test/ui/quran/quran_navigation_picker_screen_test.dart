import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_navigation_picker_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';

class _VisiblePlayerController extends QuranAudioController {
  @override
  QuranAudioState build() => const QuranAudioState(isVisible: true);
}

const _ayah = Ayah(
  number: 1,
  numberInSurah: 1,
  text: 'آية',
  juz: 1,
  surahNumber: 1,
);

final _quranData = QuranData(
  surah: [
    Surah(
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatihah',
      englishNameTranslation: 'The Opening',
      revelationType: 'Meccan',
      ayahs: [_ayah],
    ),
  ],
);

void main() {
  Widget testApp(Widget home) {
    return ProviderScope(
      overrides: [
        quranAudioControllerProvider.overrideWith(_VisiblePlayerController.new),
        quranDataProvider.overrideWith((ref) async => _quranData),
      ],
      child: MaterialApp(home: home),
    );
  }

  void expectPlayerAwarePadding(WidgetTester tester) {
    final picker = tester.widget<SettingsPickerScaffold>(
      find.byType(SettingsPickerScaffold),
    );
    expect(picker.bottomPadding, screenBottomPaddingWithPlayer);
  }

  testWidgets('Juz picker uses simple titles and clears the player overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const QuranSectionPickerScreen(
          scope: QuranPlaybackScope.juz,
          currentNumber: 1,
        ),
      ),
    );

    expect(find.text('Juz 1'), findsOneWidget);
    expect(find.text(Juz.values.first.startWord), findsNothing);
    expectPlayerAwarePadding(tester);
  });

  testWidgets('Surah and ayah pickers clear the player overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const QuranSectionPickerScreen(
          scope: QuranPlaybackScope.surah,
          currentNumber: 1,
        ),
      ),
    );
    await tester.pump();
    expectPlayerAwarePadding(tester);

    await tester.pumpWidget(
      testApp(
        const QuranAyahPickerScreen(ayahs: [_ayah], title: 'Jump To Ayah'),
      ),
    );
    await tester.pump();
    expect(find.text('Ayah 1'), findsOneWidget);
    expectPlayerAwarePadding(tester);
  });
}
