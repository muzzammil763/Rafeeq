import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/models/fasting_data.dart';

import 'package:rafeeq/l10n/app_localization_ext.dart';

import 'package:rafeeq/ui/app_home/home/settings_sheets.dart';
import 'package:rafeeq/ui/common/app_info_dialog.dart';
import 'package:rafeeq/ui/prayer_times/prayer_times_settings.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';
import 'package:rafeeq/data/models/ramadan_day_info.dart';
import 'package:rafeeq/data/providers/ramadan_providers.dart';

enum RamadanViewMode { list, grid, calendar }

class RamadanCalendarScreen extends ConsumerStatefulWidget {
  const RamadanCalendarScreen({super.key});

  @override
  ConsumerState<RamadanCalendarScreen> createState() =>
      _RamadanCalendarScreenState();
}

class _RamadanCalendarScreenState extends ConsumerState<RamadanCalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToToday = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday(
    List<RamadanDayInfo> ramadanDays,
    DateTime today,
    RamadanViewMode viewMode,
  ) {
    if (_hasScrolledToToday) return;
    _hasScrolledToToday = true;

    final todayIndex = ramadanDays.indexWhere(
      (info) => _isSameDay(info.date, today),
    );

    if (todayIndex <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      double targetOffset;
      if (viewMode == RamadanViewMode.list) {
        // Each list tile is ~84px height + 12px separator
        targetOffset = todayIndex * (84.0 + 12.0);
      } else {
        // Grid: 2 columns, aspect ratio 0.85
        final row = todayIndex ~/ 2;
        // Approximate row height from screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth = (screenWidth - 12 * 3) / 2; // padding + spacing
        final itemHeight = itemWidth / 0.85;
        targetOffset = row * (itemHeight + 12);
      }

      // Clamp to max scroll extent
      final maxScroll = _scrollController.position.maxScrollExtent;
      targetOffset = targetOffset.clamp(0.0, maxScroll);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = ref.watch(userLocationNotifierProvider);

    final timeFormat = ref.watch(
      prayerTimesSettingsNotifierProvider.select((s) => s.timeFormat),
    );
    final theme = context.mainTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final viewModeIndex = ref.watch(
      appSettingsNotifierProvider.select((s) => s.ramadanViewMode),
    );
    final viewMode = RamadanViewMode
        .values[viewModeIndex.clamp(0, RamadanViewMode.values.length - 1)];

    final ramadanDays = ref.watch(ramadanDaysProvider);
    final today = DateTime.now();

    // Trigger scroll to today after build
    if (ramadanDays.isNotEmpty &&
        userLocation != null &&
        (viewMode == RamadanViewMode.list ||
            viewMode == RamadanViewMode.grid)) {
      _scrollToToday(ramadanDays, today, viewMode);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.ramadanCalendarTitle),
        actions: [
          IconButton(
            onPressed: () {
              showRamadanSettingsSheet(context);
            },
            icon: const Icon(CupertinoIcons.settings),
          ),
        ],
      ),
      body: userLocation == null
          ? Center(child: Text(context.loc.setLocationForPrayerTimes))
          : switch (viewMode) {
              RamadanViewMode.grid => GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: ramadanDays.length,
                itemBuilder: (context, index) {
                  final info = ramadanDays[index];
                  final isToday = _isSameDay(info.date, today);

                  return _RamadanGridTile(
                    info: info,
                    isToday: isToday,
                    timeFormat: timeFormat,
                    theme: theme,
                    colorScheme: colorScheme,
                  );
                },
              ),
              RamadanViewMode.calendar => _RamadanCalendarView(
                ramadanDays: ramadanDays,
                today: today,
                colorScheme: colorScheme,
              ),
              RamadanViewMode.list => ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: ramadanDays.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final info = ramadanDays[index];
                  final isToday = _isSameDay(info.date, today);

                  return _RamadanDayTile(
                    info: info,
                    isToday: isToday,
                    timeFormat: timeFormat,
                    theme: theme,
                    colorScheme: colorScheme,
                  );
                },
              ),
            },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _RamadanDayTile extends ConsumerWidget {
  final RamadanDayInfo info;
  final bool isToday;
  final TimeFormatOption timeFormat;
  final RafeeqTheme theme;
  final ColorScheme colorScheme;

  const _RamadanDayTile({
    required this.info,
    required this.isToday,
    required this.timeFormat,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final isUrdu = language == 'ur';

    final statusAsync = ref.watch(fastingStatusProvider(info.date));
    final status = statusAsync.value ?? FastingStatus.none;

    // Date Formats
    final dayName = DateFormat('EEE', language).format(info.date);
    final dayNum = DateFormat('EEE, MMM d, yyyy', language).format(info.date);

    // Hijri
    final hDay = isUrdu
        ? info.hijriDate.hDay.toLocalizedNumber(context)
        : info.hijriDate.hDay.toString();

    final background = isToday
        ? colorScheme.primary.withValues(alpha: 0.1)
        : colorScheme.surface;

    final border = isToday
        ? Border.all(color: colorScheme.primary, width: 1.5)
        : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1));

    return InkWell(
      onTap: () => showFastingStatusSheet(context, info.date),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          children: [
            // ── Date Column ──
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isToday
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    hDay,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    context.loc.ramadanMubarak.split(
                      ' ',
                    )[0], // Just "Ramadan" usually
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? colorScheme.onPrimary.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$dayName, $dayNum",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (status != FastingStatus.none)
                        Icon(
                          status.getIcon(),
                          color: status.getColor(context),
                          size: 18,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      _TimeItem(
                        label: context.loc.suhoor,
                        time: timeFormat.formatTime(info.suhoor),
                        icon: Icons.wb_twighlight,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 16),
                      _TimeItem(
                        label: context.loc.iftar,
                        time: timeFormat.formatTime(info.iftar),
                        icon: Icons.brightness_3,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeItem({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            Text(
              time,
              textDirection: ui.TextDirection.ltr,
              style: TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RamadanGridTile extends ConsumerWidget {
  final RamadanDayInfo info;
  final bool isToday;
  final TimeFormatOption timeFormat;
  final RafeeqTheme theme;
  final ColorScheme colorScheme;

  const _RamadanGridTile({
    required this.info,
    required this.isToday,
    required this.timeFormat,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final isUrdu = language == 'ur';

    final statusAsync = ref.watch(fastingStatusProvider(info.date));
    final status = statusAsync.value ?? FastingStatus.none;

    // Date Formats
    final fullDate = DateFormat('EEE, MMM d, yyyy', language).format(info.date);
    final dayName = DateFormat('EEEE', language).format(info.date);

    // Hijri
    final hDay = isUrdu
        ? info.hijriDate.hDay.toLocalizedNumber(context)
        : info.hijriDate.hDay.toString();

    final background = isToday
        ? colorScheme.primary.withValues(alpha: 0.1)
        : colorScheme.surface;

    final border = isToday
        ? Border.all(color: colorScheme.primary, width: 2)
        : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1));

    return InkWell(
      onTap: () => showFastingStatusSheet(context, info.date),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hDay,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (status != FastingStatus.none)
                  Icon(
                    status.getIcon(),
                    size: 20,
                    color: status.getColor(context),
                  )
                else if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.loc.ramadanMubarak.split(' ')[0],
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              fullDate,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniTimeItem(
                  label: context.loc.suhoor,
                  time: timeFormat.formatTime(info.suhoor),
                  icon: Icons.wb_twighlight,
                  color: colorScheme.onSurface,
                ),
                _MiniTimeItem(
                  label: context.loc.iftar,
                  time: timeFormat.formatTime(info.iftar),
                  icon: Icons.brightness_3,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTimeItem extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _MiniTimeItem({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 10,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          textDirection: ui.TextDirection.ltr,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RamadanCalendarView extends StatelessWidget {
  final List<RamadanDayInfo> ramadanDays;
  final DateTime today;
  final ColorScheme colorScheme;

  const _RamadanCalendarView({
    required this.ramadanDays,
    required this.today,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (ramadanDays.isEmpty) {
      return const SizedBox.shrink();
    }

    final language = Localizations.localeOf(context).languageCode;
    final firstDay = ramadanDays.first.date;

    // Generate headers (Mon-Sun)
    final weekDays = List.generate(7, (index) {
      final d = DateTime(
        2024,
        1,
        1,
      ).add(Duration(days: index)); // Jan 1 2024 was Monday
      return DateFormat.E(language).format(d);
    });

    final startOffset = firstDay.weekday - 1; // Mon=1 -> 0 offset.

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: ramadanDays.length + startOffset,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox();
              }
              final dayIndex = index - startOffset;
              final info = ramadanDays[dayIndex];
              bool isToday =
                  info.date.year == today.year &&
                  info.date.month == today.month &&
                  info.date.day == today.day;

              return _CalendarDayCell(
                info: info,
                isToday: isToday,
                colorScheme: colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CalendarDayCell extends ConsumerWidget {
  final RamadanDayInfo info;
  final bool isToday;
  final ColorScheme colorScheme;

  const _CalendarDayCell({
    required this.info,
    required this.isToday,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final isUrdu = language == 'ur';
    final hDay = isUrdu
        ? info.hijriDate.hDay.toLocalizedNumber(context)
        : info.hijriDate.hDay.toString();

    final statusAsync = ref.watch(fastingStatusProvider(info.date));
    final status = statusAsync.value ?? FastingStatus.none;

    Color? bgColor;
    if (status == FastingStatus.missed) {
      bgColor = status.getColor(context).withValues(alpha: 0.2);
    } else if (status == FastingStatus.fasting) {
      bgColor = Colors.green.withValues(alpha: 0.15);
    } else if (isToday) {
      bgColor = colorScheme.primary;
    } else {
      bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }

    return InkWell(
      onTap: () => showFastingStatusSheet(context, info.date),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hDay,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: (isToday && status == FastingStatus.none)
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
            if (status != FastingStatus.none)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  status.getIcon(),
                  size: 10,
                  color: status.getColor(context),
                ),
              )
            else
              Text(
                DateFormat('d', language).format(info.date),
                style: TextStyle(
                  fontSize: 9,
                  color: (isToday && status == FastingStatus.none)
                      ? colorScheme.onPrimary.withValues(alpha: 0.8)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void showFastingStatusSheet(BuildContext context, DateTime date) {
  if (!context.mounted) return;

  // Only allow tracking for today and past days
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);
  if (dateOnly.isAfter(today)) return;

  final theme = context.mainTheme;
  final language = Localizations.localeOf(context).languageCode;
  final formattedDate = DateFormat('EEE, MMM d, yyyy', language).format(date);

  AppInfoDialog.show(
    context,
    title: context.loc.fastingStatus,
    iconAsset: 'assets/logo.svg',
    gradientColors: [theme.secondaryColor, theme.primaryColor],
    contentWidgets: [
      Center(
        child: Text(
          formattedDate,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Consumer(
        builder: (context, ref, _) {
          final statusAsync = ref.watch(fastingStatusProvider(date));
          final currentStatus = statusAsync.value ?? FastingStatus.none;
          final colorScheme = Theme.of(context).colorScheme;

          return Column(
            children: [
              Row(
                children: [
                  // Fasting option
                  Expanded(
                    child: _FastingOptionCard(
                      label: context.loc.statusFasting,
                      icon: Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      isSelected: currentStatus == FastingStatus.fasting,
                      onTap: () {
                        final newStatus = currentStatus == FastingStatus.fasting
                            ? FastingStatus.none
                            : FastingStatus.fasting;
                        ref
                            .read(fastingRepositoryProvider)
                            .setStatus(date, newStatus);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Missed option
                  Expanded(
                    child: _FastingOptionCard(
                      label: context.loc.statusMissed,
                      icon: Icons.cancel_rounded,
                      color: Colors.red,
                      isSelected: currentStatus == FastingStatus.missed,
                      onTap: () {
                        final newStatus = currentStatus == FastingStatus.missed
                            ? FastingStatus.none
                            : FastingStatus.missed;
                        ref
                            .read(fastingRepositoryProvider)
                            .setStatus(date, newStatus);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              if (currentStatus != FastingStatus.none) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(fastingRepositoryProvider)
                          .setStatus(date, FastingStatus.none);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(context.loc.statusNone),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    ],
  );
}

class _FastingOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FastingOptionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white.withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showRamadanSettingsSheet(BuildContext context) {
  final theme = context.mainTheme;

  AppInfoDialog.show(
    context,
    title: context.loc.ramadanSettings,
    iconAsset: 'assets/logo.svg',
    gradientColors: [theme.secondaryColor, theme.primaryColor],
    contentWidgets: [
      Consumer(
        builder: (context, ref, child) {
          final viewModeIndex = ref.watch(
            appSettingsNotifierProvider.select((s) => s.ramadanViewMode),
          );
          final viewMode =
              RamadanViewMode.values[viewModeIndex.clamp(
                0,
                RamadanViewMode.values.length - 1,
              )];
          final hijriCorrection = ref.watch(
            appSettingsNotifierProvider.select((e) => e.hijriCorrection),
          );
          final theme = context.mainTheme;

          return Column(
            children: [
              ListTile(
                title: Text(context.loc.viewType),
                subtitle: Text(
                  switch (viewMode) {
                    RamadanViewMode.list => context.loc.listView,
                    RamadanViewMode.grid => context.loc.gridView,
                    RamadanViewMode.calendar => context.loc.calendarView,
                  },
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () {
                  showRamadanViewModeSheet(context);
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                title: Text(context.loc.hijriCorrection),
                subtitle: Text(
                  hijriCorrection.getLabel(context),
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () {
                  showHijriCorrectionModalSheet(context);
                },
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          );
        },
      ),
    ],
  );
}

void showRamadanViewModeSheet(BuildContext context) {
  final theme = context.mainTheme;

  AppInfoDialog.show(
    context,
    title: context.loc.viewType,
    iconAsset: 'assets/logo.svg',
    gradientColors: [theme.secondaryColor, theme.primaryColor],
    contentWidgets: [
      Consumer(
        builder: (context, ref, child) {
          final viewModeIndex = ref.watch(
            appSettingsNotifierProvider.select((s) => s.ramadanViewMode),
          );
          final colorScheme = Theme.of(context).colorScheme;

          return Column(
            children: [
              for (final mode in RamadanViewMode.values)
                ListTile(
                  leading: Icon(
                    switch (mode) {
                      RamadanViewMode.list => Icons.view_list_rounded,
                      RamadanViewMode.grid => Icons.grid_view_rounded,
                      RamadanViewMode.calendar => Icons.calendar_month_rounded,
                    },
                    color: mode.index == viewModeIndex
                        ? colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    switch (mode) {
                      RamadanViewMode.list => context.loc.listView,
                      RamadanViewMode.grid => context.loc.gridView,
                      RamadanViewMode.calendar => context.loc.calendarView,
                    },
                    style: TextStyle(
                      fontWeight: mode.index == viewModeIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: mode.index == viewModeIndex
                          ? colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: mode.index == viewModeIndex
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(appSettingsNotifierProvider.notifier)
                        .setRamadanViewMode(mode.index);
                    Navigator.pop(context);
                  },
                ),
            ],
          );
        },
      ),
    ],
  );
}
