import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/di_container.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_details_screen.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/center_loading_view.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';

import 'quran_search_provider.dart';

class ReadQuranHomeScreen extends HookConsumerWidget {
  const ReadQuranHomeScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  EdgeInsets _contentPadding({required bool playerVisible}) {
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      navigationScreenPlayerAwareBottomPadding(playerVisible: playerVisible),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final quranDataValue = ref.watch(quranDataProvider);
    final searchState = ref.watch(quranSearchProvider);
    final player = ref.watch(quranAudioControllerProvider);
    final palette = SettingsPalette.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: RafeeqAppBar(
          title: searchState.isSearchActive ? '' : context.loc.quran,
          palette: palette,
          showBackButton: onBack != null,
          onBack: onBack,
          titleWidget: searchState.isSearchActive
              ? _buildAppBarSearchField(context, ref, palette)
              : null,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 2),
              child: IconButton(
                tooltip: searchState.isSearchActive
                    ? MaterialLocalizations.of(context).closeButtonTooltip
                    : context.loc.search,
                onPressed: () =>
                    ref.read(quranSearchProvider.notifier).toggleSearch(),
                icon: Icon(
                  searchState.isSearchActive
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  size: 23,
                ),
              ),
            ),
          ],
          bottom: searchState.isSearchActive
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: SizedBox(
                    height: 48,
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TabBar(
                          splashFactory: NoSplash.splashFactory,
                          dividerHeight: 0,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          unselectedLabelColor: palette.subtitle,
                          indicatorColor: palette.accent,
                          labelColor: palette.title,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: TextStyle(
                            fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          physics: const BouncingScrollPhysics(),
                          tabs: [
                            Tab(text: context.loc.surah),
                            Tab(text: context.loc.juz),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        body: quranDataValue.when(
          data: (quranData) {
            if (searchState.isSearchActive) {
              return _buildSurahList(
                context,
                quranData,
                palette,
                ref: ref,
                player: player,
                query: searchState.searchQuery,
              );
            }
            return TabBarView(
              children: [
                _buildSurahList(
                  context,
                  quranData,
                  palette,
                  ref: ref,
                  player: player,
                ),
                _buildJuzList(
                  context,
                  quranData,
                  palette,
                  ref: ref,
                  player: player,
                ),
              ],
            );
          },
          error: (err, trace) => Center(
            child: Text(
              context.loc.errorLoadingQuranData,
              style: TextStyle(color: palette.title),
            ),
          ),
          loading: () => const CenterLoadingView(),
        ),
      ),
    );
  }

  Widget _buildAppBarSearchField(
    BuildContext context,
    WidgetRef ref,
    SettingsPalette palette,
  ) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    return TextField(
      key: const Key('quran-app-bar-search-field'),
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: (value) =>
          ref.read(quranSearchProvider.notifier).updateQuery(value),
      style: TextStyle(
        color: palette.title,
        fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      cursorColor: palette.accent,
      decoration: InputDecoration(
        hintText: context.loc.searchQuranHint,
        hintStyle: TextStyle(
          color: palette.subtitle,
          fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _buildSurahList(
    BuildContext context,
    QuranData quranData,
    SettingsPalette palette, {
    required WidgetRef ref,
    required QuranAudioState player,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final surahList = normalizedQuery.isEmpty
        ? quranData.surah
        : quranData.surah.where((surah) {
            return surah.surahNumber.toString() == normalizedQuery ||
                surah.name.contains(normalizedQuery) ||
                surah.englishName.toLowerCase().contains(normalizedQuery) ||
                surah.englishNameTranslation.toLowerCase().contains(
                  normalizedQuery,
                ) ||
                SurahNamesProvider.getUrduName(
                  surah.surahNumber,
                ).contains(normalizedQuery);
          }).toList();
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: _contentPadding(playerVisible: player.isVisible),
      itemCount: surahList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final surah = surahList[index];
        final isActive =
            player.isVisible &&
            player.playbackScope == QuranPlaybackScope.surah &&
            player.activePlaybackNumber == surah.surahNumber;
        final controller = ref.read(quranAudioControllerProvider.notifier);
        void openSurah() {
          di.appRouter.pushNamed(
            AppRoutes.quranDetails,
            arguments: QuranDetailsArgs(
              SurahQuranDetailArgs(surah, quranData.ayahs),
            ),
          );
        }

        void playSurah() {
          controller.playSurah(
            surahNumber: surah.surahNumber,
            surahName: surah.englishName,
            surahArabicName: surah.name,
            ayahs: surah.ayahs,
          );
        }

        return _QuranIndexCard(
          index: _formatQuranIndex(context, surah.surahNumber),
          title: isUrdu
              ? SurahNamesProvider.getUrduName(surah.surahNumber)
              : surah.englishName,
          subtitle: isUrdu
              ? SurahNamesProvider.getUrduMeaning(surah.surahNumber)
              : surah.englishNameTranslation,
          palette: palette,
          onTap: openSurah,
          onTrailingTap: () {
            if (isActive) {
              if (player.isPlaybackComplete && player.canPlayNextSelection) {
                controller.playNextSelection();
              } else {
                controller.togglePlayPause();
              }
              return;
            }
            openSurah();
            playSurah();
          },
          isActive: isActive,
          isAudioPlaying: player.isPlaying,
          isBusy: player.isLoading || player.isBuffering,
          isPlaybackComplete: player.isPlaybackComplete,
          canPlayNextSelection: player.canPlayNextSelection,
        );
      },
    );
  }

  Widget _buildJuzList(
    BuildContext context,
    QuranData quranData,
    SettingsPalette palette, {
    required WidgetRef ref,
    required QuranAudioState player,
  }) {
    final juzList = Juz.values;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: _contentPadding(playerVisible: player.isVisible),
      itemCount: juzList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final juz = juzList[index];
        final isActive =
            player.isVisible &&
            player.playbackScope == QuranPlaybackScope.juz &&
            player.activePlaybackNumber == juz.number;
        final controller = ref.read(quranAudioControllerProvider.notifier);
        return _QuranIndexCard(
          index: _formatQuranIndex(context, juz.number),
          title: isUrdu
              ? JuzNamesProvider.getUrduName(juz.number)
              : JuzNamesProvider.getEnglishName(juz.number),
          subtitle: isUrdu
              ? JuzNamesProvider.getUrduOrdinalName(juz.number)
              : 'Juz ${juz.number}',
          palette: palette,
          onTap: () => _openJuz(quranData, juz),
          onTrailingTap: () {
            if (isActive) {
              if (player.isPlaybackComplete && player.canPlayNextSelection) {
                controller.playNextSelection();
              } else {
                controller.togglePlayPause();
              }
              return;
            }
            _openJuz(quranData, juz);
            controller.playJuz(juzNumber: juz.number);
          },
          isActive: isActive,
          isAudioPlaying: player.isPlaying,
          isBusy: player.isLoading || player.isBuffering,
          isPlaybackComplete: player.isPlaybackComplete,
          canPlayNextSelection: player.canPlayNextSelection,
        );
      },
    );
  }

  void _openJuz(QuranData quranData, Juz juz) {
    di.appRouter.pushNamed(
      AppRoutes.quranDetails,
      arguments: QuranDetailsArgs(JuzQuranDetailArgs(juz, quranData.ayahs)),
    );
  }
}

String _formatQuranIndex(BuildContext context, int value) {
  final prefix = value < 10 ? 0.toLocalizedNumber(context) : '';
  return '$prefix${value.toLocalizedNumber(context)}';
}

class _QuranIndexCard extends StatelessWidget {
  const _QuranIndexCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
    required this.onTrailingTap,
    required this.isActive,
    required this.isAudioPlaying,
    required this.isBusy,
    required this.isPlaybackComplete,
    required this.canPlayNextSelection,
  });

  final String index;
  final String title;
  final String subtitle;
  final SettingsPalette palette;
  final VoidCallback onTap;
  final VoidCallback onTrailingTap;
  final bool isActive;
  final bool isAudioPlaying;
  final bool isBusy;
  final bool isPlaybackComplete;
  final bool canPlayNextSelection;

  @override
  Widget build(BuildContext context) {
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    return Semantics(
      button: true,
      label: '$index. $title. $subtitle',
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    index,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: palette.accent,
                      fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.title,
                          fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.subtitle,
                          fontFamily: isUrdu ? 'Alvi' : 'GoogleSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _QuranIndexPlaybackAction(
                  isActive: isActive,
                  isAudioPlaying: isAudioPlaying,
                  isBusy: isBusy,
                  showNext:
                      isActive && isPlaybackComplete && canPlayNextSelection,
                  onPressed: onTrailingTap,
                  palette: palette,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuranIndexPlaybackAction extends StatelessWidget {
  const _QuranIndexPlaybackAction({
    required this.isActive,
    required this.isAudioPlaying,
    required this.isBusy,
    required this.showNext,
    required this.onPressed,
    required this.palette,
  });

  final bool isActive;
  final bool isAudioPlaying;
  final bool isBusy;
  final bool showNext;
  final VoidCallback onPressed;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    if (showNext) {
      return SizedBox(
        width: 48,
        height: 48,
        child: TextButton(
          key: const ValueKey('quran_index_next_selection_button'),
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: palette.title,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.skip_next_rounded, size: 19),
              Text(
                'Next',
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        key: ValueKey(
          isActive ? 'quran_active_playback_button' : 'quran_start_play_button',
        ),
        tooltip: isActive && isAudioPlaying
            ? 'Pause'
            : isActive
            ? 'Resume'
            : 'Open and play',
        onPressed: onPressed,
        icon: isBusy && isActive
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: palette.accent,
                ),
              )
            : isActive && isAudioPlaying
            ? _AnimatedPlayingWave(color: palette.accent)
            : Icon(
                Icons.play_arrow_rounded,
                size: 26,
                color: palette.accent.withValues(alpha: 0.75),
              ),
      ),
    );
  }
}

class _AnimatedPlayingWave extends StatefulWidget {
  const _AnimatedPlayingWave({required this.color});

  final Color color;

  @override
  State<_AnimatedPlayingWave> createState() => _AnimatedPlayingWaveState();
}

class _AnimatedPlayingWaveState extends State<_AnimatedPlayingWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('quran_active_playback_wave'),
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _PlayingWavePainter(
            phase: _controller.value,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _PlayingWavePainter extends CustomPainter {
  const _PlayingWavePainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 4;
    const barWidth = 3.0;
    final gap = (size.width - (barCount * barWidth)) / (barCount - 1);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var index = 0; index < barCount; index++) {
      final wave = (math.sin((phase * math.pi * 2) + (index * 1.25)) + 1) / 2;
      final height = 7 + (wave * (size.height - 9));
      final left = index * (barWidth + gap);
      final rect = Rect.fromLTWH(
        left,
        (size.height - height) / 2,
        barWidth,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(barWidth / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PlayingWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}
