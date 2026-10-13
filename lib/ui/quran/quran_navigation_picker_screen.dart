import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';

class QuranSectionSelection {
  const QuranSectionSelection({required this.scope, required this.number});

  final QuranPlaybackScope scope;
  final int number;
}

class QuranSectionPickerScreen extends ConsumerWidget {
  const QuranSectionPickerScreen({
    super.key,
    required this.scope,
    required this.currentNumber,
  });

  final QuranPlaybackScope scope;
  final int currentNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(quranAudioControllerProvider);
    final selectedNumber = player.playbackScope == scope && player.isVisible
        ? player.activePlaybackNumber
        : currentNumber;

    if (scope == QuranPlaybackScope.juz) {
      return SettingsPickerScaffold(
        title: 'Choose Juz',
        itemCount: Juz.values.length,
        bottomPadding: quranPlayerAwareBottomPadding(
          context,
          playerVisible: player.isVisible,
        ),
        itemBuilder: (context, index, palette) {
          final juz = Juz.values[index];
          return SettingsPickerTile(
            key: ValueKey('quran_juz_picker_${juz.number}'),
            title: 'Juz ${juz.number}',
            selected: selectedNumber == juz.number,
            palette: palette,
            onTap: () => Navigator.of(
              context,
            ).pop(QuranSectionSelection(scope: scope, number: juz.number)),
          );
        },
      );
    }

    final quranData = ref.watch(quranDataProvider);
    return quranData.when(
      data: (data) => SettingsPickerScaffold(
        title: 'Choose Surah',
        itemCount: data.surah.length,
        bottomPadding: quranPlayerAwareBottomPadding(
          context,
          playerVisible: player.isVisible,
        ),
        itemBuilder: (context, index, palette) {
          final surah = data.surah[index];
          return SettingsPickerTile(
            key: ValueKey('quran_surah_picker_${surah.surahNumber}'),
            title: '${surah.surahNumber} - ${surah.englishName}',
            selected: selectedNumber == surah.surahNumber,
            palette: palette,
            onTap: () => Navigator.of(context).pop(
              QuranSectionSelection(scope: scope, number: surah.surahNumber),
            ),
          );
        },
      ),
      loading: () => _PickerLoadingScaffold(title: 'Choose Surah'),
      error: (_, _) => _PickerErrorScaffold(title: 'Choose Surah'),
    );
  }
}

class QuranAyahPickerScreen extends ConsumerWidget {
  const QuranAyahPickerScreen({
    super.key,
    required this.ayahs,
    required this.title,
  });

  final List<Ayah> ayahs;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGlobalAyah = ref.watch(
      quranAudioControllerProvider.select((state) => state.currentAyah?.number),
    );
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final hasMultipleSurahs =
        ayahs.map((ayah) => ayah.surahNumber).toSet().length > 1;
    final quranData = ref.watch(quranDataProvider);
    final surahNames = quranData.maybeWhen(
      data: (data) => {
        for (final surah in data.surah) surah.surahNumber: surah.englishName,
      },
      orElse: () => const <int, String>{},
    );

    return SettingsPickerScaffold(
      title: title,
      itemCount: ayahs.length,
      bottomPadding: quranPlayerAwareBottomPadding(
        context,
        playerVisible: playerVisible,
      ),
      itemBuilder: (context, index, palette) {
        final ayah = ayahs[index];
        final surahName = surahNames[ayah.surahNumber];
        return SettingsPickerTile(
          key: ValueKey('quran_ayah_picker_${ayah.number}'),
          title: hasMultipleSurahs && surahName != null
              ? '$surahName - Ayah ${ayah.numberInSurah}'
              : 'Ayah ${ayah.numberInSurah}',
          selected: currentGlobalAyah == ayah.number,
          palette: palette,
          onTap: () => Navigator.of(context).pop(ayah),
        );
      },
    );
  }
}

class _PickerLoadingScaffold extends StatelessWidget {
  const _PickerLoadingScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: title, palette: palette),
      body: Center(child: CircularProgressIndicator(color: palette.accent)),
    );
  }
}

class _PickerErrorScaffold extends StatelessWidget {
  const _PickerErrorScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: title, palette: palette),
      body: Center(
        child: Text(
          'Unable to load Quran sections',
          style: TextStyle(color: palette.subtitle, fontFamily: 'GoogleSans'),
        ),
      ),
    );
  }
}
