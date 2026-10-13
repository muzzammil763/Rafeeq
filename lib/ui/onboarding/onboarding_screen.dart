import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/services/country_city_service.dart';
import 'package:rafeeq/data/services/notification_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/app_home_screen.dart';
import 'package:rafeeq/ui/app_home/home/language_screen.dart';
import 'package:rafeeq/ui/app_home/home/location_picker_screen.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/app_home/home/theme_screen.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/ui/widgets/scrollable_column.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/localized_font.dart';

enum _OnboardingStep {
  welcome,
  language,
  notifications,
  location,
  juristic,
  theme,
}

const _actionButtonHeight = 40.0;
const _actionsVerticalPadding = 12.0;
const _actionsHeight = _actionButtonHeight + 12;
const _artworkPadding = 12.0;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  var _step = _OnboardingStep.welcome;
  bool _requestingNotifications = false;
  bool _updatingLocation = false;
  bool _manualExpanded = false;
  bool _locationChoiceTouched = false;
  String? _country;
  String? _countryCode;
  String? _city;

  @override
  void initState() {
    super.initState();
    final location = ref.read(userLocationNotifierProvider);
    _country = location?.country;
    _countryCode = location?.countryCode;
    _city = location?.city;
    _manualExpanded = location?.source == UserLocationSource.manual;
    _locationChoiceTouched = location != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(appSettingsNotifierProvider).themeMode != ThemeMode.system) {
        ref
            .read(appSettingsNotifierProvider.notifier)
            .setThemeMode(ThemeMode.system);
      }
    });
  }

  void _next() {
    if (_step.index == _OnboardingStep.values.length - 1) {
      _finish();
      return;
    }
    setState(() => _step = _OnboardingStep.values[_step.index + 1]);
  }

  void _back() {
    if (_step.index > 0) {
      setState(() => _step = _OnboardingStep.values[_step.index - 1]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _requestNotifications() async {
    if (_requestingNotifications) return;
    setState(() => _requestingNotifications = true);
    try {
      final service = ref.read(notificationServiceProvider);
      await service.init();
      await service.requestPermissions();
    } catch (_) {
      // Denial or an unavailable platform service must not trap the user.
    }
    if (!mounted) return;
    setState(() => _requestingNotifications = false);
    _next();
  }

  Future<void> _useAutomaticLocation() async {
    if (_updatingLocation) return;
    setState(() {
      _locationChoiceTouched = true;
      _updatingLocation = true;
    });
    var updated = false;
    try {
      updated = await ref
          .read(userLocationNotifierProvider.notifier)
          .updateUserLocation();
    } catch (_) {
      updated = false;
    }
    if (!mounted) return;
    final location = ref.read(userLocationNotifierProvider);
    setState(() {
      _updatingLocation = false;
      if (updated) {
        _country = location?.country;
        _countryCode = location?.countryCode;
        _city = location?.city;
        _manualExpanded = false;
      }
    });
    _message(
      updated
          ? context.loc.locationUpdated
          : context.loc.locationPermissionDenied,
    );
  }

  void _toggleManualLocation() {
    setState(() {
      _locationChoiceTouched = true;
      _manualExpanded = !_manualExpanded;
    });
  }

  Future<void> _continueFromLocation() async {
    if (_updatingLocation) return;
    final savedLocation = ref.read(userLocationNotifierProvider);
    if (_locationChoiceTouched || savedLocation != null) {
      _next();
      return;
    }

    setState(() => _updatingLocation = true);
    try {
      await ref
          .read(userLocationNotifierProvider.notifier)
          .autoRequestLocationIfNeeded();
    } catch (_) {
      // Permission denial or an unavailable location service must not block
      // onboarding.
    }
    if (!mounted) return;
    final location = ref.read(userLocationNotifierProvider);
    setState(() {
      _updatingLocation = false;
      if (location != null) {
        _country = location.country;
        _countryCode = location.countryCode;
        _city = location.city;
        _manualExpanded = false;
      }
    });
    _next();
  }

  Future<void> _chooseCountry() async {
    final country = await Navigator.of(context).push<CountryOption>(
      MaterialPageRoute<CountryOption>(
        settings: const RouteSettings(name: AnalyticsScreenNames.countryPicker),
        builder: (_) => CountryPickerScreen(
          selectedCountryCode: _countryCode,
          selectedCountryName: _country,
        ),
      ),
    );
    if (!mounted || country == null) return;
    setState(() {
      if (_countryCode != country.code) _city = null;
      _country = country.name;
      _countryCode = country.code;
      _manualExpanded = true;
    });
  }

  Future<void> _chooseCity() async {
    if (_country == null || _countryCode == null || _updatingLocation) return;
    final country = CountryOption(
      name: _country!,
      code: _countryCode!,
      emoji: '',
    );
    final city = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: AnalyticsScreenNames.cityPicker),
        builder: (_) => CityPickerScreen(country: country, selectedCity: _city),
      ),
    );
    if (!mounted || city == null) return;
    setState(() {
      _city = city;
      _updatingLocation = true;
    });
    final updated = await ref
        .read(userLocationNotifierProvider.notifier)
        .setManualLocation(
          country: country.name,
          countryCode: country.code,
          city: city,
        );
    if (!mounted) return;
    setState(() => _updatingLocation = false);
    _message(
      updated ? context.loc.locationUpdated : context.loc.locationNotFound,
    );
  }

  void _message(String message) {
    showRafeeqToast(context, message);
  }

  Future<void> _finish() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool('onboarding_completed_v2', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: AnalyticsScreenNames.home),
        builder: (_) => const AppHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const side = 12.0;
            const padding = EdgeInsets.fromLTRB(side, 28, side, 28);
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _content(palette, padding),
                      ),
                    ),
                  ),
                ),
                _Actions(
                  step: _step,
                  nextIsLoading: _requestingNotifications || _updatingLocation,
                  palette: palette,
                  onBack: _back,
                  onNext: switch (_step) {
                    _OnboardingStep.notifications => _requestNotifications,
                    _OnboardingStep.location => _continueFromLocation,
                    _ => _next,
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(SettingsPalette palette, EdgeInsets padding) {
    return switch (_step) {
      _OnboardingStep.welcome => _Welcome(
        key: const ValueKey('welcome'),
        palette: palette,
        padding: padding,
      ),
      _OnboardingStep.language => _Language(
        key: const ValueKey('language'),
        palette: palette,
        padding: padding,
      ),
      _OnboardingStep.notifications => _Notifications(
        key: const ValueKey('notifications'),
        palette: palette,
        padding: padding,
      ),
      _OnboardingStep.location => _Location(
        key: const ValueKey('location'),
        palette: palette,
        padding: padding,
        manualExpanded: _manualExpanded,
        updating: _updatingLocation,
        country: _country,
        city: _city,
        onAutomatic: _useAutomaticLocation,
        onManual: _toggleManualLocation,
        onCountry: _chooseCountry,
        onCity: _chooseCity,
      ),
      _OnboardingStep.juristic => _Juristic(
        key: const ValueKey('juristic'),
        palette: palette,
        padding: padding,
      ),
      _OnboardingStep.theme => _Theme(
        key: const ValueKey('theme'),
        palette: palette,
        padding: padding,
      ),
    };
  }
}

class _Page extends StatelessWidget {
  const _Page({
    super.key,
    required this.title,
    required this.subtitle,
    required this.padding,
    required this.palette,
    required this.content,
    this.artwork,
    this.header,
    this.titleSpan,
    this.titleSize = 28,
  });
  final String title;
  final String subtitle;
  final EdgeInsets padding;
  final SettingsPalette palette;
  final List<Widget> content;
  final Widget? artwork;
  final Widget? header;
  final InlineSpan? titleSpan;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return ScrollableColumn(
      key: key,
      padding: padding,
      physics: const ClampingScrollPhysics(),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 24)],
        Text.rich(
          titleSpan ?? TextSpan(text: title),
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ...content,
        if (artwork != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: _artworkPadding,
                bottom: _artworkPadding + _actionsHeight,
              ),
              child: Center(child: artwork),
            ),
          ),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({super.key, required this.palette, required this.padding});
  final SettingsPalette palette;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return _Page(
      key: key,
      title:
          '${context.loc.onboardingAppName} - ${context.loc.onboardingWelcomeTitle}',
      titleSpan: TextSpan(
        children: [
          TextSpan(
            text: context.loc.onboardingAppName,
            style: TextStyle(color: palette.accent),
          ),
          TextSpan(text: ' - ${context.loc.onboardingWelcomeTitle}'),
        ],
      ),
      titleSize: 32,
      subtitle: context.loc.onboardingWelcomeDescription,
      padding: padding,
      palette: palette,
      header: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      content: const [],
      artwork: const _Artwork(asset: 'assets/onboarding/welcome.png'),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _Language extends ConsumerWidget {
  const _Language({super.key, required this.palette, required this.padding});
  final SettingsPalette palette;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appSettingsNotifierProvider).language;
    final selected =
        ref.watch(selectedLanguageIdProvider) ??
        (language == AppLanguage.ur ? 'ur' : 'en');
    return _Page(
      key: key,
      title: context.loc.selectLanguage,
      subtitle: context.loc.onboardingLanguageDescription,
      padding: padding,
      palette: palette,
      content: [
        for (final option in languageOptions) ...[
          SettingsPickerTile(
            title: option.localizedLabel(context),
            selected: option.id == selected,
            palette: palette,
            onTap: () {
              ref.read(selectedLanguageIdProvider.notifier).state = option.id;
              ref
                  .read(appSettingsNotifierProvider.notifier)
                  .setLanguage(option.effectiveLanguage);
            },
          ),
          if (option != languageOptions.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Notifications extends StatelessWidget {
  const _Notifications({
    super.key,
    required this.palette,
    required this.padding,
  });
  final SettingsPalette palette;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return _Page(
      key: key,
      title: context.loc.allowNotifications,
      subtitle: context.loc.onboardingNotificationsDescription,
      padding: padding,
      palette: palette,
      content: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.accent.withValues(alpha: 0.25)),

            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.025),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  'assets/logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.onboardingAppName,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.loc.onboardingNotificationTitle,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.loc.onboardingNotificationBody,
                      style: TextStyle(
                        color: palette.subtitle,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                TimeFormatOption.twelveHour.formatTimeWithContext(
                  context,
                  DateTime.now(),
                ),
                style: TextStyle(
                  color: palette.subtitle,
                  fontFamily: localizedFontFamily(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
      artwork: const _Artwork(asset: 'assets/onboarding/notifications.png'),
    );
  }
}

class _Location extends ConsumerWidget {
  const _Location({
    super.key,
    required this.palette,
    required this.padding,
    required this.manualExpanded,
    required this.updating,
    required this.country,
    required this.city,
    required this.onAutomatic,
    required this.onManual,
    required this.onCountry,
    required this.onCity,
  });
  final SettingsPalette palette;
  final EdgeInsets padding;
  final bool manualExpanded;
  final bool updating;
  final String? country;
  final String? city;
  final VoidCallback onAutomatic;
  final VoidCallback onManual;
  final VoidCallback onCountry;
  final VoidCallback onCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(userLocationNotifierProvider);
    return _Page(
      key: key,
      title: context.loc.location,
      subtitle: context.loc.onboardingLocationDescription,
      padding: padding,
      palette: palette,
      content: [
        LocationOptionCard(
          icon: Icons.my_location_outlined,
          title: context.loc.allowLocation,
          description: context.loc.allowLocationDescription,
          selected: location?.source == UserLocationSource.automatic,
          loading: updating && !manualExpanded,
          palette: palette,
          onTap: onAutomatic,
        ),
        const SizedBox(height: 8),
        LocationOptionCard(
          icon: CupertinoIcons.location_slash,
          title: context.loc.manualLocation,
          description: context.loc.manualLocationDescription,
          selected: location?.source == UserLocationSource.manual,
          palette: palette,
          onTap: onManual,
          expandedContent: manualExpanded
              ? ManualLocationSelector(
                  country: country,
                  city: city,
                  loading: updating,
                  onSelectedSurface:
                      location?.source == UserLocationSource.manual,
                  palette: palette,
                  title: context.loc.selectLocation,
                  countryPlaceholder: context.loc.selectCountry,
                  cityPlaceholder: context.loc.selectCity,
                  onCountryTap: onCountry,
                  onCityTap: onCity,
                )
              : null,
        ),
      ],
      artwork: const _Artwork(asset: 'assets/onboarding/location.png'),
    );
  }
}

class _Juristic extends ConsumerWidget {
  const _Juristic({super.key, required this.palette, required this.padding});
  final SettingsPalette palette;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref
        .watch(prayerTimesSettingsNotifierProvider)
        .asrCalculationMethod;
    return _Page(
      key: key,
      title: context.loc.juristicMethod,
      subtitle: context.loc.onboardingJuristicDescription,
      padding: padding,
      palette: palette,
      content: [
        for (final method in AsrCalculationMethod.values) ...[
          SettingsPickerTile(
            title: method.getLabel(context),
            selected: selected == method,
            palette: palette,
            onTap: () => ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .setAsrCalculationMethod(method),
          ),
          if (method != AsrCalculationMethod.values.last)
            const SizedBox(height: 8),
        ],
      ],
      artwork: const _Artwork(asset: 'assets/onboarding/juristic.png'),
    );
  }
}

class _Theme extends ConsumerWidget {
  const _Theme({super.key, required this.palette, required this.padding});
  final SettingsPalette palette;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsNotifierProvider).themeMode;
    const modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    return _Page(
      key: key,
      title: context.loc.theme,
      subtitle: context.loc.onboardingThemeDescription,
      padding: padding,
      palette: palette,
      content: [
        for (final mode in modes) ...[
          ThemePickerTile(
            mode: mode,
            title: themeModeLabel(context, mode),
            selected: selected == mode,
            palette: palette,
            onTap: () => ref
                .read(appSettingsNotifierProvider.notifier)
                .setThemeMode(mode),
          ),
          if (mode != modes.last) const SizedBox(height: 8),
        ],
      ],
      artwork: const _Artwork(asset: 'assets/onboarding/theme.png'),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.step,
    required this.nextIsLoading,
    required this.palette,
    required this.onBack,
    required this.onNext,
  });
  final _OnboardingStep step;
  final bool nextIsLoading;
  final SettingsPalette palette;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final first = step == _OnboardingStep.welcome;
    final last = step == _OnboardingStep.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: _actionsVerticalPadding,
              ),
              child: Row(
                children: [
                  if (!first) ...[
                    Expanded(
                      child: SizedBox(
                        height: _actionButtonHeight,
                        child: OutlinedButton(
                          onPressed: nextIsLoading ? null : onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.title,
                            side: BorderSide(color: palette.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.loc.back,
                            style: TextStyle(
                              fontFamily: localizedFontFamily(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: _actionButtonHeight,
                      child: FilledButton(
                        onPressed: nextIsLoading ? null : onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.accent,
                          foregroundColor: palette.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: nextIsLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.background,
                                ),
                              )
                            : Text(
                                first
                                    ? context.loc.getStarted
                                    : last
                                    ? context.loc.finish
                                    : context.loc.next,
                                style: TextStyle(
                                  fontFamily: localizedFontFamily(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
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
}
