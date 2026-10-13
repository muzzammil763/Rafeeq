import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_router.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/core/navigation/current_route_provider.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';

class QuranPlayerHost extends ConsumerWidget {
  const QuranPlayerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    return QuranPlayerVisibility(
      isVisible: playerVisible,
      child: Stack(
        fit: StackFit.expand,
        children: [child, const _QuranPlayerOverlayEntry()],
      ),
    );
  }
}

class _QuranPlayerOverlayEntry extends ConsumerWidget {
  const _QuranPlayerOverlayEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final routeName = ref.watch(currentRouteNameProvider);
    final isAppHomeRoute =
        routeName == Navigator.defaultRouteName ||
        routeName == AnalyticsScreenNames.home;
    final isQuranDetailsRoute = routeName == AppRoutes.quranDetails;
    final showPlayer = playerVisible && !isAppHomeRoute && !isQuranDetailsRoute;

    if (!showPlayer) return const SizedBox.shrink();
    return const PositionedDirectional(
      start: 0,
      end: 0,
      bottom: 0,
      child: QuranMiniPlayer(includeBottomSafeArea: true),
    );
  }
}

class QuranMiniPlayer extends ConsumerWidget {
  const QuranMiniPlayer({
    super.key,
    this.includeBottomSafeArea = false,
    this.onQuranDetailsScreen = false,
  });

  final bool includeBottomSafeArea;
  final bool onQuranDetailsScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(quranAudioControllerProvider);
    if (!player.isVisible) return const SizedBox.shrink();
    final routeName = ref.watch(currentRouteNameProvider);
    final isQuranDetails =
        onQuranDetailsScreen || routeName == AppRoutes.quranDetails;
    final isAyahFocus = routeName == AppRoutes.ayahFocus;
    final controller = ref.read(quranAudioControllerProvider.notifier);
    final palette = SettingsPalette.of(context);
    final effectiveDuration = player.effectiveDuration;
    final progress = player.isPlaybackComplete
        ? player.playbackEndProgress
        : effectiveDuration.inMilliseconds <= 0
        ? 0.0
        : (player.position.inMilliseconds / effectiveDuration.inMilliseconds)
              .clamp(0.0, 1.0);

