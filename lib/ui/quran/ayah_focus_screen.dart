import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart' hide isRtlEdition;
import 'package:rafeeq/ui/quran/quran_navigation_picker_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/quran/quran_reader_app_bar_title.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';

class AyahFocusScreen extends ConsumerWidget {
  const AyahFocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final player = ref.watch(quranAudioControllerProvider);
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final ayah = player.currentAyah;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final scopeNumber = player.activePlaybackNumber;
    final title =
        player.playbackScope == QuranPlaybackScope.juz && scopeNumber != null
        ? isUrdu
              ? '${context.loc.juz} ${scopeNumber.toLocalizedNumber(context)} • ${JuzNamesProvider.getUrduName(scopeNumber)}'
              : 'Juz $scopeNumber'
        : player.surahNumber == null || player.surahName.isEmpty
        ? context.loc.quran
        : '${player.surahNumber!.toLocalizedNumber(context)}. ${isUrdu ? SurahNamesProvider.getUrduName(player.surahNumber!) : player.surahName}';
    final subtitle = ayah == null || player.ayahs.isEmpty
        ? context.loc.noAyahPlaying
        : player.playbackScope == QuranPlaybackScope.juz
        ? '${(player.currentIndex + 1).toLocalizedNumber(context)}/${player.ayahs.length.toLocalizedNumber(context)}'
        : '${ayah.numberInSurah.toLocalizedNumber(context)}/${player.ayahs.length.toLocalizedNumber(context)}';
    final translation = ayah == null || !settings.showTranslation
        ? const AsyncValue.data(<int, String>{})
        : ref.watch(
            quranEditionTextProvider((
              type: QuranFetchType.surah,
              number: ayah.surahNumber,
              editionId: settings.translationEditionId,
            )),
          );

    return Scaffold(
      appBar: RafeeqAppBar(
        title: title,
        palette: palette,
        showBackButton: true,
        titleWidget: QuranReaderAppBarTitle(
          title: title,
          subtitle: subtitle,
          palette: palette,
          onTap: player.activePlaybackNumber == null
              ? null
              : () => _openSectionPicker(context, ref, player),
        ),
        actions: [
          IconButton(
            key: const ValueKey('quran_ayah_picker_action'),
            tooltip: context.loc.jumpToAyah,
            onPressed: player.ayahs.isEmpty
                ? null
                : () => _openAyahPicker(context, ref, player),
            icon: const Icon(Icons.format_list_numbered_rounded),
          ),
          IconButton(
            key: const ValueKey('quran_view_settings_action'),
            tooltip: isUrdu
                ? context.loc.quranViewSettings
                : 'Quran view settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.quranViewSettings),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      backgroundColor: palette.card,
      body: ayah == null
          ? Center(
              child: Text(
                context.loc.noQuranAudioPlaying,
                style: TextStyle(
                  color: palette.subtitle,
                  fontFamily: localizedFontFamily(context),
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    quranPlayerAwareBottomPadding(
                      context,
                      playerVisible: player.isVisible,
                      spacing: 12,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MediaQuery.withNoTextScaling(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                ayah.text,
                                textAlign: TextAlign.start,
                                style: getArabicTextStyle(
                                  settings,
                                  palette.title,
                                  customFontSize: settings.arabicFontSize + 8,
                                ),
                              ),
                            ),
                          ),
                          if (settings.showTranslation) ...[
                            const SizedBox(height: 12),
                            translation.when(
                              data: (values) => MediaQuery.withNoTextScaling(
                                child: Directionality(
                                  textDirection:
                                      isRtlEdition(
                                        settings.translationEditionId,
                                      )
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Text(
                                    values[ayah.number] ?? '',
                                    textAlign:
                                        isRtlEdition(
                                          settings.translationEditionId,
                                        )
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: getTranslationTextStyle(
                                      settings,
                                      palette.subtitle,
                                      customFontSize:
                                          settings.translationFontSize + 4,
                                    ),
                                  ),
                                ),
                              ),
                              loading: () => LinearProgressIndicator(
                                color: palette.accent,
                                backgroundColor: palette.divider,
                              ),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openSectionPicker(
    BuildContext context,
    WidgetRef ref,
    QuranAudioState player,
  ) async {
    final currentNumber = player.activePlaybackNumber;
    if (currentNumber == null) return;
    final selection = await Navigator.of(context).push<QuranSectionSelection>(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranSectionPicker,
        ),
        builder: (_) => QuranSectionPickerScreen(
          scope: player.playbackScope,
          currentNumber: currentNumber,
        ),
      ),
    );
    if (selection == null || !context.mounted) return;

    try {
      final controller = ref.read(quranAudioControllerProvider.notifier);
      if (selection.scope == QuranPlaybackScope.juz) {
        await controller.playJuz(juzNumber: selection.number);
        return;
      }
      final data = await ref.read(quranDataProvider.future);
      final surah = data.surah.firstWhere(
        (item) => item.surahNumber == selection.number,
      );
      await controller.playSurah(
        surahNumber: surah.surahNumber,
        surahName: surah.englishName,
        surahArabicName: surah.name,
        ayahs: surah.ayahs,
      );
    } catch (_) {
      if (!context.mounted) return;
      showRafeeqToast(
        context,
        'Unable to load Quran audio.',
        type: RafeeqToastType.error,
      );
    }
  }

  Future<void> _openAyahPicker(
    BuildContext context,
    WidgetRef ref,
    QuranAudioState player,
  ) async {
    final selectedAyah = await Navigator.of(context).push<Ayah>(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranAyahPicker,
        ),
        builder: (_) => QuranAyahPickerScreen(
          ayahs: player.ayahs,
          title: context.loc.jumpToAyah,
        ),
      ),
    );
    if (selectedAyah == null || !context.mounted) return;
    await ref
        .read(quranAudioControllerProvider.notifier)
        .jumpToAyah(selectedAyah.number);
  }
}
