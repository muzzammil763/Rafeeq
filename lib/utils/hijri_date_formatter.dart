import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:rafeeq/utils/extensions/number_localization.dart';

/// Shared utility for formatting Hijri dates in a locale-aware way.
class HijriDateFormatter {
  HijriDateFormatter._();

  static const _urduMonths = [
    "محرم",
    "صفر",
    "ربیع الاول",
    "ربیع الثانی",
    "جمادی الاول",
    "جمادی الثانی",
    "رجب",
    "شعبان",
    "رمضان",
    "شوال",
    "ذو القعدہ",
    "ذو الحجہ",
  ];

  /// Returns the Urdu name for a Hijri month (1-indexed).
  ///
  /// Throws [ArgumentError] if month is not in range 1-12.
  static String getUrduHijriMonth(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12',
      );
    }
    return _urduMonths[month - 1];
  }

  /// Formats a [HijriCalendar] date as "DD MonthName" (no year).
  ///
  /// Handles Urdu numeral and month-name localization automatically.
  ///
  /// Throws [ArgumentError] if [hijriDate] is null.
  static String formatShort(BuildContext context, HijriCalendar hijriDate) {
    ArgumentError.checkNotNull(hijriDate, 'hijriDate');

    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    final day = _formatDay(hijriDate.hDay, context, isUrdu);
    final month = _formatMonth(hijriDate.hMonth, hijriDate, isUrdu);

    return '$day $month';
  }

  /// Formats a [HijriCalendar] date as "DD MonthName, YYYY".
  ///
  /// Handles Urdu numeral and month-name localization automatically.
  ///
  /// Throws [ArgumentError] if [hijriDate] is null.
  static String formatLong(BuildContext context, HijriCalendar hijriDate) {
    ArgumentError.checkNotNull(hijriDate, 'hijriDate');

    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    final day = _formatDay(hijriDate.hDay, context, isUrdu);
    final year = _formatYear(hijriDate.hYear, context, isUrdu);
    final month = _formatMonth(hijriDate.hMonth, hijriDate, isUrdu);

    return '$day $month, $year';
  }

  /// Helper method to format day with proper localization.
  static String _formatDay(int day, BuildContext context, bool isUrdu) {
    return isUrdu ? day.toLocalizedNumber(context) : day.toString();
  }

  /// Helper method to format year with proper localization.
  static String _formatYear(int year, BuildContext context, bool isUrdu) {
    return isUrdu ? year.toLocalizedNumber(context) : year.toString();
  }

  /// Helper method to format month name with proper localization.
  static String _formatMonth(int month, HijriCalendar hijriDate, bool isUrdu) {
    return isUrdu ? getUrduHijriMonth(month) : hijriDate.longMonthName;
  }
}
