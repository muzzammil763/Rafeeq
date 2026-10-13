import 'dart:ui';

import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/home_prayer_data.dart';
import 'package:rafeeq/ui/app_home/home/location_screen.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/utils/localized_font.dart';

class PrayerTimesScreen extends HookConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final location = ref.watch(userLocationNotifierProvider);
    final today = DateTime.now();
    final selectedDate = useState(today);
    useScrollController();
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );

    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(
        title: context.loc.prayerTimes,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
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
            children: [
              if (location == null)
                _NoLocationPlaceholder(
                  palette: palette,
                  onGrantPermission: () => _openLocation(context),
                )
              else
                _PrayerTimesContent(
                  location: location,
                  selectedDate: selectedDate.value,
                  palette: palette,
                ),
            ],
          ),
        ),
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

String _locationLabel(BuildContext context, UserLocation? location) {
  if (location == null) return context.loc.locationNotSet;
  final parts = [
    location.city,
  ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
  return parts.isEmpty ? context.loc.locationNotSet : parts.join(', ');
}

class _NoLocationPlaceholder extends StatelessWidget {
  const _NoLocationPlaceholder({
    required this.palette,
    required this.onGrantPermission,
  });

  final SettingsPalette palette;
  final VoidCallback onGrantPermission;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.location_off_outlined, color: palette.accent, size: 38),
            const SizedBox(height: 12),
            Text(
              context.loc.locationRequiredTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.title,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.loc.locationRequiredDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.subtitle,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onGrantPermission,
                icon: const Icon(CupertinoIcons.location),
                label: Text(context.loc.grantLocationPermission),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimesContent extends ConsumerWidget {
  const _PrayerTimesContent({
    required this.location,
    required this.selectedDate,
    required this.palette,
  });

  final UserLocation location;
  final DateTime selectedDate;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final times = ref.watch(
      prayerTimesForDateProvider((location, selectedDate)),
    );
    final nextTimes = ref.watch(
      prayerTimesForDateProvider((
        location,
        selectedDate.add(const Duration(days: 1)),
      )),
    );
    final settings = ref.watch(prayerTimesSettingsNotifierProvider);
    final activePrayer = _isToday(selectedDate)
        ? _activePrayer(times, nextTimes)
        : null;
    final prayerItems = _prayerItems(context, times, nextTimes, selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(title: context.loc.prayerTimes, palette: palette),
        const SizedBox(height: 8),
        for (final item in prayerItems) ...[
          _PrayerTimeCard(
            item: item,
            active: item.prayer == activePrayer,
            palette: palette,
            onNotificationTap: item.notifKey == null
                ? null
                : () => showPrayerNotificationEditorScreen(
                    context,
                    item.notifKey!,
                    item.name,
                  ),
          ),
          const SizedBox(height: 8),
        ],
        _SectionLabel(
          title: context.loc.homeForbiddenSalatTimes,
          palette: palette,
        ),
        const SizedBox(height: 8),
        _ForbiddenTimesSection(
          times: times,
          format: settings.timeFormat,
          palette: palette,
          onTap: (item) => _showForbiddenDialog(context, item),
        ),
        const SizedBox(height: 16),
        _SectionLabel(title: context.loc.suhoor, palette: palette),
        const SizedBox(height: 8),
        _NightTimesSection(
          times: times,
          nextTimes: nextTimes,
          format: settings.timeFormat,
          palette: palette,
          context: context,
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  Prayer? _activePrayer(PrayerTimes times, PrayerTimes nextTimes) {
    final now = DateTime.now();
    final ranges = [
      (Prayer.fajr, times.fajr, times.dhuhr),
      (Prayer.dhuhr, times.dhuhr, times.asr),
      (Prayer.asr, times.asr, times.maghrib),
      (Prayer.maghrib, times.maghrib, times.isha),
      (Prayer.isha, times.isha, nextTimes.fajr),
    ];
    for (final range in ranges) {
      if (!now.isBefore(range.$2) && now.isBefore(range.$3)) return range.$1;
    }
    return null;
  }

  List<_PrayerRowData> _prayerItems(
    BuildContext context,
    PrayerTimes times,
    PrayerTimes nextTimes,
    DateTime date,
  ) {
    final isFriday = date.weekday == DateTime.friday;
    final result = [
      _PrayerRowData(
        Prayer.fajr,
        context.loc.prayerFajr,
        times.fajr,
        times.dhuhr,
        PrayerNotifKey.fajr,
        Icons.wb_twilight_outlined,
      ),
      _PrayerRowData(
        Prayer.dhuhr,
        isFriday ? context.loc.prayerJumma : context.loc.prayerDhuhr,
        times.dhuhr,
        times.asr,
        PrayerNotifKey.dhuhr,
        Icons.wb_sunny_outlined,
      ),
      _PrayerRowData(
        Prayer.asr,
        context.loc.prayerAsr,
        times.asr,
        times.maghrib,
        PrayerNotifKey.asr,
        Icons.wb_cloudy_outlined,
      ),
      _PrayerRowData(
        Prayer.maghrib,
        context.loc.prayerMaghrib,
        times.maghrib,
        times.isha,
        PrayerNotifKey.maghrib,
        Icons.wb_twilight_outlined,
      ),
      _PrayerRowData(
        Prayer.isha,
        context.loc.prayerIsha,
        times.isha,
        nextTimes.fajr,
        PrayerNotifKey.isha,
        Icons.nightlight_outlined,
      ),
    ];
    final hijri = HijriCalendar.fromDate(date);
    final showEid =
        (hijri.hMonth == 9 && (hijri.hDay == 29 || hijri.hDay == 30)) ||
        (hijri.hMonth == 10 && hijri.hDay == 1);
    if (showEid) {
      final eid = times.sunrise.add(const Duration(minutes: 30));
      result.add(
        _PrayerRowData(
          Prayer.none,
          context.loc.eidPrayer,
          eid,
          eid.add(const Duration(minutes: 45)),
          PrayerNotifKey.eid,
          Icons.mosque_outlined,
        ),
      );
    }
    return result;
  }

  void _showForbiddenDialog(BuildContext context, _ForbiddenRowData item) {
    final palette = SettingsPalette.of(context);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: SizedBox.expand(
          child: Center(
            child: AlertDialog(
              backgroundColor: palette.card,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(item.icon, color: palette.accent, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaQuery.withNoTextScaling(
                    child: Text(
                      '${item.start} – ${item.end}',
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: 'GoogleSans',
                        fontSize: 16,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Avoid voluntary prayer during this interval.',
                    style: TextStyle(
                      color: palette.subtitle,
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(context.loc.cancel),
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

class _PrayerRowData {
  const _PrayerRowData(
    this.prayer,
    this.name,
    this.start,
    this.end,
    this.notifKey,
    this.icon,
  );

  final Prayer prayer;
  final String name;
  final DateTime? start;
  final DateTime end;
  final PrayerNotifKey? notifKey;
  final IconData icon;
}

class _PrayerTimeCard extends ConsumerWidget {
  const _PrayerTimeCard({
    required this.item,
    required this.active,
    required this.palette,
    required this.onNotificationTap,
  });

  final _PrayerRowData item;
  final bool active;
  final SettingsPalette palette;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerTimesSettingsNotifierProvider);
    final enabled =
        item.notifKey != null &&
        settings.notificationSettings[item.notifKey!] == true;
    final format = settings.timeFormat;
    return Material(
      color: active ? palette.selectedCard : palette.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onNotificationTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: active ? palette.selectedTitle : palette.title,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MediaQuery.withNoTextScaling(
                      child: Text(
                        item.start == null
                            ? '--:-- --'
                            : format.formatTimeWithContext(
                                context,
                                item.start!,
                              ),
                        style: TextStyle(
                          color: active
                              ? palette.selectedSubtitle
                              : palette.subtitle,
                          fontFamily: 'GoogleSans',
                          fontSize: 14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onNotificationTap != null)
                IconButton(
                  onPressed: onNotificationTap,
                  tooltip: context.loc.notification,
                  icon: Icon(
                    enabled ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
                    color: active ? palette.selectedTitle : palette.title,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.palette});
  final String title;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: palette.title,
      fontFamily: localizedFontFamily(context),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ForbiddenRowData {
  const _ForbiddenRowData(this.label, this.start, this.end, this.icon);
  final String label;
  final String start;
  final String end;
  final IconData icon;
}

class _ForbiddenTimesSection extends StatelessWidget {
  const _ForbiddenTimesSection({
    required this.times,
    required this.format,
    required this.palette,
    required this.onTap,
  });

  final PrayerTimes times;
  final TimeFormatOption format;
  final SettingsPalette palette;
  final ValueChanged<_ForbiddenRowData> onTap;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _ForbiddenRowData(
        context.loc.prayerSunrise,
        format.formatTimeWithContext(context, times.sunrise),
        format.formatTimeWithContext(
          context,
          times.sunrise.add(const Duration(minutes: 15)),
        ),
        Icons.wb_twilight_outlined,
      ),
      _ForbiddenRowData(
        context.loc.homeNoon,
        format.formatTimeWithContext(
          context,
          times.dhuhr.subtract(const Duration(minutes: 10)),
        ),
        format.formatTimeWithContext(context, times.dhuhr),
        Icons.wb_sunny_outlined,
      ),
      _ForbiddenRowData(
        context.loc.homeSunset,
        format.formatTimeWithContext(
          context,
          times.maghrib.subtract(const Duration(minutes: 15)),
        ),
        format.formatTimeWithContext(context, times.maghrib),
        Icons.wb_twilight_outlined,
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Material(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(rows[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(rows[i].icon, color: palette.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rows[i].label,
                            style: TextStyle(
                              color: palette.title,
                              fontFamily: localizedFontFamily(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          MediaQuery.withNoTextScaling(
                            child: Text(
                              '${rows[i].start} – ${rows[i].end}',
                              style: TextStyle(
                                color: palette.subtitle,
                                fontFamily: 'GoogleSans',
                                fontSize: 14,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => onTap(rows[i]),
                      tooltip: context.loc.notification,
                      icon: Icon(
                        CupertinoIcons.info_circle,
                        color: palette.title,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (i != rows.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _NightTimesSection extends StatelessWidget {
  const _NightTimesSection({
    required this.times,
    required this.nextTimes,
    required this.format,
    required this.palette,
    required this.context,
  });

  final PrayerTimes times;
  final PrayerTimes nextTimes;
  final TimeFormatOption format;
  final SettingsPalette palette;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final tahajjud = times.maghrib.add(
      Duration(
        milliseconds:
            (nextTimes.fajr.difference(times.maghrib).inMilliseconds * 2 / 3)
                .round(),
      ),
    );
    final rows = [
      (
        context.loc.homeSuhurEnd,
        times.fajr.subtract(const Duration(minutes: 1)),
        Icons.wb_twilight_outlined,
      ),
      (context.loc.iftar, times.maghrib, Icons.wb_sunny_outlined),
      (context.loc.homeTahajjud, tahajjud, Icons.nightlight_outlined),
    ];
    return Row(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(rows[i].$3, color: palette.accent, size: 23),
                    const SizedBox(height: 12),
                    Text(
                      rows[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.subtitle,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: MediaQuery.withNoTextScaling(
                        child: Text(
                          format.formatTimeWithContext(context, rows[i].$2),
                          style: TextStyle(
                            color: palette.title,
                            fontFamily: 'GoogleSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (i != rows.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class PrayerNotificationSettingsScreen extends ConsumerWidget {
  const PrayerNotificationSettingsScreen({super.key});

  static const _keys = [
    PrayerNotifKey.suhoor,
    PrayerNotifKey.fajr,
    PrayerNotifKey.sunrise,
    PrayerNotifKey.dhuhr,
    PrayerNotifKey.asr,
    PrayerNotifKey.iftar,
    PrayerNotifKey.maghrib,
    PrayerNotifKey.isha,
    PrayerNotifKey.eid,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final settings = ref.watch(prayerTimesSettingsNotifierProvider);
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final labels = _notificationLabels(context);
    final allEnabled = _keys.every(
      (key) => settings.notificationSettings[key] == true,
    );
    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: context.loc.notification, palette: palette),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          quranPlayerAwareBottomPadding(context, playerVisible: playerVisible),
        ),
        children: [
          SettingsCard(
            icon: Icons.notifications_active_outlined,
            title: context.loc.notificationEnabled,
            subtitle: context.loc.notificationPermissionDescription,
            palette: palette,
            switchValue: allEnabled,
            onSwitchChanged: (value) async {
              for (final key in _keys) {
                final enabled = settings.notificationSettings[key] == true;
                if (enabled != value) {
                  await ref
                      .read(prayerTimesSettingsNotifierProvider.notifier)
                      .toggleNotification(key);
                }
              }
            },
          ),
          const SizedBox(height: 8),
          SettingsCard(
            icon: Icons.schedule_outlined,
            title: _notificationTimingTitle(context),
            subtitle: settings.notificationTiming.getLabel(context),
            palette: palette,
            onTap: () => showNotificationTimingScreen(context),
          ),
          const SizedBox(height: 16),
          Text(
            context.loc.prayerAndFastingReminders,
            style: TextStyle(
              color: palette.title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final key in _keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NotificationRow(
                key: ValueKey(key),
                title: labels[key]!,
                palette: palette,
                enabled: settings.notificationSettings[key] == true,
                onToggle: () => ref
                    .read(prayerTimesSettingsNotifierProvider.notifier)
                    .toggleNotification(key),
                onTap: () => showPrayerNotificationEditorScreen(
                  context,
                  key,
                  labels[key]!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    super.key,
    required this.title,
    required this.palette,
    required this.enabled,
    required this.onToggle,
    required this.onTap,
  });

  final String title;
  final SettingsPalette palette;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                Icons.notifications_none_outlined,
                color: palette.accent,
                size: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.title,
                    fontFamily: localizedFontFamily(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: enabled,
                activeTrackColor: palette.accent,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<PrayerNotifKey, String> _notificationLabels(BuildContext context) => {
  PrayerNotifKey.suhoor: context.loc.suhoor,
  PrayerNotifKey.fajr: context.loc.prayerFajr,
  PrayerNotifKey.sunrise: context.loc.prayerSunrise,
  PrayerNotifKey.dhuhr: context.loc.prayerDhuhr,
  PrayerNotifKey.asr: context.loc.prayerAsr,
  PrayerNotifKey.iftar: context.loc.iftar,
  PrayerNotifKey.maghrib: context.loc.prayerMaghrib,
  PrayerNotifKey.isha: context.loc.prayerIsha,
  PrayerNotifKey.eid: context.loc.eidPrayer,
};

void showPrayerNotificationEditorScreen(
  BuildContext context,
  PrayerNotifKey key,
  String prayerName,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(
        name: AnalyticsScreenNames.prayerNotificationEditor,
      ),
      builder: (context) => PrayerNotificationEditorScreen(
        prayerKey: key,
        prayerName: prayerName,
      ),
    ),
  );
}

class PrayerNotificationEditorScreen extends ConsumerWidget {
  const PrayerNotificationEditorScreen({
    super.key,
    required this.prayerKey,
    required this.prayerName,
  });

  final PrayerNotifKey prayerKey;
  final String prayerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final settings = ref.watch(prayerTimesSettingsNotifierProvider);
    final enabled = settings.notificationSettings[prayerKey] == true;
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: prayerName, palette: palette),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          quranPlayerAwareBottomPadding(context, playerVisible: playerVisible),
        ),
        children: [
          SettingsCard(
            icon: Icons.notifications_active_outlined,
            title: context.loc.notificationEnabled,
            subtitle: context.loc.notificationPermissionDescription,
            palette: palette,
            switchValue: enabled,
            onSwitchChanged: (_) => ref
                .read(prayerTimesSettingsNotifierProvider.notifier)
                .toggleNotification(prayerKey),
          ),
          const SizedBox(height: 8),
          SettingsCard(
            icon: Icons.volume_up_outlined,
            title: _soundTitle(context),
            subtitle: settings.getSound(prayerKey).getLabel(context),
            palette: palette,
            onTap: () => showNotificationSoundOptionsScreen(
              context,
              prayerKey,
              prayerName: prayerName,
            ),
          ),
          const SizedBox(height: 8),
          SettingsCard(
            icon: Icons.schedule_outlined,
            title: _notificationTimingTitle(context),
            subtitle: settings.notificationTiming.getLabel(context),
            palette: palette,
            onTap: () => showNotificationTimingScreen(context),
          ),
        ],
      ),
    );
  }
}

void showNotificationSoundOptionsScreen(
  BuildContext context,
  PrayerNotifKey key, {
  String? prayerName,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(
        name: AnalyticsScreenNames.notificationSound,
      ),
      builder: (context) => NotificationSoundSelectionScreen(
        prayerKey: key,
        prayerName: prayerName,
      ),
    ),
  );
}

class NotificationSoundSelectionScreen extends ConsumerWidget {
  const NotificationSoundSelectionScreen({
    super.key,
    required this.prayerKey,
    this.prayerName,
  });

  final PrayerNotifKey prayerKey;
  final String? prayerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(prayerTimesSettingsNotifierProvider)
        .getSound(prayerKey);
    final sounds = prayerKey.availableSounds;
    return SettingsPickerScaffold(
      title: prayerName == null
          ? _soundTitle(context)
          : '$prayerName · ${_soundTitle(context)}',
      itemCount: sounds.length,
      itemBuilder: (context, index, palette) {
        final sound = sounds[index];
        return SettingsPickerTile(
          title: sound.getLabel(context),
          selected: sound == current,
          palette: palette,
          onTap: () => ref
              .read(prayerTimesSettingsNotifierProvider.notifier)
              .setNotificationSound(prayerKey, sound),
        );
      },
    );
  }
}

void showNotificationTimingScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(
        name: AnalyticsScreenNames.notificationTiming,
      ),
      builder: (context) => const NotificationTimingScreen(),
    ),
  );
}

class NotificationTimingScreen extends ConsumerWidget {
  const NotificationTimingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(prayerTimesSettingsNotifierProvider)
        .notificationTiming;
    return SettingsPickerScaffold(
      title: _notificationTimingTitle(context),
      itemCount: NotificationTiming.values.length,
      itemBuilder: (context, index, palette) {
        final timing = NotificationTiming.values[index];
        return SettingsPickerTile(
          title: timing.getLabel(context),
          selected: timing == current,
          palette: palette,
          onTap: () => ref
              .read(prayerTimesSettingsNotifierProvider.notifier)
              .setNotificationTiming(timing),
        );
      },
    );
  }
}

String _soundTitle(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ur'
      ? 'آواز'
      : 'Sound';
}

String _notificationTimingTitle(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ur'
      ? 'اطلاع کا وقت'
      : 'Notification Time';
}

void showTimeFormatScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: AnalyticsScreenNames.timeFormat),
      builder: (context) => const TimeFormatScreen(),
    ),
  );
}

class TimeFormatScreen extends ConsumerWidget {
  const TimeFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(prayerTimesSettingsNotifierProvider).timeFormat;
    return SettingsPickerScaffold(
      title: context.loc.timeFormat,
      itemCount: TimeFormatOption.values.length,
      itemBuilder: (context, index, palette) {
        final format = TimeFormatOption.values[index];
        return SettingsPickerTile(
          title: format.getLabel(context),
          selected: format == current,
          palette: palette,
          onTap: () => ref
              .read(prayerTimesSettingsNotifierProvider.notifier)
              .setTimeFormat(format),
        );
      },
    );
  }
}
