import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/core/prefs.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/providers/surah_info_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/data/services/bookmark_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_navigation_picker_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_overlay.dart';
import 'package:rafeeq/ui/quran/quran_reader_app_bar_title.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/ui/widgets/scene_artwork.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/juz_names_provider.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

TextStyle getTranslationTextStyle(
  QuranViewSettings settings,
  Color color, {
  double? customFontSize,
}) {
  final isUrdu =
      settings.translationEditionId.split('.').first.toLowerCase() == 'ur';
  return TextStyle(
    fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
    fontSize: customFontSize ?? settings.translationFontSize,
    color: color,
    height: 1.55,
  );
}

TextStyle getArabicTextStyle(
  QuranViewSettings settings,
  Color color, {
  double? customFontSize,
}) {
  return TextStyle(
    fontFamily: 'PDMS Saleem Quran',
    fontSize: customFontSize ?? settings.arabicFontSize,
    color: color,
    height: 1.8,
  );
}

bool isRtlEdition(String editionId) {
  final languageCode = editionId.split('.').first.toLowerCase();
  return rtlLanguages.contains(languageCode);
}

typedef _QuranDetailsPlaybackStatus = ({
  bool isVisible,
  bool isComplete,
  QuranPlaybackScope scope,
  int? scopeNumber,
  int currentIndex,
  int totalAyahs,
  Ayah? currentAyah,
  String surahName,
});

sealed class QuranDetailArgs {
  QuranDetailArgs(this.ayahs, this.initialIndex);

  final List<Ayah> ayahs;
  final int initialIndex;

  String get label;
  String get screenAnalyticsName;
}

class SurahQuranDetailArgs extends QuranDetailArgs {
  SurahQuranDetailArgs(this.surah, List<Ayah> allAyahs)
    : super(
        allAyahs,
        allAyahs.indexWhere(
          (ayah) =>
              ayah.surahNumber == surah.surahNumber && ayah.numberInSurah == 1,
        ),
      );

  final Surah surah;

  @override
  String get label => surah.name;

  @override
  String get screenAnalyticsName => 'surah';
}

class JuzQuranDetailArgs extends QuranDetailArgs {
  JuzQuranDetailArgs(this.juz, List<Ayah> allAyahs)
    : super(allAyahs, allAyahs.indexWhere((ayah) => ayah.juz == juz.number));

  final Juz juz;

  @override
  String get label => juz.startWord;

  @override
  String get screenAnalyticsName => 'juz';
}

class QuranDetailsScreen extends ConsumerStatefulWidget {
  const QuranDetailsScreen({
    super.key,
    required this.args,
    this.initialAyahNumber,
    this.autoPlay = false,
  });

  final QuranDetailArgs args;
  final int? initialAyahNumber;
  final bool autoPlay;

  @override
  ConsumerState<QuranDetailsScreen> createState() => _QuranDetailsScreenState();
}

