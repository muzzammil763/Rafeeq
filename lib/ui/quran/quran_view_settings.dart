import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/data/providers/quran_data_provider.dart';
import 'package:rafeeq/data/model/quran_edition.dart';
import 'package:rafeeq/data/repo/quran_api_repo.dart';
import 'package:rafeeq/data/storage/storage_box.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/app_home/home/location_picker_screen.dart';
import 'package:rafeeq/ui/choose_recitor/reciter_state_notifier.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/cancel_button.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';

final editionsProvider = FutureProvider(
  (ref) => ref.read(quranApiRepoProvider).getEditions(),
);

final quranViewSettingsStorageBoxProvider =
    Provider<StorageBox<QuranViewSettings>>((ref) {
      final factory = ref.watch(storageBoxProvider);
      return factory.create<QuranViewSettings>(
        "quran_view_settings",
        encoder: (QuranViewSettings value) => jsonEncode(value.toMap()),
        decoder: (String value) => QuranViewSettings.fromMap(
          jsonDecode(value) as Map<String, dynamic>,
        ),
        defaultValue: QuranViewSettings.defaultSettings,
      );
    });

final quranViewSettingsNotifierProvider =
    NotifierProvider<QuranViewSettingsNotifier, QuranViewSettings>(
      QuranViewSettingsNotifier.new,
    );

bool isRtlEdition(String editionId) {
  final langCode = editionId.split('.').first.toLowerCase();
  return rtlLanguages.contains(langCode);
}

// RTL languages set
final Set<String> rtlLanguages = {
  'ar',
  'ur',
  'fa',
  'ps',
  'sd',
  'ug',
  'he',
  'yi',
};

bool isRtlLanguage(String languageCode) {
  return rtlLanguages.contains(languageCode.toLowerCase());
}

enum AyahViewMode {
  defaultMode,
  paperLight,
  paperCream,
  paperDark,
  paperWood,
  paperAged,
  gradientBlue,
  gradientPurple,
  gradientGreen;

