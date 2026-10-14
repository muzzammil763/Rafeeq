import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/app_home_screen.dart';
import 'package:rafeeq/ui/app_home/home/home_prayer_data.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/app_home/home/settings_sheets.dart' show playStoreUri;
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/utils/hijri_date_formatter.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:share_plus/share_plus.dart';

export 'package:rafeeq/ui/app_home/home/settings_picker.dart'
    show HomeLocationAction;

const _timePlaceholder = '--:-- --';
const _ayahPictureOpenedKey = 'ayah_picture_opened_v1';

final _showAyahPictureNewBadgeProvider = Provider<bool>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return !(preferences.getBool(_ayahPictureOpenedKey) ?? false);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final palette = SettingsPalette.of(context);
    final location = ref.watch(userLocationNotifierProvider);
    final correctedDate = ref.watch(correctedDateTimeProvider);
    final hijriDate = HijriCalendar.fromDate(correctedDate);
    final timeFormat = ref.watch(
      prayerTimesSettingsNotifierProvider.select((value) => value.timeFormat),
    );
    final showAllCards = ref.watch(
      appSettingsNotifierProvider.select((value) => value.showAllCards),
    );
    final now = DateTime.now();
    final isFriday = now.weekday == DateTime.friday;
    final isRamadan = hijriDate.hMonth == 9;
    final eidType = switch ((hijriDate.hMonth, hijriDate.hDay)) {
      (10, 1) => _HomeEidType.fitr,
      (12, 10) => _HomeEidType.adha,
      _ => _HomeEidType.none,
    };

    _HomePrayerSnapshot? prayerSnapshot;
    if (location != null) {
      final today = ref.watch(prayerTimesProvider(location));
      final yesterday = ref.watch(
        prayerTimesForDateProvider((
          location,
          now.subtract(const Duration(days: 1)),
        )),
      );
      final tomorrow = ref.watch(
        prayerTimesForDateProvider((
          location,
          now.add(const Duration(days: 1)),
        )),
      );
      prayerSnapshot = _HomePrayerSnapshot.fromPrayerTimes(
        now: now,
        yesterday: yesterday,
        today: today,
        tomorrow: tomorrow,
      );
    }

    String formatTime(DateTime? value) {
      return value == null
          ? '--:-- --'
          : timeFormat.formatTimeWithContext(context, value);
    }

    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return Scaffold(
      appBar: RafeeqAppBar(
        title: context.loc.appTitle,
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUrdu)
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/logo.png',
                  key: const Key('home-app-logo'),
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              )
            else
              SizedBox.shrink(),
            const SizedBox(width: 8),
            if (isUrdu)
              SvgPicture.asset(
                'assets/calligraphy.svg',
                key: const Key('home-calligraphy'),
                width: 64,
                height: 40,
                fit: BoxFit.contain,
                semanticsLabel: context.loc.appTitle,
                colorFilter: ColorFilter.mode(
                  palette.selectedCard,
                  BlendMode.srcIn,
                ),
              )
            else
              Text(
                context.loc.appTitle,
                key: const Key('home-english-title'),
                style: TextStyle(
                  color: palette.title,
                  fontFamily: localizedFontFamily(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        palette: palette,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Center(
              child: HomeLocationAction(
                location: _locationLabel(context, location),
                palette: palette,
                onTap: () => _openLocation(context),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: palette.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  navigationScreenPlayerAwareBottomPadding(
                    playerVisible: playerVisible,
                  ),
                ),
                children: [
                  _TodayDates(
                    hijriDate: HijriDateFormatter.formatLong(
                      context,
                      hijriDate,
                    ),
                    today: now,
                    palette: palette,
                  ),
                  const SizedBox(height: 16),
                  HomeFocusCardCarousel(
                    cards: [
                      HomePrayerFocusCard(
                        previousPrayer: prayerSnapshot == null
                            ? context.loc.prayerNone
                            : _prayerName(
                                context,
                                prayerSnapshot.previousPrayer,
                              ),
                        previousTime: formatTime(
                          prayerSnapshot?.previousPrayerTime,
                        ),
                        nextPrayer: prayerSnapshot == null
                            ? context.loc.prayerNone
                            : _prayerName(context, prayerSnapshot.nextPrayer),
                        nextTime: formatTime(prayerSnapshot?.nextPrayerTime),
                        countdown: _formatDuration(
                          prayerSnapshot?.nextPrayerTime.difference(now),
                        ),
                        progress: prayerSnapshot?.progress ?? 0,
                        palette: palette,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.prayerTimes),
                      ),
                      if (showAllCards || isFriday)
                        _HomeSpecialEventCard.friday(
                          context: context,
                          palette: palette,
                          onTap: () =>
                              ref
                                      .read(
                                        homeNavigationIndexProvider.notifier,
                                      )
                                      .state =
                                  1,
                        ),
                      if (showAllCards || isRamadan)
                        _HomeSpecialEventCard.ramadan(
                          context: context,
                          palette: palette,
                          day: hijriDate.hDay,
                          suhoorTime: formatTime(
                            prayerSnapshot?.today.fajr.subtract(
                              const Duration(minutes: 1),
                            ),
                          ),
                          iftarTime: formatTime(prayerSnapshot?.today.maghrib),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.ramadanCalendar),
                        ),
                      if (showAllCards || eidType != _HomeEidType.none)
                        _HomeSpecialEventCard.eid(
                          context: context,
                          palette: palette,
                          type: eidType == _HomeEidType.none
                              ? _HomeEidType.fitr
                              : eidType,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.prayerTimes),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: context.loc.homeExplore,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),
                  _ExploreGrid(palette: palette),
                  const SizedBox(height: 24),
                  _SectionTitle(title: context.loc.homeToday, palette: palette),
                  const SizedBox(height: 12),
                  HomePrayerTimeline(
                    prayers: [
                      HomePrayerTimelineItem(
                        label: context.loc.prayerFajr,
                        time: formatTime(prayerSnapshot?.today.fajr),
                        active: prayerSnapshot?.previousPrayer == Prayer.fajr,
                      ),
                      HomePrayerTimelineItem(
                        label: context.loc.prayerDhuhr,
                        time: formatTime(prayerSnapshot?.today.dhuhr),
                        active: prayerSnapshot?.previousPrayer == Prayer.dhuhr,
                      ),
                      HomePrayerTimelineItem(
                        label: context.loc.prayerAsr,
                        time: formatTime(prayerSnapshot?.today.asr),
                        active: prayerSnapshot?.previousPrayer == Prayer.asr,
                      ),
                      HomePrayerTimelineItem(
                        label: context.loc.prayerMaghrib,
                        time: formatTime(prayerSnapshot?.today.maghrib),
                        active:
                            prayerSnapshot?.previousPrayer == Prayer.maghrib,
                      ),
                      HomePrayerTimelineItem(
                        label: context.loc.prayerIsha,
                        time: formatTime(prayerSnapshot?.today.isha),
                        active: prayerSnapshot?.previousPrayer == Prayer.isha,
                      ),
                    ],
                    palette: palette,
                    onPrayerTap: (_) =>
                        Navigator.of(context).pushNamed(AppRoutes.prayerTimes),
                  ),
                  const SizedBox(height: 8),
                  _NightPrayerCards(
                    suhurLabel: context.loc.homeSuhurEnd,
                    suhurTime: formatTime(
                      prayerSnapshot?.today.fajr.subtract(
                        const Duration(minutes: 1),
                      ),
                    ),
                    iftarLabel: context.loc.iftar,
                    iftarTime: formatTime(prayerSnapshot?.today.maghrib),
                    tahajjudLabel: context.loc.homeTahajjud,
                    tahajjudTime: formatTime(prayerSnapshot?.tahajjudStart),
                    palette: palette,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.prayerTimes),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: context.loc.homeForbiddenSalatTimes,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),
                  ForbiddenPrayerTimesCard(
                    palette: palette,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.prayerTimes),
                    windows: [
                      ForbiddenPrayerWindow(
                        label: context.loc.prayerSunrise,
                        start: formatTime(prayerSnapshot?.today.sunrise),
                        end: formatTime(
                          prayerSnapshot?.today.sunrise.add(
                            const Duration(minutes: 15),
                          ),
                        ),
                        imageAsset:
                            'assets/home/forbidden-sunrise-placeholder.png',
                      ),
                      ForbiddenPrayerWindow(
                        label: context.loc.homeNoon,
                        start: formatTime(
                          prayerSnapshot?.today.dhuhr.subtract(
                            const Duration(minutes: 10),
                          ),
                        ),
                        end: formatTime(prayerSnapshot?.today.dhuhr),
                        imageAsset:
                            'assets/home/forbidden-noon-placeholder.png',
                      ),
                      ForbiddenPrayerWindow(
                        label: context.loc.homeSunset,
                        start: formatTime(
                          prayerSnapshot?.today.maghrib.subtract(
                            const Duration(minutes: 15),
                          ),
                        ),
                        end: formatTime(prayerSnapshot?.today.maghrib),
                        imageAsset:
                            'assets/home/forbidden-sunset-placeholder.png',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: context.loc.homeShareRafeeq,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),
                  _SharingCard(palette: palette),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openLocation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: AnalyticsScreenNames.location),
        builder: (context) => const LocationScreen(),
      ),
    );
  }
}