class _QuranDetailsScreenState extends ConsumerState<QuranDetailsScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  List<_ReaderItem> _readerItems = const [];
  bool _initialActionScheduled = false;
  late QuranDetailArgs _activeArgs;
  int? _pendingInitialAyahNumber;
  int? _pendingGlobalAyahNumber;
  late bool _autoPlayPending;

  @override
  void initState() {
    super.initState();
    _activeArgs = widget.args;
    _pendingInitialAyahNumber = widget.initialAyahNumber;
    _pendingGlobalAyahNumber = null;
    _autoPlayPending = widget.autoPlay;
  }

  @override
  void didUpdateWidget(covariant QuranDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args == widget.args &&
        oldWidget.initialAyahNumber == widget.initialAyahNumber) {
      return;
    }
    _activeArgs = widget.args;
    _pendingInitialAyahNumber = widget.initialAyahNumber;
    _pendingGlobalAyahNumber = null;
    _autoPlayPending = widget.autoPlay;
    _initialActionScheduled = false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final surahInfo = ref.watch(surahInfoProvider);
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    ref.listen<int?>(
      quranAudioControllerProvider.select((state) => state.currentAyah?.number),
      (previous, current) {
        if (current == null || previous == current) return;
        if (!ref.read(prefsProvider).isQuranAutoScrollEnabled) return;
        _scrollToAyah(current);
      },
    );
    ref.listen<(QuranPlaybackScope, int?)>(
      quranAudioControllerProvider.select(
        (state) => (state.playbackScope, state.activePlaybackNumber),
      ),
      (previous, current) {
        if (current.$2 == null || previous == current) return;
        unawaited(_followPlaybackSelection(current.$1, current.$2!));
      },
    );
    final playbackStatus = ref.watch(
      quranAudioControllerProvider.select(
        (state) => (
          isVisible: state.isVisible,
          isComplete: state.isPlaybackComplete,
          scope: state.playbackScope,
          scopeNumber: state.activePlaybackNumber,
          currentIndex: state.currentIndex,
          totalAyahs: state.ayahs.length,
          currentAyah: state.currentAyah,
          surahName: state.surahName,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: _screenTitle(context),
        palette: palette,
        showBackButton: true,
        titleWidget: QuranReaderAppBarTitle(
          title: _screenTitle(context),
          subtitle: _screenSubtitle(context, playbackStatus),
          palette: palette,
          onTap: _openSectionPicker,
        ),
        actions: [
          IconButton(
            key: const ValueKey('quran_ayah_picker_action'),
            tooltip: context.loc.jumpToAyah,
            onPressed: _openAyahPicker,
            icon: const Icon(Icons.format_list_numbered_rounded),
          ),
          IconButton(
            tooltip: context.loc.quranViewSettings,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.quranViewSettings),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final infos = surahInfo;
          final items = _buildItems(infos);
          _readerItems = items;
          _scheduleInitialAction(items, infos);
          return LayoutBuilder(
            builder: (context, constraints) {
              return ScrollablePositionedList.builder(
                key: ValueKey(_activeSectionKey),
                itemScrollController: _scrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: items.length,
                itemBuilder: (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _buildItem(items[index], settings, palette),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: playbackStatus.isVisible
          ? const QuranMiniPlayer(
              includeBottomSafeArea: true,
              onQuranDetailsScreen: true,
            )
          : null,
    );
  }

  String _screenTitle(BuildContext context) {
    final args = _activeArgs;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    if (args is SurahQuranDetailArgs) {
      final number = args.surah.surahNumber.toLocalizedNumber(context);
      final name = isUrdu
          ? SurahNamesProvider.getUrduName(args.surah.surahNumber)
          : args.surah.englishName;
      return '$number. $name';
    }
    final juz = (args as JuzQuranDetailArgs).juz.number;
    return isUrdu
        ? '${context.loc.juz} ${juz.toLocalizedNumber(context)} • ${JuzNamesProvider.getUrduName(juz)}'
        : 'Juz $juz';
  }

  String _screenSubtitle(
    BuildContext context,
    _QuranDetailsPlaybackStatus playback,
  ) {
    final args = _activeArgs;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final currentAyah = playback.currentAyah;
    if (playback.isVisible && !playback.isComplete && currentAyah != null) {
      final isCurrentSelection = switch (args) {
        SurahQuranDetailArgs() =>
          playback.scope == QuranPlaybackScope.surah &&
              playback.scopeNumber == args.surah.surahNumber,
        JuzQuranDetailArgs() =>
          playback.scope == QuranPlaybackScope.juz &&
              playback.scopeNumber == args.juz.number,
      };
      if (isCurrentSelection) {
        if (args is JuzQuranDetailArgs) {
          final current = (playback.currentIndex + 1).toLocalizedNumber(
            context,
          );
          final total = playback.totalAyahs.toLocalizedNumber(context);
          final surahName = isUrdu
              ? SurahNamesProvider.getUrduName(currentAyah.surahNumber)
              : playback.surahName;
          final ayah = currentAyah.numberInSurah.toLocalizedNumber(context);
          return '${context.loc.ayahProgress(current, total)} • $surahName $ayah';
        }
        final current = currentAyah.numberInSurah.toLocalizedNumber(context);
        final total = playback.totalAyahs.toLocalizedNumber(context);
        final juz = currentAyah.juz.toLocalizedNumber(context);
        return '${context.loc.ayahProgress(current, total)} • ${context.loc.juz} $juz';
      }
    }
    if (args is SurahQuranDetailArgs && args.surah.ayahs.isNotEmpty) {
      final juz = args.surah.ayahs.first.juz.toLocalizedNumber(context);
      return '${context.loc.juz} $juz';
    }
    return context.loc.quran;
  }

  List<_ReaderItem> _buildItems(List<SurahInfo> infos) {
    final args = _activeArgs;
    if (args is SurahQuranDetailArgs) {
      final info = _findInfo(infos, args.surah.surahNumber);
      final ayahs = args.ayahs
          .where((ayah) => ayah.surahNumber == args.surah.surahNumber)
          .toList(growable: false);
      return [
        _ReaderItem.header(info),
        ...ayahs.map((ayah) => _ReaderItem.ayah(ayah, info)),
      ];
    }

    final juz = (args as JuzQuranDetailArgs).juz.number;
    final ayahs = args.ayahs
        .where((ayah) => ayah.juz == juz)
        .toList(growable: false);
    final items = <_ReaderItem>[];
    int? previousSurah;
    for (final ayah in ayahs) {
      final info = _findInfo(infos, ayah.surahNumber);
      if (previousSurah != ayah.surahNumber) {
        items.add(_ReaderItem.header(info));
        previousSurah = ayah.surahNumber;
      }
      items.add(_ReaderItem.ayah(ayah, info));
    }
    return items;
  }

  SurahInfo _findInfo(List<SurahInfo> infos, int surahNumber) {
    return infos.firstWhere((info) => info.number == surahNumber);
  }

  void _scheduleInitialAction(List<_ReaderItem> items, List<SurahInfo> infos) {
    if (_initialActionScheduled) return;
    _initialActionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final targetAyah = _pendingInitialAyahNumber;
      final targetGlobalAyah = _pendingGlobalAyahNumber;
      if (targetAyah != null || targetGlobalAyah != null) {
        final index = items.indexWhere(
          (item) => targetGlobalAyah != null
              ? item.ayah?.number == targetGlobalAyah
              : item.ayah?.numberInSurah == targetAyah,
        );
        if (index >= 0 && _scrollController.isAttached) {
          _scrollController.jumpTo(index: index, alignment: 0.08);
        }
      }
      if (_autoPlayPending) {
        final firstAyah = items
            .map((item) => item.ayah)
            .whereType<Ayah>()
            .firstOrNull;
        if (firstAyah != null) {
          final info = _findInfo(infos, firstAyah.surahNumber);
          final targetItem = targetAyah == null && targetGlobalAyah == null
              ? firstAyah
              : items
                    .map((item) => item.ayah)
                    .whereType<Ayah>()
                    .firstWhere(
                      (ayah) => targetGlobalAyah != null
                          ? ayah.number == targetGlobalAyah
                          : ayah.numberInSurah == targetAyah,
                      orElse: () => firstAyah,
                    );
          await _playFrom(info, targetItem);
        }
      }
      _pendingInitialAyahNumber = null;
      _pendingGlobalAyahNumber = null;
      _autoPlayPending = false;
    });
  }

  void _scrollToAyah(int globalAyahNumber) {
    final index = _readerItems.indexWhere(
      (item) => item.ayah?.number == globalAyahNumber,
    );
    if (index < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.isAttached) return;
      _scrollController.scrollTo(
        index: index,
        alignment: 0.12,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildItem(
    _ReaderItem item,
    QuranViewSettings settings,
    SettingsPalette palette,
  ) {
    if (item.isHeader) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: _SurahHeader(
          info: item.info,
          palette: palette,
          onPlay: () => _playFrom(
            item.info,
            _readerItems
                .map((readerItem) => readerItem.ayah)
                .whereType<Ayah>()
                .firstWhere((ayah) => ayah.surahNumber == item.info.number),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _AyahCard(
        ayah: item.ayah!,
        info: item.info,
        settings: settings,
        palette: palette,
        onPlay: () => _playFrom(item.info, item.ayah!),
      ),
    );
  }

  Future<void> _playFrom(SurahInfo info, Ayah startAyah) async {
    final controller = ref.read(quranAudioControllerProvider.notifier);
    try {
      final args = _activeArgs;
      if (args is JuzQuranDetailArgs) {
        await controller.playJuz(
          juzNumber: args.juz.number,
          startAyahGlobalNumber: startAyah.number,
        );
      } else {
        final surahAyahs = args.ayahs
            .where((ayah) => ayah.surahNumber == info.number)
            .toList(growable: false);
        await controller.playSurah(
          surahNumber: info.number,
          surahName: info.englishName,
          surahArabicName: info.name,
          ayahs: surahAyahs,
          startAyahNumber: startAyah.numberInSurah,
        );
      }
    } catch (_) {
      if (!mounted) return;
      showRafeeqToast(
        context,
        'Unable to play Quran audio right now.',
        type: RafeeqToastType.error,
      );
    }
  }

  Future<void> _followPlaybackSelection(
    QuranPlaybackScope scope,
    int number,
  ) async {
    final currentNumber = switch (_activeArgs) {
      SurahQuranDetailArgs(:final surah) => surah.surahNumber,
      JuzQuranDetailArgs(:final juz) => juz.number,
    };
    final currentScope = _activeArgs is JuzQuranDetailArgs
        ? QuranPlaybackScope.juz
        : QuranPlaybackScope.surah;
    if (scope == currentScope && number == currentNumber) return;

    try {
      final data = await ref.read(quranDataProvider.future);
      if (!mounted) return;
      final nextArgs = scope == QuranPlaybackScope.juz
          ? JuzQuranDetailArgs(Juz.values[number - 1], data.ayahs)
          : SurahQuranDetailArgs(
              data.surah.firstWhere((surah) => surah.surahNumber == number),
              data.ayahs,
            );
      _setActiveArgs(nextArgs);
    } catch (_) {
      // Keep the currently rendered section if Quran data is unavailable.
    }
  }

  Future<void> _openSectionPicker() async {
    final scope = _activeArgs is JuzQuranDetailArgs
        ? QuranPlaybackScope.juz
        : QuranPlaybackScope.surah;
    final currentNumber = switch (_activeArgs) {
      SurahQuranDetailArgs(:final surah) => surah.surahNumber,
      JuzQuranDetailArgs(:final juz) => juz.number,
    };
    final selection = await Navigator.of(context).push<QuranSectionSelection>(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranSectionPicker,
        ),
        builder: (_) => QuranSectionPickerScreen(
          scope: scope,
          currentNumber: currentNumber,
        ),
      ),
    );
    if (selection == null || !mounted) return;

    try {
      final data = await ref.read(quranDataProvider.future);
      if (!mounted) return;
      final nextArgs = selection.scope == QuranPlaybackScope.juz
          ? JuzQuranDetailArgs(Juz.values[selection.number - 1], data.ayahs)
          : SurahQuranDetailArgs(
              data.surah.firstWhere(
                (surah) => surah.surahNumber == selection.number,
              ),
              data.ayahs,
            );
      _setActiveArgs(nextArgs);
    } catch (_) {
      _showLoadError();
    }
  }

  Future<void> _openAyahPicker() async {
    final ayahs = _activeSectionAyahs;
    if (ayahs.isEmpty) return;
    final selectedAyah = await Navigator.of(context).push<Ayah>(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranAyahPicker,
        ),
        builder: (_) =>
            QuranAyahPickerScreen(ayahs: ayahs, title: context.loc.jumpToAyah),
      ),
    );
    if (selectedAyah == null || !mounted) return;
    _scrollToAyah(selectedAyah.number);
    final player = ref.read(quranAudioControllerProvider);
    if (!player.isPlaying) return;
    final info = _readerItems
        .firstWhere((item) => item.ayah?.number == selectedAyah.number)
        .info;
    await _playFrom(info, selectedAyah);
  }

  List<Ayah> get _activeSectionAyahs {
    return _sectionAyahs(_activeArgs);
  }

  void _setActiveArgs(QuranDetailArgs args) {
    final firstAyah = _sectionAyahs(args).firstOrNull;
    setState(() {
      _activeArgs = args;
      _readerItems = const [];
      _pendingInitialAyahNumber = null;
      _pendingGlobalAyahNumber = firstAyah?.number;
      _autoPlayPending = false;
      _initialActionScheduled = false;
    });
  }

  String get _activeSectionKey => switch (_activeArgs) {
    SurahQuranDetailArgs(:final surah) => 'surah-${surah.surahNumber}',
    JuzQuranDetailArgs(:final juz) => 'juz-${juz.number}',
  };

  List<Ayah> _sectionAyahs(QuranDetailArgs args) {
    if (args is SurahQuranDetailArgs) {
      return args.ayahs
          .where((ayah) => ayah.surahNumber == args.surah.surahNumber)
          .toList(growable: false);
    }
    final juzNumber = (args as JuzQuranDetailArgs).juz.number;
    return args.ayahs
        .where((ayah) => ayah.juz == juzNumber)
        .toList(growable: false);
  }

  void _showLoadError() {
    showRafeeqToast(
      context,
      'Unable to load Quran sections.',
      type: RafeeqToastType.error,
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.info,
    required this.palette,
    required this.onPlay,
  });

  final SurahInfo info;
  final SettingsPalette palette;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final isMakki = info.revelationType.toLowerCase().contains('meccan');
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: SceneArtwork(
            scene: isMakki ? SceneArt.makkah : SceneArt.madinah,
            semanticLabel: isMakki
                ? 'Makkah illustration'
                : 'Madinah illustration',
          ),
        ),
        SizedBox(height: 12),
        Text(
          isUrdu
              ? SurahNamesProvider.getUrduMeaning(info.number)
              : info.englishNameTranslation,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
            fontSize: 14,
          ),
        ),
        SizedBox(height: 2),
        Text(
          isUrdu
              ? SurahNamesProvider.getUrduName(info.number)
              : info.englishName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.title,
            fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: onPlay,
          icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
          label: Text(context.loc.playAudio),
          style: FilledButton.styleFrom(
            backgroundColor: palette.card,
            foregroundColor: palette.title,
            textStyle: TextStyle(
              fontFamily: isUrdu ? 'Jameel Noori Nastaleeq' : 'GoogleSans',
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ],
    );
  }
}