  String getDisplayName(BuildContext context) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return context.loc.themeDefault;
      case AyahViewMode.paperLight:
        return context.loc.themePaperLight;
      case AyahViewMode.paperCream:
        return context.loc.themePaperCream;
      case AyahViewMode.paperDark:
        return context.loc.themePaperDark;
      case AyahViewMode.paperWood:
        return context.loc.themePaperWood;
      case AyahViewMode.paperAged:
        return context.loc.themePaperAged;
      case AyahViewMode.gradientBlue:
        return context.loc.themeGradientBlue;
      case AyahViewMode.gradientPurple:
        return context.loc.themeGradientPurple;
      case AyahViewMode.gradientGreen:
        return context.loc.themeGradientGreen;
    }
  }

  bool get isDarkTheme {
    switch (this) {
      case AyahViewMode.paperDark:
      case AyahViewMode.gradientBlue:
      case AyahViewMode.gradientPurple:
      case AyahViewMode.gradientGreen:
        return true;
      default:
        return false;
    }
  }

  Color getArabicTextColor(
    bool isSelected,
    ColorScheme scheme,
    RafeeqTheme theme,
  ) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return scheme.onSecondary;
      case AyahViewMode.paperLight:
      case AyahViewMode.paperCream:
      case AyahViewMode.paperWood:
      case AyahViewMode.paperAged:
        return Colors.black87;
      case AyahViewMode.paperDark:
      case AyahViewMode.gradientBlue:
      case AyahViewMode.gradientPurple:
      case AyahViewMode.gradientGreen:
        return Colors.white;
    }
  }

  Color getTranslationTextColor(
    bool isSelected,
    ColorScheme scheme,
    RafeeqTheme theme,
  ) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return theme.textColor.withValues(alpha: 0.9);
      case AyahViewMode.paperLight:
      case AyahViewMode.paperCream:
      case AyahViewMode.paperWood:
      case AyahViewMode.paperAged:
        return const Color(0xFF333333);
      case AyahViewMode.paperDark:
      case AyahViewMode.gradientBlue:
      case AyahViewMode.gradientPurple:
      case AyahViewMode.gradientGreen:
        return Colors.white.withValues(alpha: 0.9);
    }
  }

  Color getTransliterationTextColor(
    bool isSelected,
    ColorScheme scheme,
    RafeeqTheme theme,
  ) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return scheme.onSurfaceVariant;
      case AyahViewMode.paperLight:
      case AyahViewMode.paperCream:
      case AyahViewMode.paperWood:
      case AyahViewMode.paperAged:
        return const Color(0xFF555555);
      case AyahViewMode.paperDark:
      case AyahViewMode.gradientBlue:
      case AyahViewMode.gradientPurple:
      case AyahViewMode.gradientGreen:
        return Colors.white.withValues(alpha: 0.7);
    }
  }

  Color getAccentColor(bool isSelected, ColorScheme scheme, RafeeqTheme theme) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return scheme.primary;
      case AyahViewMode.paperLight:
      case AyahViewMode.paperCream:
        return scheme.primary.withValues(alpha: 0.8);
      case AyahViewMode.paperWood:
        return const Color(0xFF5D4037);
      case AyahViewMode.paperAged:
        return const Color(0xFF8D6E63);
      case AyahViewMode.paperDark:
        return const Color(0xFFFFD700);
      case AyahViewMode.gradientBlue:
      case AyahViewMode.gradientPurple:
      case AyahViewMode.gradientGreen:
        return Colors.white;
    }
  }

  Color getIconColor(bool isSelected, ColorScheme scheme, RafeeqTheme theme) {
    if (this == AyahViewMode.defaultMode) {
      return scheme.onSurfaceVariant.withValues(alpha: 0.6);
    }
    return getTranslationTextColor(
      isSelected,
      scheme,
      theme,
    ).withValues(alpha: 0.7);
  }

  BoxDecoration getDecoration(
    bool isSelected,
    ColorScheme scheme,
    RafeeqTheme theme,
  ) {
    switch (this) {
      case AyahViewMode.defaultMode:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : Border.all(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                ),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: 0.1),
                    scheme.primary.withValues(alpha: 0.2),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.secondary.withValues(alpha: 0.4),
                    scheme.surface.withValues(alpha: 0.1),
                    scheme.secondary.withValues(alpha: 0.2),
                  ],
                ),
        );
      case AyahViewMode.paperLight:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFFDFBF7),
          border: Border.all(color: const Color(0xFFE0D8C8), width: 1),
          boxShadow: kSubtleBoxShadow,
        );
      case AyahViewMode.paperCream:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF3EACD),
          border: Border.all(color: const Color(0xFFD4C5A3), width: 1),
          boxShadow: kSubtleBoxShadow,
        );
      case AyahViewMode.paperDark:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF2C2C2C),
          border: Border.all(color: const Color(0xFF444444), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case AyahViewMode.paperWood:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFDEB887),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDEB887), Color(0xFFD2B48C), Color(0xFFC19A6B)],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF8B4513).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case AyahViewMode.paperAged:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFEEDC82),
          gradient: const RadialGradient(
            radius: 1.2,
            colors: [Color(0xFFFFF8DC), Color(0xFFEEDC82)],
          ),
          border: Border.all(
            color: const Color(0xFFB8860B).withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        );
      case AyahViewMode.gradientBlue:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1A2980).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AyahViewMode.gradientPurple:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4A00E0).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AyahViewMode.gradientGreen:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF134E5E), Color(0xFF71B280)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF134E5E).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }
}

class QuranViewSettings {
  final double arabicFontSize;
  final double translationFontSize;
  final double transliterationFontSize;
  final bool showTranslation;
  final bool showTransliteration;
  final String translationEditionId;
  final String transliterationEditionId;
  final String arabicFontFamily;
  final String translationFontFamily;
  final AyahViewMode viewMode;
  final bool continueToNextSurah;
  final bool surahRepeat;
  final bool autoHidePlayerControls;

  const QuranViewSettings({
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.transliterationFontSize,
    this.showTranslation = true,
    this.showTransliteration = false,
    this.translationEditionId = 'en.asad',
    this.transliterationEditionId = 'en.transliteration',
    this.arabicFontFamily = 'PDMS Saleem Quran',
    this.translationFontFamily = 'GoogleSans',
    this.viewMode = AyahViewMode.defaultMode,
    this.continueToNextSurah = false,
    this.surahRepeat = false,
    this.autoHidePlayerControls = false,
  });

