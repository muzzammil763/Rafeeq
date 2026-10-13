import 'package:flutter/material.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';

enum HijriCorrection {
  minus2Days,
  minus1Day,
  none,
  plus1Day,
  plus2Days;

  String getLabel(BuildContext context) {
    switch (this) {
      case minus2Days:
        return context.loc.hijriMinus2Days;
      case minus1Day:
        return context.loc.hijriMinus1Day;
      case none:
        return context.loc.hijriNone;
      case plus1Day:
        return context.loc.hijriPlus1Day;
      case plus2Days:
        return context.loc.hijriPlus2Days;
    }
  }

  // Keep the old label getter for backward compatibility
  String get label {
    switch (this) {
      case minus2Days:
        return "Two Days Ago (-2)";
      case minus1Day:
        return "One Day Ago (-1)";
      case none:
        return "None";
      case plus1Day:
        return "One Day Ahead (+1)";
      case plus2Days:
        return "Two Days Ahead (+2)";
    }
  }

  DateTime getAdjustedDate(DateTime date) {
    switch (this) {
      case minus2Days:
        return date.subtract(const Duration(days: 2));
      case minus1Day:
        return date.subtract(const Duration(days: 1));
      case none:
        return date;
      case plus1Day:
        return date.add(const Duration(days: 1));
      case plus2Days:
        return date.add(const Duration(days: 2));
    }
  }
}

extension HijriCorrectionX on DateTime {
  DateTime getAdjusted(HijriCorrection hijriCorrection) {
    return hijriCorrection.getAdjustedDate(this);
  }
}
