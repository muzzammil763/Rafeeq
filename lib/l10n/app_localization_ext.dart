import 'package:flutter/material.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/l10n/app_localizations_en.dart';
import 'package:rafeeq/l10n/app_localizations_ur.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc {
    final localization = AppLocalizations.of(this);
    if (localization != null) return localization;

    return Localizations.localeOf(this).languageCode == 'ur'
        ? AppLocalizationsUr()
        : AppLocalizationsEn();
  }
}