  QuranViewSettings copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    double? transliterationFontSize,
    bool? showTranslation,
    bool? showTransliteration,
    String? translationEditionId,
    String? transliterationEditionId,
    String? arabicFontFamily,
    String? translationFontFamily,
    AyahViewMode? viewMode,
    bool? continueToNextSurah,
    bool? surahRepeat,
    bool? autoHidePlayerControls,
  }) {
    return QuranViewSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      transliterationFontSize:
          transliterationFontSize ?? this.transliterationFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      translationEditionId: translationEditionId ?? this.translationEditionId,
      transliterationEditionId:
          transliterationEditionId ?? this.transliterationEditionId,
      arabicFontFamily: arabicFontFamily ?? this.arabicFontFamily,
      translationFontFamily:
          translationFontFamily ?? this.translationFontFamily,
      viewMode: viewMode ?? this.viewMode,
      continueToNextSurah: continueToNextSurah ?? this.continueToNextSurah,
      surahRepeat: surahRepeat ?? this.surahRepeat,
      autoHidePlayerControls:
          autoHidePlayerControls ?? this.autoHidePlayerControls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'arabicFontSize': arabicFontSize,
      'translationFontSize': translationFontSize,
      'transliterationFontSize': transliterationFontSize,
      'showTranslation': showTranslation,
      'showTransliteration': showTransliteration,
      'translationEditionId': translationEditionId,
      'transliterationEditionId': transliterationEditionId,
      'arabicFontFamily': arabicFontFamily,
      'translationFontFamily': translationFontFamily,
      'viewMode': viewMode.index,
      'continueToNextSurah': continueToNextSurah,
      'surahRepeat': surahRepeat,
      'autoHidePlayerControls': autoHidePlayerControls,
    };
  }

  static const QuranViewSettings defaultSettings = QuranViewSettings(
    arabicFontSize: 28,
    translationFontSize: 16,
    transliterationFontSize: 14,
    showTranslation: true,
    showTransliteration: false,
    translationEditionId: 'en.asad',
    transliterationEditionId: 'en.transliteration',
    arabicFontFamily: 'PDMS Saleem Quran',
    translationFontFamily: 'GoogleSans',
    viewMode: AyahViewMode.defaultMode,
    continueToNextSurah: false,
    surahRepeat: false,
    autoHidePlayerControls: false,
  );

  factory QuranViewSettings.fromMap(Map<String, dynamic> map) {
    return QuranViewSettings(
      arabicFontSize:
          (map['arabicFontSize'] as num?)?.toDouble() ??
          defaultSettings.arabicFontSize,
      translationFontSize:
          (map['translationFontSize'] as num?)?.toDouble() ??
          defaultSettings.translationFontSize,
      transliterationFontSize:
          (map['transliterationFontSize'] as num?)?.toDouble() ??
          defaultSettings.transliterationFontSize,
      showTranslation:
          map['showTranslation'] as bool? ?? defaultSettings.showTranslation,
      showTransliteration:
          map['showTransliteration'] as bool? ??
          defaultSettings.showTransliteration,
      translationEditionId:
          map['translationEditionId'] as String? ??
          defaultSettings.translationEditionId,
      transliterationEditionId:
          map['transliterationEditionId'] as String? ??
          defaultSettings.transliterationEditionId,
      arabicFontFamily:
          map['arabicFontFamily'] as String? ??
          defaultSettings.arabicFontFamily,
      translationFontFamily:
          map['translationFontFamily'] as String? ??
          defaultSettings.translationFontFamily,
      viewMode: map['viewMode'] != null
          ? AyahViewMode.values[map['viewMode'] as int]
          : defaultSettings.viewMode,
      continueToNextSurah:
          map['continueToNextSurah'] as bool? ??
          defaultSettings.continueToNextSurah,
      surahRepeat: map['surahRepeat'] as bool? ?? defaultSettings.surahRepeat,
      autoHidePlayerControls:
          map['autoHidePlayerControls'] as bool? ??
          defaultSettings.autoHidePlayerControls,
    );
  }
}

class QuranViewSettingsNotifier extends Notifier<QuranViewSettings> {
  late final StorageBox<QuranViewSettings> _storageBox;

  @override
  QuranViewSettings build() {
    _storageBox = ref.watch(quranViewSettingsStorageBoxProvider);
    return _storageBox.get();
  }

  @override
  set state(QuranViewSettings value) {
    super.state = value;
    _storageBox.set(value);
  }

