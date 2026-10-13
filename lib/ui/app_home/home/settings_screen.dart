import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/calculation_method_screen.dart';
import 'package:rafeeq/ui/app_home/home/high_latitude_rule_screen.dart';
import 'package:rafeeq/ui/app_home/home/hijri_correction_screen.dart';
import 'package:rafeeq/ui/app_home/home/juristic_method_screen.dart';
import 'package:rafeeq/ui/app_home/home/language_screen.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/app_home/home/settings_sheets.dart';
import 'package:rafeeq/ui/app_home/home/theme_screen.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_screen.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _aboutOpenedKey = 'about_opened_v1';

final _showAboutNewBadgeProvider = Provider<bool>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return !(preferences.getBool(_aboutOpenedKey) ?? false);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final palette = SettingsPalette.of(context);
    final analyticsService = ref.watch(analyticsServiceProvider);
    final settingsState = ref.watch(appSettingsNotifierProvider);
    final language = settingsState.language;
    final prayerSettings = ref.watch(prayerTimesSettingsNotifierProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final selectedLanguageId = ref.watch(selectedLanguageIdProvider);
    final userLocation = ref.watch(userLocationNotifierProvider);
    final showAboutNewBadge = ref.watch(_showAboutNewBadgeProvider);

    final cards = <_SettingsCardData>[
      _SettingsCardData(
        icon: Icons.translate_outlined,
        title: context.loc.language,
        subtitle:
            languageLabelFor(context, selectedLanguageId) ??
            switch (language) {
              AppLanguage.en => context.loc.languageEnglish,
              AppLanguage.ur => context.loc.languageUrdu,
            },
        onTap: () {
          analyticsService.logSettingsLanguageScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.language,
              ),
              builder: (context) => const LanguageScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: Icons.explore_outlined,
        title: context.loc.location,
        subtitle: _locationLabel(context, userLocation),
        disableSubtitleTextScaling: true,
        onTap: () {
          analyticsService.logSettingsLocationScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.location,
              ),
              builder: (context) => const LocationScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: Icons.palette_outlined,
        title: context.loc.appTheme,
        subtitle: themeModeLabel(context, settingsState.themeMode),
        onTap: () {
          analyticsService.logSettingsThemeScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: AnalyticsScreenNames.theme),
              builder: (context) => const ThemeScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: CupertinoIcons.clock,
        title: context.loc.calculationMethod,
        subtitle: prayerSettings.prayerCalcMethod.getLabel(context),
        onTap: () {
          analyticsService.logSettingsCalculationScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.calculationMethod,
              ),
              builder: (context) => const CalculationMethodScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: Icons.layers_outlined,
        title: context.loc.juristicMethod,
        subtitle: prayerSettings.asrCalculationMethod.getLabel(context),
        onTap: () {
          analyticsService.logSettingsJuristicScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.juristicMethod,
              ),
              builder: (context) => const JuristicMethodScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: Icons.public_outlined,
        title: context.loc.highLatitudeRule,
        subtitle: prayerSettings.highLatitudeAdjustment.getLabel(context),
        onTap: () {
          analyticsService.logSettingsHighLatitudeScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.highLatitudeRule,
              ),
              builder: (context) => const HighLatitudeRuleScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: CupertinoIcons.calendar,
        title: context.loc.hijriCorrection,
        subtitle: settingsState.hijriCorrection.getLabel(context),
        onTap: () {
          analyticsService.logSettingsHijriCorrectionScreenOpened();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(
                name: AnalyticsScreenNames.hijriCorrection,
              ),
              builder: (context) => const HijriCorrectionScreen(),
            ),
          );
        },
      ),
      _SettingsCardData(
        icon: Icons.schedule_outlined,
        title: context.loc.timeFormat,
        subtitle: prayerSettings.timeFormat.getLabel(context),
        onTap: () => showTimeFormatScreen(context),
      ),
      _SettingsCardData(
        icon: Icons.access_time_outlined,
        title: context.loc.prayerTimes,
        subtitle: _locationLabel(context, userLocation),
        disableSubtitleTextScaling: true,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.prayerTimes),
      ),
      _SettingsCardData(
        icon: Icons.notifications_none_outlined,
        title: context.loc.notification,
        subtitle: language == AppLanguage.ur
            ? 'نماز کی یاددہانی اور اطلاع کی ترتیب'
            : 'Prayer reminders and notification settings',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: AnalyticsScreenNames.prayerNotificationSettings,
            ),
            builder: (context) => const PrayerNotificationSettingsScreen(),
          ),
        ),
      ),
      _SettingsCardData(
        icon: Icons.menu_book_outlined,
        title: context.loc.quranViewSettings,
        subtitle: language == AppLanguage.ur
            ? 'خط، سائز، ترجمہ اور تلاوت کی ترتیبات'
            : 'Script, font size, translation & recitation settings',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.quranViewSettings);
        },
      ),
      _SettingsCardData(
        icon: Icons.chat_bubble_outline_rounded,
        title: context.loc.feedback,
        subtitle: context.loc.feedbackSubtitle,
        onTap: () async {
          analyticsService.logSettingsFeedbackTapped();
          if (await canLaunchUrl(feedbackFormUri)) {
            await launchUrl(
              feedbackFormUri,
              mode: LaunchMode.externalApplication,
            );
          }
        },
      ),
      _SettingsCardData(
        icon: Icons.star_border_rounded,
        title: context.loc.rateThisApp,
        subtitle: context.loc.rateThisAppSubtitle,
        onTap: () async {
          analyticsService.logSettingsRateAppTapped();
          if (await canLaunchUrl(playStoreUri)) {
            await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
          }
        },
      ),
      _SettingsCardData(
        icon: Icons.share_outlined,
        title: context.loc.shareThisApp,
        subtitle: context.loc.shareThisAppSubtitle,
        onTap: () {
          analyticsService.logSettingsShareAppTapped();
          SharePlus.instance.share(ShareParams(uri: playStoreUri));
        },
      ),
      _SettingsCardData(
        icon: Icons.info_outline_rounded,
        title: context.loc.about,
        subtitle: context.loc.aboutSubtitle,
        badge: showAboutNewBadge ? 'NEW' : null,
        onTap: () async {
          await ref
              .read(sharedPreferencesProvider)
              .setBool(_aboutOpenedKey, true);
          ref.invalidate(_showAboutNewBadgeProvider);
          if (!context.mounted) return;
          await Navigator.of(context).pushNamed(AppRoutes.about);
        },
      ),
      _SettingsCardData(
        icon: Icons.tag_rounded,
        title: context.loc.version,
        subtitle: '${context.loc.versionSubtitle}  •  ${packageInfo.version}',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.version),
      ),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(
        title: context.loc.settings,
        palette: palette,
        onBack: onBack,
        actions: const [_DeveloperPanelAction()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  navigationScreenPlayerAwareBottomPadding(
                    playerVisible: playerVisible,
                  ),
                ),
                itemCount: cards.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = cards[index];
                  return SettingsCard(
                    icon: data.icon,
                    title: data.title,
                    subtitle: data.subtitle,
                    disableSubtitleTextScaling: data.disableSubtitleTextScaling,
                    palette: palette,
                    onTap: data.onTap,
                    switchValue: data.switchValue,
                    onSwitchChanged: data.onSwitchChanged,
                    badge: data.badge,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeveloperPanelAction extends StatelessWidget {
  const _DeveloperPanelAction();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Developer Panel',
      onPressed: () =>
          Navigator.of(context).pushNamed(AppRoutes.developerPanel),
      icon: const Icon(Icons.developer_mode_outlined),
    );
  }
}

String _locationLabel(BuildContext context, UserLocation? location) {
  if (location == null) return context.loc.locationNotSet;

  final parts = [
    location.city,
    location.country,
  ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
  return parts.isEmpty ? context.loc.locationNotSet : parts.join(', ');
}

class _SettingsCardData {
  const _SettingsCardData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.disableSubtitleTextScaling = false,
    this.badge,
  }) : assert(
         (switchValue == null) == (onSwitchChanged == null),
         'Switch value and callback must be supplied together.',
       );

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool disableSubtitleTextScaling;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final String? badge;
}