class _AyahCard extends ConsumerWidget {
  const _AyahCard({
    required this.ayah,
    required this.info,
    required this.settings,
    required this.palette,
    required this.onPlay,
  });

  final Ayah ayah;
  final SurahInfo info;
  final QuranViewSettings settings;
  final SettingsPalette palette;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(quranAudioControllerProvider);
    final isCurrent = player.currentAyah?.number == ayah.number;
    final bookmarkService = ref.watch(bookmarkServiceProvider);
    ref.watch(bookmarksStateProvider);
    final isBookmarked = bookmarkService.isBookmarked(
      ayah.surahNumber,
      ayah.numberInSurah,
    );
    final translation = ref.watch(
      quranEditionTextProvider((
        type: QuranFetchType.surah,
        number: ayah.surahNumber,
        editionId: settings.translationEditionId,
      )),
    );
    final cardColor = isCurrent ? palette.selectedCard : palette.card;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final reference = isUrdu
        ? 'القرآن ${ayah.surahNumber.toLocalizedNumber(context)}:${ayah.numberInSurah.toLocalizedNumber(context)}'
        : '${ayah.surahNumber}:${ayah.numberInSurah}';

    return GestureDetector(
      onTap: isCurrent && player.isPlaying
          ? ref.read(quranAudioControllerProvider.notifier).togglePlayPause
          : onPlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    reference,
                    style: TextStyle(
                      color: isCurrent ? palette.background : palette.title,
                      fontFamily: isUrdu
                          ? 'Jameel Noori Nastaleeq'
                          : 'GoogleSans',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MediaQuery.withNoTextScaling(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        _displayArabicText(ayah),
                        textAlign: TextAlign.right,
                        style: getArabicTextStyle(
                          settings,
                          isCurrent ? palette.background : palette.title,
                        ),
                      ),
                    ),
                  ),
                  if (settings.showTranslation) ...[
                    const SizedBox(height: 8),
                    translation.when(
                      data: (values) {
                        final value = values[ayah.number];
                        if (value == null || value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final rtl = isRtlEdition(settings.translationEditionId);
                        return MediaQuery.withNoTextScaling(
                          child: Directionality(
                            textDirection: rtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Text(
                              value,
                              textAlign: rtl ? TextAlign.right : TextAlign.left,
                              style: getTranslationTextStyle(
                                settings,
                                isCurrent ? palette.card : palette.title,
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => LinearProgressIndicator(
                        minHeight: 2,
                        color: palette.card,
                        backgroundColor: palette.card.withValues(alpha: 0.25),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: palette.card.withValues(alpha: 0.25)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.loc.playFromAyah,
                    onPressed: isCurrent && player.isPlaying
                        ? ref
                              .read(quranAudioControllerProvider.notifier)
                              .togglePlayPause
                        : onPlay,
                    icon: Icon(
                      isCurrent && player.isPlaying
                          ? CupertinoIcons.pause
                          : CupertinoIcons.play,
                      size: 22,
                    ),
                    color: isCurrent ? palette.background : palette.title,
                  ),
                  IconButton(
                    tooltip: isBookmarked
                        ? context.loc.removeBookmark
                        : context.loc.bookmarkAyah,
                    onPressed: () => bookmarkService.toggleBookmark(
                      ayah.surahNumber,
                      ayah.numberInSurah,
                    ),
                    icon: Icon(
                      isBookmarked
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      size: 22,
                    ),
                    color: isCurrent ? palette.card : palette.title,
                  ),
                  IconButton(
                    tooltip: context.loc.shareAyah,
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.ayahPictureMaker,
                      arguments: AyahPictureMakerArgs.ayah(
                        surahNumber: ayah.surahNumber,
                        ayahNumber: ayah.numberInSurah,
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.share, size: 22),
                    color: isCurrent ? palette.background : palette.title,
                  ),
                  const Spacer(),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Text(
                        player.isPlaying
                            ? context.loc.playing
                            : context.loc.paused,
                        style: TextStyle(
                          color: palette.card,
                          fontFamily: isUrdu
                              ? 'Jameel Noori Nastaleeq'
                              : 'GoogleSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayArabicText(Ayah ayah) {
    if (ayah.surahNumber == 1 || ayah.numberInSurah != 1) return ayah.text;
    const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
    return ayah.text.replaceFirst(bismillah, '').trim();
  }
}

class _ReaderItem {
  const _ReaderItem.header(this.info) : ayah = null;
  const _ReaderItem.ayah(this.ayah, this.info);

  final Ayah? ayah;
  final SurahInfo info;

  bool get isHeader => ayah == null;
}