  void setArabicFontSize(double fontSize) =>
      state = state.copyWith(arabicFontSize: fontSize);
  void setTranslationFontSize(double fontSize) =>
      state = state.copyWith(translationFontSize: fontSize);
  void setTransliterationFontSize(double fontSize) =>
      state = state.copyWith(transliterationFontSize: fontSize);
  void toggleTranslation(bool value) =>
      state = state.copyWith(showTranslation: value);
  void toggleTransliteration(bool value) =>
      state = state.copyWith(showTransliteration: value);
  void setTranslationEditionId(String editionId) =>
      state = state.copyWith(translationEditionId: editionId);
  void setViewMode(AyahViewMode mode) => state = state.copyWith(viewMode: mode);
  void toggleContinueToNextSurah(bool value) => state = state.copyWith(
    continueToNextSurah: value,
    surahRepeat: value ? false : state.surahRepeat,
  );
  void toggleSurahRepeat(bool value) => state = state.copyWith(
    surahRepeat: value,
    continueToNextSurah: value ? false : state.continueToNextSurah,
  );

  void toggleAutoHidePlayerControls(bool value) =>
      state = state.copyWith(autoHidePlayerControls: value);
}

class QuranViewSettingsScreen extends ConsumerWidget {
  const QuranViewSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final notifier = ref.read(quranViewSettingsNotifierProvider.notifier);
    final palette = SettingsPalette.of(context);
    final editionsAsync = ref.watch(editionsProvider);
    final quranDataAsync = ref.watch(quranDataProvider);
    final previewTranslationAsync = ref.watch(
      quranEditionTextProvider((
        type: QuranFetchType.surah,
        number: 1,
        editionId: settings.translationEditionId,
      )),
    );
    final reciter = ref.watch(reciterStateNotifierProvider).reciter;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final selectedEditionName = editionsAsync.when(
      data: (editions) {
        final edition = editions
            .where(
              (edition) => edition.identifier == settings.translationEditionId,
            )
            .firstOrNull;
        if (edition == null) return settings.translationEditionId;
        return isUrdu ? edition.name : edition.englishName;
      },
      loading: () => 'Loading...',
      error: (_, _) => settings.translationEditionId,
    );