class _TodayDates extends StatelessWidget {
  const _TodayDates({
    required this.hijriDate,
    required this.today,
    required this.palette,
  });

  final String hijriDate;
  final DateTime today;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final fontFamily = localizedFontFamily(context);
    final gregorianDate =
        '${today.day.toLocalizedNumber(context)} '
        '${DateFormat.MMMM(languageCode).format(today)}, '
        '${today.year.toLocalizedNumber(context)}';
    final weekday = DateFormat.EEEE(languageCode).format(today);
    TextStyle secondary() => TextStyle(
      color: palette.subtitle,
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    return Column(
      key: const Key('home-today-dates'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hijriDate,
          style: TextStyle(
            color: palette.title,
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(gregorianDate, style: secondary()),
        const SizedBox(height: 2),
        Text(weekday, style: secondary()),
      ],
    );
  }
}

class HomePrayerFocusCard extends StatelessWidget {
  const HomePrayerFocusCard({
    super.key,
    required this.previousPrayer,
    required this.previousTime,
    required this.nextPrayer,
    required this.nextTime,
    required this.countdown,
    required this.progress,
    required this.palette,
    required this.onTap,
  });

  final String previousPrayer;
  final String previousTime;
  final String nextPrayer;
  final String nextTime;
  final String countdown;
  final double progress;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final background = isLight
        ? const Color(0xFFC8EDF7)
        : const Color(0xFF193438);
    final line = isLight ? const Color(0xFF9CCFDB) : const Color(0xFF34565A);

