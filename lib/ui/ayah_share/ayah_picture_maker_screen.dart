import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna.dart';
import 'package:rafeeq/data/asma_ul_husna/asma_ul_husna_urdu_meanings.dart';
import 'package:rafeeq/data/model/quran_edition.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_card.dart';
import 'package:rafeeq/ui/ayah_share/ayah_picture_share_text.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_navigation_picker_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/quran/quran_view_settings.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/surah_names_provider.dart';
import 'package:share_plus/share_plus.dart';

class AyahPictureMakerScreen extends ConsumerStatefulWidget {
  const AyahPictureMakerScreen({
    super.key,
    this.initialSurahNumber = 1,
    this.initialAyahNumber = 1,
    this.initialAsmaNumber,
  });

  final int initialSurahNumber;
  final int initialAyahNumber;
  final int? initialAsmaNumber;

  @override
  ConsumerState<AyahPictureMakerScreen> createState() =>
      _AyahPictureMakerScreenState();
}

class _AyahPictureMakerScreenState
    extends ConsumerState<AyahPictureMakerScreen> {
  final _previewKey = GlobalKey();
  late int _surahNumber;
  late int _ayahNumber;
  bool _sharing = false;
  bool _showArabic = true;
  bool _showTranslation = true;
  bool _useUrdu = false;
  bool _initializedLanguage = false;
  String? _translationEditionId;

  bool get _isAsmaPicture => widget.initialAsmaNumber != null;

  @override
  void initState() {
    super.initState();
    _surahNumber = widget.initialSurahNumber;
    _ayahNumber = widget.initialAyahNumber;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedLanguage) return;
    _useUrdu = Localizations.localeOf(context).languageCode == 'ur';
    _initializedLanguage = true;
  }

  @override
  Widget build(BuildContext context) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final palette = SettingsPalette.of(context);
    final quranData = _isAsmaPicture ? null : ref.watch(quranDataProvider);
    final asma = _isAsmaPicture
        ? ref
              .watch(asmaUlHusnaProvider)
              .where((item) => item.number == widget.initialAsmaNumber)
              .firstOrNull
        : null;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: _isAsmaPicture
            ? context.loc.asmaPicture
            : context.loc.homeAyahPicture,
        palette: palette,
        showBackButton: true,
        actions: [
          IconButton(
            key: const ValueKey('share_ayah_picture_appbar'),
            onPressed: _sharing ? null : _sharePicture,
            icon: Icon(CupertinoIcons.share, color: palette.accent),
          ),
        ],
      ),
      body: asma != null
          ? _buildAsmaContent(
              context,
              asma,
              palette,
              playerVisible: playerVisible,
            )
          : quranData?.when(
                  data: (data) => _buildContent(
                    context,
                    data,
                    palette,
                    playerVisible: playerVisible,
                  ),
                  loading: () => Center(
                    child: AyahPictureLoadingIndicator(color: palette.accent),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      context.loc.unableToLoadQuran,
                      style: TextStyle(
                        color: palette.subtitle,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                  ),
                ) ??
                Center(
                  child: Text(
                    context.loc.unableToLoadAsma,
                    style: TextStyle(
                      color: palette.subtitle,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
    );
  }

  Widget _buildAsmaContent(
    BuildContext context,
    AsmaUlHusna asma,
    SettingsPalette palette, {
    required bool playerVisible,
  }) {
    final meaning = _useUrdu
        ? asmaUlHusnaUrduMeanings[asma.number] ?? asma.meaning
        : asma.meaning;
    final description = _useUrdu
        ? asmaUlHusnaUrduDescription(asma.number)
        : asma.desc;
    final translation = [
      meaning,
      if (description.trim().isNotEmpty) description,
    ].join('\n\n');
    return _PictureMakerLayout(
      playerVisible: playerVisible,
      preview: RepaintBoundary(
        key: _previewKey,
        child: AspectRatio(
          aspectRatio: 1,
          child: AyahPictureCard.asma(
            asma: asma,
            translation: translation,
            palette: palette,
            showArabic: _showArabic,
            showTranslation: _showTranslation,
            translationEditionId: _useUrdu ? 'ur' : 'en',
            urduMode: _useUrdu,
          ),
        ),
      ),
      controls: [
        SettingsCard(
          key: const ValueKey('ayah_picture_arabic_toggle'),
          icon: CupertinoIcons.textformat,
          title: context.loc.showArabic,
          subtitle: context.loc.includeArabicName,
          palette: palette,
          switchValue: _showArabic,
          onSwitchChanged: (value) {
            if (!value && !_showTranslation) return;
            setState(() => _showArabic = value);
          },
        ),
        const SizedBox(height: 8),
        SettingsCard(
          key: const ValueKey('ayah_picture_translation_toggle'),
          icon: CupertinoIcons.text_quote,
          title: context.loc.showMeaning,
          subtitle: context.loc.includeNameMeaning,
          palette: palette,
          switchValue: _showTranslation,
          onSwitchChanged: (value) {
            if (!value && !_showArabic) return;
            setState(() => _showTranslation = value);
          },
        ),
        const SizedBox(height: 8),
        SettingsCard(
          key: const ValueKey('asma_picture_urdu_toggle'),
          icon: CupertinoIcons.globe,
          title: context.loc.urduMode,
          subtitle: _useUrdu
              ? context.loc.showingMeaningInUrdu
              : context.loc.showMeaningInUrdu,
          palette: palette,
          switchValue: _useUrdu,
          onSwitchChanged: (value) => setState(() => _useUrdu = value),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuranData data,
    SettingsPalette palette, {
    required bool playerVisible,
  }) {
    final surah = data.surah.firstWhere(
      (item) => item.surahNumber == _surahNumber,
      orElse: () => data.surah.first,
    );
    final ayah = surah.ayahs.firstWhere(
      (item) => item.numberInSurah == _ayahNumber,
      orElse: () => surah.ayahs.first,
    );
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final editions =
        ref.watch(editionsProvider).value ?? const <QuranEdition>[];
    if (_translationEditionId == null && editions.isNotEmpty) {
      _translationEditionId =
          _firstEditionForMode(editions, _useUrdu)?.identifier ??
          settings.translationEditionId;
    }
    final translationEditionId =
        _translationEditionId ?? settings.translationEditionId;
    final translation = ref.watch(
      quranEditionTextProvider((
        type: QuranFetchType.surah,
        number: surah.surahNumber,
        editionId: translationEditionId,
      )),
    );
    final translationText = translation.value?[ayah.number];
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final edition = editions
        .where((edition) => edition.identifier == translationEditionId)
        .firstOrNull;
    final editionName = edition == null
        ? null
        : isUrdu
        ? edition.name
        : edition.englishName;

    return _PictureMakerLayout(
      playerVisible: playerVisible,
      preview: RepaintBoundary(
        key: _previewKey,
        child: AspectRatio(
          aspectRatio: 1,
          child: AyahPictureCard(
            ayah: ayah,
            translation: translationText,
            translationEditionId: translationEditionId,
            palette: palette,
            showArabic: _showArabic,
            showTranslation: _showTranslation,
            isLoading: _showTranslation && translation.isLoading,
            urduMode: _useUrdu,
          ),
        ),
      ),
      controls: [
        SettingsCard(
          key: const ValueKey('ayah_picture_arabic_toggle'),
          icon: CupertinoIcons.textformat,
          title: context.loc.showArabic,
          subtitle: context.loc.includeArabicAyah,
          palette: palette,
          switchValue: _showArabic,
          onSwitchChanged: (value) {
            if (!value && !_showTranslation) return;
            setState(() => _showArabic = value);
          },
        ),
        const SizedBox(height: 8),
        SettingsCard(
          key: const ValueKey('ayah_picture_translation_toggle'),
          icon: CupertinoIcons.text_quote,
          title: context.loc.showTranslation,
          subtitle: context.loc.includeTranslation,
          palette: palette,
          switchValue: _showTranslation,
          onSwitchChanged: (value) {
            if (!value && !_showArabic) return;
            setState(() => _showTranslation = value);
          },
        ),
        const SizedBox(height: 8),
        SettingsCard(
          key: const ValueKey('ayah_picture_urdu_toggle'),
          icon: CupertinoIcons.globe,
          title: context.loc.urduMode,
          subtitle: _useUrdu
              ? context.loc.usingUrduPictureLayout
              : context.loc.useUrduPictureLayout,
          palette: palette,
          switchValue: _useUrdu,
          onSwitchChanged: (value) {
            setState(() {
              _useUrdu = value;
              _translationEditionId = _firstEditionForMode(
                editions,
                value,
              )?.identifier;
            });
          },
        ),
        const SizedBox(height: 8),
        if (_showArabic) ...[
          SettingsPickerTile(
            key: const ValueKey('ayah_picture_surah_selector'),
            title: isUrdu
                ? '${surah.surahNumber.toLocalizedNumber(context)} - ${SurahNamesProvider.getUrduName(surah.surahNumber)}'
                : '${surah.surahNumber} - ${surah.englishName}',
            subtitle: context.loc.chooseSurah,
            selected: false,
            palette: palette,
            onTap: () => _chooseSurah(data),
          ),
          const SizedBox(height: 8),
          SettingsPickerTile(
            key: const ValueKey('ayah_picture_ayah_selector'),
            title: context.loc.ayahNumber(
              ayah.numberInSurah.toLocalizedNumber(context),
            ),
            subtitle: context.loc.jumpToAyah,
            selected: false,
            palette: palette,
            onTap: () => _chooseAyah(surah),
          ),
          const SizedBox(height: 8),
        ],
        if (_showTranslation)
          SettingsPickerTile(
            key: const ValueKey('ayah_picture_translation_selector'),
            title: editionName ?? settings.translationEditionId,
            subtitle: context.loc.translationEdition,
            selected: false,
            palette: palette,
            onTap: _chooseTranslationEdition,
          ),
      ],
    );
  }

  Future<void> _chooseSurah(QuranData data) async {
    final selection = await Navigator.of(context).push<QuranSectionSelection>(
      MaterialPageRoute<QuranSectionSelection>(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranSectionPicker,
        ),
        builder: (_) => QuranSectionPickerScreen(
          scope: QuranPlaybackScope.surah,
          currentNumber: _surahNumber,
        ),
      ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      _surahNumber = selection.number;
      _ayahNumber = 1;
    });
  }

  Future<void> _chooseAyah(Surah surah) async {
    final ayah = await Navigator.of(context).push<Ayah>(
      MaterialPageRoute<Ayah>(
        settings: const RouteSettings(
          name: AnalyticsScreenNames.quranAyahPicker,
        ),
        builder: (_) => QuranAyahPickerScreen(
          ayahs: surah.ayahs,
          title: context.loc.jumpToAyah,
        ),
      ),
    );
    if (!mounted || ayah == null) return;
    setState(() => _ayahNumber = ayah.numberInSurah);
  }

  QuranEdition? _firstEditionForMode(
    List<QuranEdition> editions,
    bool useUrdu,
  ) {
    final language = useUrdu ? 'ur' : 'en';
    return editions
        .where((edition) => edition.language.toLowerCase() == language)
        .firstOrNull;
  }

  Future<void> _chooseTranslationEdition() async {
    final edition = await Navigator.of(context).push<QuranEdition>(
      MaterialPageRoute<QuranEdition>(
        settings: const RouteSettings(name: AppRoutes.translationSelection),
        builder: (_) => TranslationSelectionPage(
          selectionOnly: true,
          selectedEditionId: _translationEditionId,
        ),
      ),
    );
    if (!mounted || edition == null) return;
    setState(() => _translationEditionId = edition.identifier);
  }

  Future<void> _sharePicture() async {
    final boundary =
        _previewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;
    setState(() => _sharing = true);
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/rafeeq_ayah_picture.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: buildAyahPictureShareText(),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class _PictureMakerLayout extends StatelessWidget {
  const _PictureMakerLayout({
    required this.preview,
    required this.controls,
    required this.playerVisible,
  });

  final Widget preview;
  final List<Widget> controls;
  final bool playerVisible;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final previewSize = math.min(
        math.min(constraints.maxWidth, 760.0),
        constraints.maxHeight * .65,
      );
      return Column(
        children: [
          Center(
            child: SizedBox.square(dimension: previewSize, child: preview),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  key: const ValueKey('picture_maker_controls'),
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    quranPlayerAwareBottomPadding(
                      context,
                      playerVisible: playerVisible,
                    ),
                  ),
                  children: controls,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