    final cards = <Widget>[
      SettingsCard(
        icon: Icons.format_size_rounded,
        title: context.loc.arabicFontSize,
        subtitle: '${settings.arabicFontSize.toInt()}',
        palette: palette,
        supporting: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ayahPreview(
              context,
              palette: palette,
              quranDataAsync: quranDataAsync,
              translationAsync: previewTranslationAsync,
              translationEditionId: settings.translationEditionId,
              arabicFontSize: settings.arabicFontSize,
              translationFontSize: settings.translationFontSize,
              showArabic: true,
              showTranslation: false,
            ),
            const SizedBox(height: 8),
            _settingsSlider(
              context,
              palette: palette,
              value: settings.arabicFontSize,
              min: 20,
              max: 40,
              onChanged: notifier.setArabicFontSize,
            ),
          ],
        ),
      ),
      SettingsCard(
        icon: Icons.translate_rounded,
        title: context.loc.showTranslation,
        subtitle: context.loc.toggleTranslationVisibility,
        palette: palette,
        switchValue: settings.showTranslation,
        onSwitchChanged: notifier.toggleTranslation,
      ),
      if (settings.showTranslation) ...[
        SettingsCard(
          icon: Icons.text_fields_rounded,
          title: context.loc.translationFontSize,
          subtitle: '${settings.translationFontSize.toInt()}',
          palette: palette,
          supporting: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ayahPreview(
                context,
                palette: palette,
                quranDataAsync: quranDataAsync,
                translationAsync: previewTranslationAsync,
                translationEditionId: settings.translationEditionId,
                arabicFontSize: settings.arabicFontSize,
                translationFontSize: settings.translationFontSize,
                showArabic: false,
                showTranslation: true,
              ),
              const SizedBox(height: 8),
              _settingsSlider(
                context,
                palette: palette,
                value: settings.translationFontSize,
                min: 12,
                max: 36,
                onChanged: notifier.setTranslationFontSize,
              ),
            ],
          ),
        ),
        SettingsCard(
          icon: Icons.menu_book_outlined,
          title: context.loc.translationEdition,
          subtitle: selectedEditionName,
          palette: palette,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.translationSelection),
        ),
      ],
      SettingsCard(
        icon: Icons.record_voice_over_outlined,
        title: context.loc.changeReciter,
        subtitle: isUrdu ? reciter.name : reciter.englishName,
        palette: palette,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.chooseReciter),
      ),
      SettingsCard(
        icon: Icons.restart_alt_rounded,
        title: context.loc.resetToDefault,
        subtitle: context.loc.resetToDefaultSubtitle,
        palette: palette,
        foregroundColor: Colors.redAccent,
        onTap: () => _showResetConfirmation(context, ref),
      ),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(
        title: context.loc.quranViewSettings,
        palette: palette,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              quranPlayerAwareBottomPadding(
                context,
                playerVisible: playerVisible,
              ),
            ),
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => cards[index],
          ),
        ),
      ),
    );
  }

  Widget _settingsSlider(
    BuildContext context, {
    required SettingsPalette palette,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        activeTrackColor: palette.accent,
        inactiveTrackColor: palette.divider,
        thumbColor: palette.accent,
        overlayColor: palette.accent.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        padding: EdgeInsets.zero,
        value: value,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _ayahPreview(
    BuildContext context, {
    required SettingsPalette palette,
    required AsyncValue<QuranData> quranDataAsync,
    required AsyncValue<Map<int, String>> translationAsync,
    required String translationEditionId,
    required double arabicFontSize,
    required double translationFontSize,
    required bool showArabic,
    required bool showTranslation,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: quranDataAsync.when(
          loading: () => SizedBox(
            height: 86,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.accent,
              ),
            ),
          ),
          error: (_, _) => Text(
            context.loc.errorLoadingQuranData,
            style: TextStyle(color: palette.subtitle, fontSize: 12),
          ),
          data: (quranData) {
            final ayah = quranData.ayahs.firstOrNull;
            if (ayah == null) return const SizedBox.shrink();
            if (!showTranslation) {
              return _previewAyahText(
                context,
                ayah: ayah,
                translation: null,
                translationEditionId: translationEditionId,
                palette: palette,
                arabicFontSize: arabicFontSize,
                translationFontSize: translationFontSize,
                showArabic: showArabic,
                showTranslation: false,
              );
            }
            return translationAsync.when(
              loading: () => _previewAyahText(
                context,
                ayah: ayah,
                translation: null,
                translationEditionId: translationEditionId,
                palette: palette,
                arabicFontSize: arabicFontSize,
                translationFontSize: translationFontSize,
                showArabic: showArabic,
                showTranslation: showTranslation,
              ),
              error: (_, _) => _previewAyahText(
                context,
                ayah: ayah,
                translation: null,
                translationEditionId: translationEditionId,
                palette: palette,
                arabicFontSize: arabicFontSize,
                translationFontSize: translationFontSize,
                showArabic: showArabic,
                showTranslation: showTranslation,
              ),
              data: (translations) => _previewAyahText(
                context,
                ayah: ayah,
                translation: translations[ayah.number],
                translationEditionId: translationEditionId,
                palette: palette,
                arabicFontSize: arabicFontSize,
                translationFontSize: translationFontSize,
                showArabic: showArabic,
                showTranslation: showTranslation,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _previewAyahText(
    BuildContext context, {
    required Ayah ayah,
    required String? translation,
    required String translationEditionId,
    required SettingsPalette palette,
    required double arabicFontSize,
    required double translationFontSize,
    required bool showArabic,
    required bool showTranslation,
  }) {
    final translationIsUrdu =
        translationEditionId.split('.').first.toLowerCase() == 'ur';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showArabic)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: palette.title,
                fontFamily: 'PDMS Saleem Quran',
                fontSize: arabicFontSize,
                height: 1.45,
              ),
            ),
          ),
        if (showArabic && showTranslation) const SizedBox(height: 6),
        if (showTranslation && translation == null)
          Text(
            'Loading translation…',
            style: TextStyle(color: palette.subtitle, fontSize: 12),
          )
        else if (showTranslation)
          Directionality(
            textDirection: translationIsUrdu
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Text(
              translation!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: translationIsUrdu ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: translationIsUrdu
                    ? 'Jameel Noori Nastaleeq'
                    : 'GoogleSans',
                fontSize: translationFontSize,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final theme = context.mainTheme;

    AppInfoDialog.show(
      context,
      title: context.loc.resetSettingsTitle,
      iconAsset: "assets/logo.svg",
      gradientColors: [theme.secondaryColor, theme.primaryColor],
      contentWidgets: [
        Text(
          context.loc.resetSettingsMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: CancelButton()),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Reset all settings to default
                  final notifier = ref.read(
                    quranViewSettingsNotifierProvider.notifier,
                  );

                  // Reset font sizes
                  notifier.setArabicFontSize(
                    QuranViewSettings.defaultSettings.arabicFontSize,
                  );
                  notifier.setTranslationFontSize(
                    QuranViewSettings.defaultSettings.translationFontSize,
                  );
                  notifier.setTransliterationFontSize(
                    QuranViewSettings.defaultSettings.transliterationFontSize,
                  );

                  // Reset visibility toggles
                  notifier.toggleTranslation(
                    QuranViewSettings.defaultSettings.showTranslation,
                  );
                  notifier.toggleTransliteration(
                    QuranViewSettings.defaultSettings.showTransliteration,
                  );

                  // Reset edition IDs
                  notifier.setTranslationEditionId(
                    QuranViewSettings.defaultSettings.translationEditionId,
                  );

                  // Reset view mode
                  notifier.setViewMode(
                    QuranViewSettings.defaultSettings.viewMode,
                  );

                  // Reset playback settings
                  notifier.toggleContinueToNextSurah(
                    QuranViewSettings.defaultSettings.continueToNextSurah,
                  );
                  notifier.toggleSurahRepeat(
                    QuranViewSettings.defaultSettings.surahRepeat,
                  );
                  notifier.toggleAutoHidePlayerControls(
                    QuranViewSettings.defaultSettings.autoHidePlayerControls,
                  );

                  Navigator.pop(context);

                  showRafeeqToast(context, context.loc.settingsResetSuccess);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.loc.reset,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Translation Selection Page
class TranslationSelectionPage extends StatefulHookConsumerWidget {
  const TranslationSelectionPage({
    super.key,
    this.selectionOnly = false,
    this.selectedEditionId,
  });

  final bool selectionOnly;
  final String? selectedEditionId;

  @override
  ConsumerState<TranslationSelectionPage> createState() =>
      _TranslationSelectionPageState();
}

class _TranslationSelectionPageState
    extends ConsumerState<TranslationSelectionPage> {
  String searchQuery = '';

  final Map<String, Map<String, String>> languageInfo = {
    'en': {'name': 'English', 'flag': '🇬🇧'},
    'ar': {'name': 'Arabic', 'flag': '🇸🇦'},
    'ur': {'name': 'Urdu', 'flag': '🇵🇰'},
    'id': {'name': 'Indonesian', 'flag': '🇮🇩'},
    'tr': {'name': 'Turkish', 'flag': '🇹🇷'},
    'fr': {'name': 'French', 'flag': '🇫🇷'},
    'de': {'name': 'German', 'flag': '🇩🇪'},
    'es': {'name': 'Spanish', 'flag': '🇪🇸'},
    'it': {'name': 'Italian', 'flag': '🇮🇹'},
    'pt': {'name': 'Portuguese', 'flag': '🇵🇹'},
    'ru': {'name': 'Russian', 'flag': '🇷🇺'},
    'zh': {'name': 'Chinese', 'flag': '🇨🇳'},
    'ja': {'name': 'Japanese', 'flag': '🇯🇵'},
    'ko': {'name': 'Korean', 'flag': '🇰🇷'},
    'hi': {'name': 'Hindi', 'flag': '🇮🇳'},
    'bn': {'name': 'Bengali', 'flag': '🇧🇩'},
    'ms': {'name': 'Malay', 'flag': '🇲🇾'},
    'fa': {'name': 'Persian', 'flag': '🇮🇷'},
    'uz': {'name': 'Uzbek', 'flag': '🇺🇿'},
    'sq': {'name': 'Albanian', 'flag': '🇦🇱'},
    'az': {'name': 'Azerbaijani', 'flag': '🇦🇿'},
    'bs': {'name': 'Bosnian', 'flag': '🇧🇦'},
    'dv': {'name': 'Divehi', 'flag': '🇲🇻'},
    'ha': {'name': 'Hausa', 'flag': '🇳🇬'},
    'kk': {'name': 'Kazakh', 'flag': '🇰🇿'},
    'ku': {'name': 'Kurdish', 'flag': '🏳️'},
    'ml': {'name': 'Malayalam', 'flag': '🇮🇳'},
    'nl': {'name': 'Dutch', 'flag': '🇳🇱'},
    'pl': {'name': 'Polish', 'flag': '🇵🇱'},
    'ro': {'name': 'Romanian', 'flag': '🇷🇴'},
    'sd': {'name': 'Sindhi', 'flag': '🇵🇰'},
    'so': {'name': 'Somali', 'flag': '🇸🇴'},
    'sw': {'name': 'Swahili', 'flag': '🇰🇪'},
    'ta': {'name': 'Tamil', 'flag': '🇮🇳'},
    'tg': {'name': 'Tajik', 'flag': '🇹🇯'},
    'th': {'name': 'Thai', 'flag': '🇹🇭'},
    'tt': {'name': 'Tatar', 'flag': '🇷🇺'},
    'ug': {'name': 'Uyghur', 'flag': '🇨🇳'},
    'ps': {'name': 'Pashto', 'flag': '🇦🇫'},
  };

  String getLanguageName(String code) =>
      languageInfo[code.toLowerCase()]?['name'] ?? code.toUpperCase();
  String getLanguageFlag(String code) =>
      languageInfo[code.toLowerCase()]?['flag'] ?? '🌐';

  List<QuranEdition> filterEditions(List<QuranEdition> editions, String query) {
    if (query.isEmpty) return editions;
    final lowerQuery = query.toLowerCase();
    return editions
        .where(
          (edition) =>
              edition.name.toLowerCase().contains(lowerQuery) ||
              edition.englishName.toLowerCase().contains(lowerQuery) ||
              edition.identifier.toLowerCase().contains(lowerQuery) ||
              getLanguageName(
                edition.language,
              ).toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  Map<String, List<QuranEdition>> groupEditionsByLanguage(
    List<QuranEdition> editions,
  ) {
    final groups = <String, List<QuranEdition>>{};
    for (final edition in editions) {
      final lang = edition.language.toLowerCase();
      groups.putIfAbsent(lang, () => []).add(edition);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final editionsAsync = ref.watch(editionsProvider);
    final settings = ref.watch(quranViewSettingsNotifierProvider);
    final bottomPadding = quranPlayerAwareBottomPadding(
      context,
      playerVisible: QuranPlayerVisibility.of(context),
    );

    return LocationPickerScaffold(
      title: context.loc.selectTranslation,
      searchHint: context.loc.searchTranslations,
      palette: palette,
      onQueryChanged: (value) => setState(() => searchQuery = value),
      child: editionsAsync.when(
        data: (editions) {
          final filteredEditions = filterEditions(editions, searchQuery);
          final groupedEditions = groupEditionsByLanguage(filteredEditions);
          final sortedLanguages = groupedEditions.keys.toList()
            ..sort((a, b) {
              const priority = {'en': 0, 'ur': 1};
              final aPriority = priority[a] ?? 2;
              final bPriority = priority[b] ?? 2;
              if (aPriority != bPriority) {
                return aPriority.compareTo(bPriority);
              }
              return getLanguageName(a).compareTo(getLanguageName(b));
            });

          if (sortedLanguages.isEmpty) {
            return LocationPickerEmptyState(
              message: context.loc.noResultsFound,
              palette: palette,
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
            itemCount: sortedLanguages.length,
            itemBuilder: (context, index) {
              final languageCode = sortedLanguages[index];
              final languageEditions = groupedEditions[languageCode]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Row(
                      children: [
                        Text(
                          getLanguageName(languageCode),
                          style: TextStyle(
                            fontFamily: languageCode == 'ur'
                                ? 'Jameel Noori Nastaleeq'
                                : 'GoogleSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${languageEditions.length})',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...languageEditions.map((edition) {
                    final isSelected =
                        (widget.selectedEditionId ??
                            settings.translationEditionId) ==
                        edition.identifier;
                    return LocationPickerRow(
                      title: isUrdu ? edition.name : edition.englishName,
                      fontFamily: edition.language.toLowerCase() == 'ur'
                          ? 'Jameel Noori Nastaleeq'
                          : 'GoogleSans',
                      disableTextScaling: false,
                      selected: isSelected,
                      palette: palette,
                      onTap: () {
                        if (widget.selectionOnly) {
                          Navigator.of(context).pop(edition);
                          return;
                        }
                        ref
                            .read(quranViewSettingsNotifierProvider.notifier)
                            .setTranslationEditionId(edition.identifier);
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => LocationPickerLoadingState(palette: palette),
        error: (_, _) => LocationPickerErrorState(
          palette: palette,
          message: context.loc.noResultsFound,
          retryLabel: context.loc.retry,
          onRetry: () => ref.invalidate(editionsProvider),
        ),
      ),
    );
  }
}