    return Material(
      key: const ValueKey('quran_mini_player_content'),
      color: palette.card,
      child: SafeArea(
        top: false,
        bottom: includeBottomSafeArea,
        child: Semantics(
          label: 'Quran audio player',
          button: !player.isPlaybackComplete,
          child: InkWell(
            onTap: player.isPlaybackComplete
                ? null
                : () => isAyahFocus
                      ? navigatorKey.currentState?.pushNamed(
                          AppRoutes.chooseReciter,
                        )
                      : _openPlayerDestination(
                          ref,
                          player,
                          expandAyah: isQuranDetails,
                        ),
            child: SizedBox(
              height: quranMiniPlayerContentHeight,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Close player',
                          button: true,
                          child: IconButton(
                            onPressed: controller.stop,
                            icon: Icon(
                              CupertinoIcons.clear,
                              color: palette.title,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: _PlayerDescription(
                            player: player,
                            isQuranDetails: isQuranDetails,
                            isAyahFocus: isAyahFocus,
                            palette: palette,
                          ),
                        ),
                        if (player.isPlaybackComplete) ...[
                          if (player.canPlayPreviousSelection)
                            _PlaybackSectionActionButton(
                              buttonKey: const ValueKey(
                                'quran_previous_selection_button',
                              ),
                              tooltip:
                                  'Play previous ${player.playbackUnitName}',
                              label: 'Previous',
                              icon: Icons.skip_previous_rounded,
                              onPressed: controller.playPreviousSelection,
                              palette: palette,
                            ),
                          if (player.canPlayNextSelection)
                            _PlaybackSectionActionButton(
                              buttonKey: const ValueKey(
                                'quran_next_selection_button',
                              ),
                              tooltip: 'Play next ${player.playbackUnitName}',
                              label: 'Next',
                              icon: Icons.skip_next_rounded,
                              onPressed: controller.playNextSelection,
                              palette: palette,
                            ),
                        ] else ...[
                          KeyedSubtree(
                            key: const ValueKey('quran_previous_ayah_control'),
                            child: _PlayerIconButton(
                              tooltip: 'Previous ayah',
                              icon: Icons.skip_previous_rounded,
                              enabled:
                                  player.canGoPrevious ||
                                  player.canPlayPreviousSelection,
                              onPressed: controller.previousOrPreviousSelection,
                              palette: palette,
                            ),
                          ),
                          KeyedSubtree(
                            key: const ValueKey('quran_play_pause_control'),
                            child: _PlayPauseButton(
                              palette: palette,
                              player: player,
                              onPressed: controller.togglePlayPause,
                            ),
                          ),
                          KeyedSubtree(
                            key: const ValueKey('quran_next_ayah_control'),
                            child: _PlayerIconButton(
                              tooltip: 'Next ayah',
                              icon: Icons.skip_next_rounded,
                              enabled:
                                  player.canGoNext ||
                                  player.canPlayNextSelection,
                              onPressed: controller.nextOrNextSelection,
                              palette: palette,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progress),
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: player.isLoading && !player.isPlaybackComplete
                              ? null
                              : value,
                          minHeight: 2,
                          backgroundColor: palette.card,
                          valueColor: AlwaysStoppedAnimation(palette.accent),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPlayerDestination(
    WidgetRef ref,
    QuranAudioState player, {
    required bool expandAyah,
  }) async {
    if (expandAyah) {
      await navigatorKey.currentState?.pushNamed(AppRoutes.ayahFocus);
      return;
    }

    final ayah = player.currentAyah;
    final surahNumber = ayah?.surahNumber ?? player.surahNumber;
    if (ayah == null || surahNumber == null) return;

    Surah surah;
    List<Ayah> allAyahs;
    try {
      final quranData = await ref.read(quranDataProvider.future);
      surah = quranData.surah.firstWhere(
        (candidate) => candidate.surahNumber == surahNumber,
      );
      allAyahs = quranData.ayahs;
    } catch (_) {
      surah = Surah(
        surahNumber: surahNumber,
        name: player.surahArabicName,
        englishName: player.surahName,
        englishNameTranslation: '',
        revelationType: '',
        ayahs: player.ayahs,
      );
      allAyahs = player.ayahs;
    }

    await navigatorKey.currentState?.pushNamed(
      AppRoutes.quranDetails,
      arguments: QuranDetailsArgs(
        SurahQuranDetailArgs(surah, allAyahs),
        initialAyahNumber: ayah.numberInSurah,
      ),
    );
  }
}

class _PlayerDescription extends StatelessWidget {
  const _PlayerDescription({
    required this.player,
    required this.isQuranDetails,
    required this.isAyahFocus,
    required this.palette,
  });

  final QuranAudioState player;
  final bool isQuranDetails;
  final bool isAyahFocus;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final remainingSeconds = (player.playbackEndRemaining.inMilliseconds / 1000)
        .ceil();
    final idleSubtitle = isAyahFocus
        ? (player.reciterName.isEmpty
              ? context.loc.quranRecitation
              : isUrdu && player.reciterNativeName.isNotEmpty
              ? player.reciterNativeName
              : player.reciterName)
        : isQuranDetails
        ? context.loc.tapToExpand
        : context.loc.tapToView;
    final surahNumber = player.surahNumber;
    final displayName =
        player.playbackScope == QuranPlaybackScope.juz &&
            player.activePlaybackNumber != null
        ? isUrdu
              ? '${context.loc.juz} ${player.activePlaybackNumber!.toLocalizedNumber(context)} • ${JuzNamesProvider.getUrduName(player.activePlaybackNumber!)}'
              : 'Juz ${player.activePlaybackNumber}'
        : isUrdu && surahNumber != null
        ? SurahNamesProvider.getUrduName(surahNumber)
        : player.surahName;
    final ayahNumber = (player.currentAyah?.numberInSurah ?? 1)
        .toLocalizedNumber(context);
    final remaining = remainingSeconds.toLocalizedNumber(context);
    final playbackUnitName = player.playbackScope == QuranPlaybackScope.juz
        ? context.loc.juz
        : context.loc.surah;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player.isPlaybackComplete
              ? context.loc.playbackComplete(playbackUnitName)
              : displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          player.isPlaybackComplete
              ? '${player.playbackLabel} • ${remaining}s'
              : '$idleSubtitle • $ayahNumber',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PlaybackSectionActionButton extends StatelessWidget {
  const _PlaybackSectionActionButton({
    required this.buttonKey,
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.palette,
  });

  final Key buttonKey;
  final String tooltip;
  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 62,
        height: 48,
        child: TextButton(
          key: buttonKey,
          onPressed: () async {
            try {
              await onPressed();
            } catch (_) {
              if (!context.mounted) return;
              showRafeeqToast(
                context,
                'Unable to play Quran audio right now.',
                type: RafeeqToastType.error,
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: palette.title,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.palette,
    required this.player,
    required this.onPressed,
  });

  final SettingsPalette palette;
  final QuranAudioState player;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.title.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Semantics(
        label: player.isPlaying ? 'Pause' : 'Play',
        button: true,
        child: IconButton(
          onPressed: onPressed,
          icon: player.isLoading || player.isBuffering
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    strokeCap: StrokeCap.round,
                    color: palette.accent,
                  ),
                )
              : Icon(
                  player.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: palette.title,
                  size: 22,
                ),
        ),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.palette,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onPressed;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      enabled: enabled,
      child: IconButton(
        onPressed: enabled
            ? () async {
                try {
                  await onPressed();
                } catch (_) {
                  if (!context.mounted) return;
                  showRafeeqToast(
                    context,
                    'Unable to play Quran audio right now.',
                    type: RafeeqToastType.error,
                  );
                }
              }
            : null,
        icon: Icon(icon, size: 24),
        color: palette.subtitle,
        disabledColor: palette.subtitle.withValues(alpha: 0.3),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