    return Semantics(
      button: true,
      label: '$previousPrayer, $nextPrayer',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 176,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      key: const Key('home-prayer-focus-image'),
                      'assets/home/prayer-focus-placeholder.png',
                      width: 210,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PrayerFocusLabel(
                            time: previousTime,
                            prayer: previousPrayer,
                            palette: palette,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0, 1),
                                  minHeight: 6,
                                  backgroundColor: line,
                                  color: palette.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _PrayerFocusLabel(
                            time: nextTime,
                            prayer: nextPrayer,
                            palette: palette,
                            alignEnd: true,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          countdown,
                          key: const Key('home-prayer-focus-countdown'),
                          style: TextStyle(
                            color: palette.title,
                            fontFamily: localizedFontFamily(context),
                            fontSize: 28,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeFocusCardCarousel extends StatefulWidget {
  const HomeFocusCardCarousel({
    super.key,
    required this.cards,
    this.autoAdvanceDelay = const Duration(seconds: 5),
  });

  final List<Widget> cards;
  final Duration autoAdvanceDelay;

  @override
  State<HomeFocusCardCarousel> createState() => _HomeFocusCardCarouselState();
}

class _HomeFocusCardCarouselState extends State<HomeFocusCardCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant HomeFocusCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length == widget.cards.length &&
        oldWidget.autoAdvanceDelay == widget.autoAdvanceDelay) {
      return;
    }

    _autoAdvanceTimer?.cancel();
    if (_currentPage >= widget.cards.length) {
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    if (widget.cards.length < 2) return;
    _autoAdvanceTimer = Timer.periodic(widget.autoAdvanceDelay, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.cards.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.cards.isNotEmpty);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 176,
          child: PageView.builder(
            key: const Key('home-focus-carousel'),
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) => Semantics(
              label: '${index + 1} of ${widget.cards.length}',
              child: widget.cards[index],
            ),
          ),
        ),
        if (widget.cards.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.cards.length, (index) {
              final selected = index == _currentPage;
              return AnimatedContainer(
                key: Key('home-focus-page-indicator-$index'),
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: selected ? 18 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: selected
                      ? SettingsPalette.of(context).accent
                      : SettingsPalette.of(
                          context,
                        ).subtitle.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

enum _HomeEidType { fitr, adha, none }

class _HomeSpecialEventCard extends StatelessWidget {
  const _HomeSpecialEventCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lightBackground,
    required this.darkBackground,
    required this.metrics,
    required this.palette,
    required this.onTap,
  });

  factory _HomeSpecialEventCard.friday({
    required BuildContext context,
    required SettingsPalette palette,
    required VoidCallback onTap,
  }) {
    return _HomeSpecialEventCard(
      key: const Key('home-friday-card'),
      eyebrow: context.loc.fridayCard,
      title: context.loc.fridayMubarak,
      subtitle: context.loc.fridaySunnahs,
      icon: Icons.mosque_outlined,
      lightBackground: const Color(0xFFD7EFE4),
      darkBackground: const Color(0xFF18342C),
      metrics: [
        _HomeEventMetricData(
          label: context.loc.event,
          value: context.loc.sunnahGhusl,
        ),
        _HomeEventMetricData(
          label: context.loc.surah,
          value: context.loc.readSurahKahf,
        ),
      ],
      palette: palette,
      onTap: onTap,
    );
  }

  factory _HomeSpecialEventCard.ramadan({
    required BuildContext context,
    required SettingsPalette palette,
    required int day,
    required String suhoorTime,
    required String iftarTime,
    required VoidCallback onTap,
  }) {
    return _HomeSpecialEventCard(
      key: const Key('home-ramadan-card'),
      eyebrow: '${context.loc.ramadanCard} · $day',
      title: context.loc.ramadanMubarak,
      subtitle: context.loc.ramadanCardSubtitle,
      icon: FlutterIslamicIcons.crescentMoon,
      lightBackground: const Color(0xFFE9E0F5),
      darkBackground: const Color(0xFF302641),
      metrics: [
        _HomeEventMetricData(label: context.loc.suhoor, value: suhoorTime),
        _HomeEventMetricData(label: context.loc.iftar, value: iftarTime),
      ],
      palette: palette,
      onTap: onTap,
    );
  }

  factory _HomeSpecialEventCard.eid({
    required BuildContext context,
    required SettingsPalette palette,
    required _HomeEidType type,
    required VoidCallback onTap,
  }) {
    final isFitr = type == _HomeEidType.fitr;
    return _HomeSpecialEventCard(
      key: const Key('home-eid-card'),
      eyebrow: context.loc.eidCard,
      title: isFitr
          ? context.loc.eidUlFitrGreeting
          : context.loc.eidUlAdhaGreeting,
      subtitle: isFitr
          ? context.loc.prayEidUlFitrToday
          : context.loc.prayEidUlAdhaToday,
      icon: Icons.celebration_outlined,
      lightBackground: const Color(0xFFF5E6BD),
      darkBackground: const Color(0xFF3B3020),
      metrics: [
        _HomeEventMetricData(
          label: context.loc.eidDay,
          value: isFitr ? context.loc.oneShawwal : context.loc.tenDhulHijjah,
        ),
        _HomeEventMetricData(
          label: context.loc.event,
          value: isFitr ? context.loc.eidUlFitr : context.loc.eidUlAdha,
        ),
      ],
      palette: palette,
      onTap: onTap,
    );
  }

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color lightBackground;
  final Color darkBackground;
  final List<_HomeEventMetricData> metrics;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final background = isLight ? lightBackground : darkBackground;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 176,
            child: Stack(
              children: [
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: isLight ? 0.62 : 0.35,
                    child: Image.asset(
                      'assets/home/prayer-focus-placeholder.png',
                      width: 210,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 18,
                  top: 14,
                  child: Icon(
                    icon,
                    size: 31,
                    color: palette.title.withValues(alpha: 0.45),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 15, color: palette.accent),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              eyebrow,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.subtitle,
                                fontFamily: localizedFontFamily(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      FractionallySizedBox(
                        widthFactor: 0.76,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.title,
                            fontFamily: localizedFontFamily(context),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FractionallySizedBox(
                        widthFactor: 0.76,
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.subtitle,
                            fontFamily: localizedFontFamily(context),
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          for (
                            var index = 0;
                            index < metrics.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _HomeEventMetric(
                                data: metrics[index],
                                palette: palette,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeEventMetricData {
  const _HomeEventMetricData({required this.label, required this.value});

  final String label;
  final String value;
}

class _HomeEventMetric extends StatelessWidget {
  const _HomeEventMetric({required this.data, required this.palette});

  final _HomeEventMetricData data;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: localizedFontFamily(context),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.title,
                fontFamily: localizedFontFamily(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerFocusLabel extends StatelessWidget {
  const _PrayerFocusLabel({
    required this.time,
    required this.prayer,
    required this.palette,
    this.alignEnd = false,
  });

  final String time;
  final String prayer;
  final SettingsPalette palette;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          prayer,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.palette});

  final String title;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: palette.subtitle,
        fontFamily: localizedFontFamily(context),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ExploreGrid extends ConsumerWidget {
  const _ExploreGrid({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAyahPictureNewBadge = ref.watch(_showAyahPictureNewBadgeProvider);
    final items = [
      _ExploreItem(
        label: context.loc.quran,
        icon: FlutterIslamicIcons.solidQuran2,
        onTap: () => ref.read(homeNavigationIndexProvider.notifier).state = 1,
      ),
      // Hidden until the Dua & Zikr experience is ready for users.
      // _ExploreItem(
      //   label: context.loc.homeDuaAndZikr,
      //   icon: FlutterIslamicIcons.solidPrayingPerson,
      //   onTap: () => _showComingSoon(context),
      // ),
      _ExploreItem(
        label: context.loc.dailyPrayerLabel,
        icon: Icons.menu_book_rounded,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.namazPrayer),
      ),
      _ExploreItem(
        label: context.loc.qibla,
        icon: FlutterIslamicIcons.solidKaaba,
        onTap: () => ref.read(homeNavigationIndexProvider.notifier).state = 2,
      ),
      // Hidden until the Mosques experience is ready for users.
      // _ExploreItem(
      //   label: context.loc.homeMosques,
      //   icon: FlutterIslamicIcons.solidMosque,
      //   onTap: () => _showComingSoon(context),
      // ),
      _ExploreItem(
        label: context.loc.homeCalendar,
        icon: FlutterIslamicIcons.calendar,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.hijriCalendar),
      ),
      _ExploreItem(
        label: context.loc.homeAllahsNames,
        icon: FlutterIslamicIcons.solidAllah,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.asmaulHusna),
      ),
      _ExploreItem(
        label: context.loc.homeAyahPicture,
        icon: CupertinoIcons.photo_on_rectangle,
        badge: showAyahPictureNewBadge ? 'NEW' : null,
        onTap: () async {
          await ref
              .read(sharedPreferencesProvider)
              .setBool(_ayahPictureOpenedKey, true);
          ref.invalidate(_showAyahPictureNewBadgeProvider);
          if (!context.mounted) return;
          await Navigator.of(context).pushNamed(AppRoutes.ayahPictureMaker);
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = constraints.maxWidth < 360 ? 1.2 : 1.18;
        return GridView.builder(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) =>
              _ExploreCard(item: items[index], palette: palette),
        );
      },
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item, required this.palette});

  final _ExploreItem item;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey('explore-card-${item.label}'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Material(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: item.badge == null ? 0 : 28,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.title,
                            fontFamily: localizedFontFamily(context),
                            fontSize: 13,
                            height: 1.15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Icon(
                        item.icon,
                        color: palette.selectedCard,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (item.badge case final badge?)
          Positioned(
            top: -4,
            right: -4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                  maxHeight: 20,
                  maxWidth: 32,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'GoogleSans',
                        fontSize: 10,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HomePrayerTimelineItem {
  const HomePrayerTimelineItem({
    required this.label,
    required this.time,
    required this.active,
  });

  final String label;
  final String time;
  final bool active;
}

class HomePrayerTimeline extends StatelessWidget {
  const HomePrayerTimeline({
    super.key,
    required this.prayers,
    required this.palette,
    this.onPrayerTap,
  });

  final List<HomePrayerTimelineItem> prayers;
  final SettingsPalette palette;
  final ValueChanged<int>? onPrayerTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPrayerTap == null
          ? null
          : () => onPrayerTap!(prayers.indexWhere((p) => p.active)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PositionedDirectional(
                      start: 28,
                      end: 28,
                      child: Container(height: 2, color: palette.selectedCard),
                    ),
                    Row(
                      children: [
                        for (var index = 0; index < prayers.length; index++)
                          Expanded(
                            child: GestureDetector(
                              onTap: onPrayerTap == null
                                  ? null
                                  : () => onPrayerTap!(index),
                              child: Center(
                                child: Container(
                                  width: prayers[index].active ? 24 : 12,
                                  height: prayers[index].active ? 24 : 12,
                                  decoration: BoxDecoration(
                                    color: prayers[index].active
                                        ? palette.accent
                                        : palette.selectedCard,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < prayers.length; index++)
                    Expanded(
                      child: GestureDetector(
                        onTap: onPrayerTap == null
                            ? null
                            : () => onPrayerTap!(index),
                        child: Column(
                          children: [
                            Text(
                              prayers[index].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.subtitle,
                                fontFamily: localizedFontFamily(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                prayers[index].time,
                                style: TextStyle(
                                  color: palette.title,
                                  fontFamily: localizedFontFamily(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NightPrayerCards extends StatelessWidget {
  const _NightPrayerCards({
    required this.suhurLabel,
    required this.suhurTime,
    required this.iftarLabel,
    required this.iftarTime,
    required this.tahajjudLabel,
    required this.tahajjudTime,
    required this.palette,
    this.onTap,
  });

  final String suhurLabel;
  final String suhurTime;
  final String iftarLabel;
  final String iftarTime;
  final String tahajjudLabel;
  final String tahajjudTime;
  final SettingsPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeFeatureCard(
            icon: Icons.wb_twilight_outlined,
            label: suhurLabel,
            time: suhurTime,
            palette: palette,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TimeFeatureCard(
            icon: Icons.wb_sunny_outlined,
            label: iftarLabel,
            time: iftarTime,
            palette: palette,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TimeFeatureCard(
            icon: Icons.nightlight_outlined,
            label: tahajjudLabel,
            time: tahajjudTime,
            palette: palette,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _TimeFeatureCard extends StatelessWidget {
  const _TimeFeatureCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.palette,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String time;
  final SettingsPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: palette.accent, size: 25),
                const SizedBox(height: 16),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.subtitle,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: palette.title,
                      fontFamily: localizedFontFamily(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForbiddenPrayerWindow {
  const ForbiddenPrayerWindow({
    required this.label,
    this.start,
    this.end,
    required this.imageAsset,
  });

  final String label;
  final String? start;
  final String? end;
  final String imageAsset;
}

class ForbiddenPrayerTimesCard extends StatelessWidget {
  const ForbiddenPrayerTimesCard({
    super.key,
    required this.windows,
    required this.palette,
    this.onTap,
  });

  final List<ForbiddenPrayerWindow> windows;
  final SettingsPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < windows.length; index++) ...[
          ForbiddenPrayerTimeCard(
            window: windows[index],
            palette: palette,
            onTap: onTap,
          ),
          if (index != windows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ForbiddenPrayerTimeCard extends StatelessWidget {
  const ForbiddenPrayerTimeCard({
    super.key,
    required this.window,
    required this.palette,
    this.onTap,
  });

  final ForbiddenPrayerWindow window;
  final SettingsPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.background,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: palette.selectedCard.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                const SizedBox(width: 1),
                ClipRRect(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    start: Radius.circular(10),
                  ),
                  child: ColoredBox(
                    color: palette.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        window.imageAsset,
                        width: 96,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        window.label,
                        style: TextStyle(
                          color: palette.subtitle,
                          fontFamily: localizedFontFamily(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                window.start ?? _timePlaceholder,
                                style: TextStyle(
                                  color: palette.title,
                                  fontFamily: localizedFontFamily(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Divider(color: palette.selectedCard)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                window.end ?? _timePlaceholder,
                                style: TextStyle(
                                  color: palette.title,
                                  fontFamily: localizedFontFamily(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharingCard extends StatelessWidget {
  const _SharingCard({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.loc.homeAdFreeMessage,
              style: TextStyle(
                color: palette.accent,
                fontFamily: localizedFontFamily(context),
                fontSize: 17,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.homeHadithText,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 16,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.loc.homeHadithSource,
                  style: TextStyle(
                    color: palette.subtitle,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      '${context.loc.homeHadithText}\n\n'
                      '${context.loc.homeHadithSource}\n\n'
                      '${context.loc.shareThisApp}: $playStoreUri',
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.checkForeground,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.loc.homeShareNow,
                style: TextStyle(
                  fontFamily: localizedFontFamily(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePrayerSnapshot {
  const _HomePrayerSnapshot({
    required this.today,
    required this.previousPrayer,
    required this.previousPrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.progress,
    required this.tahajjudStart,
  });

  final PrayerTimes today;
  final Prayer previousPrayer;
  final DateTime previousPrayerTime;
  final Prayer nextPrayer;
  final DateTime nextPrayerTime;
  final double progress;
  final DateTime tahajjudStart;

  factory _HomePrayerSnapshot.fromPrayerTimes({
    required DateTime now,
    required PrayerTimes yesterday,
    required PrayerTimes today,
    required PrayerTimes tomorrow,
  }) {
    final prayers = <(Prayer, DateTime)>[
      (Prayer.fajr, today.fajr),
      (Prayer.dhuhr, today.dhuhr),
      (Prayer.asr, today.asr),
      (Prayer.maghrib, today.maghrib),
      (Prayer.isha, today.isha),
    ];

    var previous = (Prayer.isha, yesterday.isha);
    var next = prayers.first;
    for (final prayer in prayers) {
      if (!prayer.$2.isAfter(now)) {
        previous = prayer;
      } else {
        next = prayer;
        break;
      }
    }
    if (!now.isBefore(today.isha)) {
      previous = (Prayer.isha, today.isha);
      next = (Prayer.fajr, tomorrow.fajr);
    }

    final interval = next.$2.difference(previous.$2).inMilliseconds;
    final elapsed = now.difference(previous.$2).inMilliseconds;
    final progress = interval <= 0 ? 0.0 : (elapsed / interval).clamp(0.0, 1.0);
    final night = tomorrow.fajr.difference(today.maghrib);
    final tahajjudStart = today.maghrib.add(
      Duration(milliseconds: (night.inMilliseconds * 2 / 3).round()),
    );

    return _HomePrayerSnapshot(
      today: today,
      previousPrayer: previous.$1,
      previousPrayerTime: previous.$2,
      nextPrayer: next.$1,
      nextPrayerTime: next.$2,
      progress: progress,
      tahajjudStart: tahajjudStart,
    );
  }
}

String _locationLabel(BuildContext context, UserLocation? location) {
  return location?.city ?? location?.country ?? context.loc.locationNotSet;
}

String _prayerName(BuildContext context, Prayer prayer) {
  return switch (prayer) {
    Prayer.fajr => context.loc.prayerFajr,
    Prayer.sunrise => context.loc.prayerSunrise,
    Prayer.dhuhr =>
      DateTime.now().weekday == DateTime.friday
          ? context.loc.prayerJumma
          : context.loc.prayerDhuhr,
    Prayer.asr => context.loc.prayerAsr,
    Prayer.maghrib => context.loc.prayerMaghrib,
    Prayer.isha => context.loc.prayerIsha,
    Prayer.none => context.loc.prayerNone,
  };
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '--:--:--';
  final safe = duration.isNegative ? Duration.zero : duration;
  final hours = safe.inHours.toString().padLeft(2, '0');
  final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

@Preview(name: 'Home prayer sections', group: 'Home', size: Size(390, 760))
Widget homePrayerSectionsPreview() {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
    home: Builder(
      builder: (context) {
        final palette = SettingsPalette.of(context);
        return Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                HomePrayerFocusCard(
                  previousPrayer: 'Dhuhr',
                  previousTime: '12:08 PM',
                  nextPrayer: 'Asr',
                  nextTime: '04:47 PM',
                  countdown: '04:17:07',
                  progress: 0.16,
                  palette: palette,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Forbidden Salat Times', palette: palette),
                const SizedBox(height: 12),
                ForbiddenPrayerTimesCard(
                  palette: palette,
                  windows: const [
                    ForbiddenPrayerWindow(
                      label: 'Sunrise',
                      imageAsset:
                          'assets/home/forbidden-sunrise-placeholder.png',
                    ),
                    ForbiddenPrayerWindow(
                      label: 'Noon',
                      imageAsset: 'assets/home/forbidden-noon-placeholder.png',
                    ),
                    ForbiddenPrayerWindow(
                      label: 'Sunset',
                      imageAsset:
                          'assets/home/forbidden-sunset-placeholder.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
