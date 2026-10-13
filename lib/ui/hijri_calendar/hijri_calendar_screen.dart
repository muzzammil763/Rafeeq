import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

class HijriCalendarScreen extends ConsumerStatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  ConsumerState<HijriCalendarScreen> createState() =>
      _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends ConsumerState<HijriCalendarScreen> {
  late HijriCalendar _displayedHijriMonth;
  late HijriCalendar _selectedHijriDay;

  @override
  void initState() {
    super.initState();
    final corrected = ref.read(correctedDateTimeProvider);
    _displayedHijriMonth = HijriCalendar.fromDate(corrected);
    _selectedHijriDay = HijriCalendar.fromDate(corrected);
  }

  void _onDaySelected(HijriCalendar day) {
    setState(() {
      _selectedHijriDay = day;
    });
  }

  void _previousMonth() {
    setState(() {
      int newMonth = _displayedHijriMonth.hMonth - 1;
      int newYear = _displayedHijriMonth.hYear;
      if (newMonth < 1) {
        newMonth = 12;
        newYear -= 1;
      }
      final greg = HijriCalendar().hijriToGregorian(newYear, newMonth, 1);
      _displayedHijriMonth = HijriCalendar.fromDate(greg);
    });
  }

  void _nextMonth() {
    setState(() {
      int newMonth = _displayedHijriMonth.hMonth + 1;
      int newYear = _displayedHijriMonth.hYear;
      if (newMonth > 12) {
        newMonth = 1;
        newYear += 1;
      }
      final greg = HijriCalendar().hijriToGregorian(newYear, newMonth, 1);
      _displayedHijriMonth = HijriCalendar.fromDate(greg);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(correctedDateTimeProvider, (previous, next) {
      if (previous != null) {
        final prevHijri = HijriCalendar.fromDate(previous);
        final nextHijri = HijriCalendar.fromDate(next);
        if (prevHijri.hYear != nextHijri.hYear ||
            prevHijri.hMonth != nextHijri.hMonth ||
            prevHijri.hDay != nextHijri.hDay) {
          setState(() {
            _displayedHijriMonth = HijriCalendar.fromDate(next);
            _selectedHijriDay = HijriCalendar.fromDate(next);
          });
        }
      }
    });

    final palette = SettingsPalette.of(context);
    final correctedNow = ref.watch(correctedDateTimeProvider);
    final todayHijri = HijriCalendar.fromDate(correctedNow);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.hijriCalendarTitle,
        palette: palette,
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                _MonthHeader(
                  hijriMonth: _displayedHijriMonth,
                  palette: palette,
                  onPrevious: _previousMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                      child: Column(
                        children: [
                          _WeekDayHeaders(palette: palette),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _CalendarGrid(
                              displayedMonth: _displayedHijriMonth,
                              todayHijri: todayHijri,
                              selectedHijri: _selectedHijriDay,
                              palette: palette,
                              onDaySelected: _onDaySelected,
                            ),
                          ),
                        ],
                      ),
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

// ═══════════════════════════════════════════════════════════════════
//  MONTH HEADER
// ═══════════════════════════════════════════════════════════════════

class _MonthHeader extends ConsumerWidget {
  final HijriCalendar hijriMonth;
  final SettingsPalette palette;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.hijriMonth,
    required this.palette,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref
        .watch(appSettingsNotifierProvider)
        .language
        .languageCode;
    final isUrdu = language == 'ur';

    // The first Gregorian day of this Hijri month
    final firstGregorianDay = HijriCalendar().hijriToGregorian(
      hijriMonth.hYear,
      hijriMonth.hMonth,
      1,
    );

    final gregMonthStr = DateFormat(
      'MMMM yyyy',
      language,
    ).format(firstGregorianDay);

    final hijriMonthName = _hijriMonthName(hijriMonth, isUrdu: isUrdu);

    final hijriYear = isUrdu
        ? hijriMonth.hYear.toLocalizedNumber(context)
        : hijriMonth.hYear.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          // Previous button
          _MonthNavigationButton(
            onPressed: onPrevious,
            icon: Icons.chevron_left_rounded,
            palette: palette,
          ),
          const SizedBox(width: 8),
          // Month info
          Expanded(
            child: Column(
              children: [
                Text(
                  '$hijriMonthName $hijriYear',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: palette.title,
                    fontFamily: isUrdu
                        ? 'Jameel Noori Nastaleeq'
                        : 'GoogleSans',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gregMonthStr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.subtitle,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Next button
          _MonthNavigationButton(
            onPressed: onNext,
            icon: Icons.chevron_right_rounded,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _MonthNavigationButton extends StatelessWidget {
  const _MonthNavigationButton({
    required this.onPressed,
    required this.icon,
    required this.palette,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      color: palette.title,
      style: IconButton.styleFrom(
        backgroundColor: palette.background,
        minimumSize: const Size.square(40),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WEEK DAY HEADERS (Mon – Sun)
// ═══════════════════════════════════════════════════════════════════

class _WeekDayHeaders extends ConsumerWidget {
  final SettingsPalette palette;

  const _WeekDayHeaders({required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref
        .watch(appSettingsNotifierProvider)
        .language
        .languageCode;
    // Jan 1 2024 was Monday – use as a fixed anchor
    final weekDays = List.generate(
      7,
      (i) => DateFormat.E(
        language,
      ).format(DateTime(2024, 1, 1).add(Duration(days: i))),
    );

    return Row(
      children: weekDays
          .map(
            (day) => Expanded(
              child: Text(
                day.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: palette.subtitle,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CALENDAR GRID
// ═══════════════════════════════════════════════════════════════════

class _CalendarGrid extends ConsumerWidget {
  final HijriCalendar displayedMonth;
  final HijriCalendar todayHijri;
  final HijriCalendar selectedHijri;
  final SettingsPalette palette;
  final void Function(HijriCalendar) onDaySelected;

  const _CalendarGrid({
    required this.displayedMonth,
    required this.todayHijri,
    required this.selectedHijri,
    required this.palette,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref
        .watch(appSettingsNotifierProvider)
        .language
        .languageCode;
    final isUrdu = language == 'ur';

    // Compute number of days in this Hijri month
    final daysInMonth = _daysInHijriMonth(
      displayedMonth.hYear,
      displayedMonth.hMonth,
    );

    // Determine Gregorian day-of-week (Mon=1) for Hijri 1st of the month
    final firstGreg = HijriCalendar().hijriToGregorian(
      displayedMonth.hYear,
      displayedMonth.hMonth,
      1,
    );
    final startOffset = firstGreg.weekday - 1; // Mon=1 → offset 0

    final totalCells = startOffset + daysInMonth;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.85,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox.shrink();

        final hijriDay = index - startOffset + 1;

        // Get corresponding Gregorian date
        final gregDate = HijriCalendar().hijriToGregorian(
          displayedMonth.hYear,
          displayedMonth.hMonth,
          hijriDay,
        );

        final isToday =
            todayHijri.hYear == displayedMonth.hYear &&
            todayHijri.hMonth == displayedMonth.hMonth &&
            todayHijri.hDay == hijriDay;

        final isSelected =
            selectedHijri.hYear == displayedMonth.hYear &&
            selectedHijri.hMonth == displayedMonth.hMonth &&
            selectedHijri.hDay == hijriDay;

        final hijriDayLabel = isUrdu
            ? hijriDay.toLocalizedNumber(context)
            : hijriDay.toString();

        final gregDayLabel = DateFormat('d', language).format(gregDate);

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            final greg = HijriCalendar().hijriToGregorian(
              displayedMonth.hYear,
              displayedMonth.hMonth,
              hijriDay,
            );
            onDaySelected(HijriCalendar.fromDate(greg));
          },
          child: _DayCell(
            hijriDay: hijriDayLabel,
            gregDay: gregDayLabel,
            isToday: isToday,
            isSelected: isSelected,
            palette: palette,
          ),
        );
      },
    );
  }

  /// Returns the number of days in a Hijri month using the hijri package.
  int _daysInHijriMonth(int year, int month) {
    return HijriCalendar().getDaysInMonth(year, month);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DAY CELL
// ═══════════════════════════════════════════════════════════════════

class _DayCell extends StatelessWidget {
  final String hijriDay;
  final String gregDay;
  final bool isToday;
  final bool isSelected;
  final SettingsPalette palette;

  const _DayCell({
    required this.hijriDay,
    required this.gregDay,
    required this.isToday,
    required this.isSelected,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? palette.accent
        : isToday
        ? palette.accent.withValues(alpha: 0.1)
        : palette.background;

    final hijriTextColor = isSelected ? palette.background : palette.title;

    final gregTextColor = isSelected
        ? palette.background.withValues(alpha: 0.82)
        : palette.subtitle;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday && !isSelected
            ? Border.all(color: palette.accent, width: 1.5)
            : Border.all(color: palette.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hijriDay,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: hijriTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(gregDay, style: TextStyle(fontSize: 12, color: gregTextColor)),
        ],
      ),
    );
  }
}

String _hijriMonthName(HijriCalendar date, {required bool isUrdu}) {
  if (!isUrdu) return date.longMonthName;
  const urduMonths = [
    'محرم',
    'صفر',
    'ربیع الاول',
    'ربیع الثانی',
    'جمادی الاول',
    'جمادی الثانی',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدہ',
    'ذو الحجہ',
  ];
  return date.hMonth >= 1 && date.hMonth <= urduMonths.length
      ? urduMonths[date.hMonth - 1]
      : '';
}
