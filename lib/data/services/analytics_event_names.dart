abstract final class AnalyticsEventNames {
  static const settingsLanguageScreenOpened = 'settings_language_screen_opened';
  static const settingsLocationScreenOpened = 'settings_location_screen_opened';
  static const settingsThemeScreenOpened = 'settings_theme_screen_opened';
  static const settingsCalculationScreenOpened =
      'settings_calculation_screen_opened';
  static const settingsJuristicScreenOpened = 'settings_juristic_screen_opened';
  static const settingsHighLatitudeScreenOpened =
      'settings_high_latitude_screen_opened';
  static const settingsHijriCorrectionScreenOpened =
      'settings_hijri_correction_screen_opened';
  static const settingsFeedbackTapped = 'settings_feedback_tapped';
  static const settingsRateAppTapped = 'settings_rate_app_tapped';
  static const settingsShareAppTapped = 'settings_share_app_tapped';
  static const settingsLocationChangedToAutomatic =
      'settings_location_to_automatic';
  static const settingsLocationChangedToManual = 'settings_location_to_manual';

  static const quranJuzDownloadStarted = 'quran_juz_download_started';
  static const quranJuzDownloadCompleted = 'quran_juz_download_completed';
  static const quranJuzDownloadFailed = 'quran_juz_download_failed';
  static const quranJuzFileChecked = 'quran_juz_file_checked';
  static const quranJuzCacheSync = 'quran_juz_cache_sync';
  static const quranJuzViewed = 'quran_juz_viewed';
  static const quranJuzSwitched = 'quran_juz_switched';

  static const asmaUlHusnaVideosDialogOpened =
      'asma_ul_husna_videos_dialog_opened';
  static const asmaUlHusnaVideoPlayed = 'asma_ul_husna_video_played';

  static String languageValue(String languageCode) {
    return switch (languageCode) {
      'en' => 'english',
      'ur' => 'urdu',
      _ => 'other',
    };
  }

  static String settingsLanguageChangedTo(String languageCode) {
    return 'settings_language_changed_to_${languageValue(languageCode)}';
  }

  static String themeValue(String themeMode) {
    return switch (themeMode) {
      'light' => 'light',
      'dark' => 'dark',
      'system' => 'system',
      _ => 'other',
    };
  }

  static String settingsThemeChangedTo(String themeMode) {
    return 'settings_theme_changed_to_${themeValue(themeMode)}';
  }

  static String calculationMethodValue(String method) {
    return switch (method) {
      'muslim_world_league' => 'muslim_world_league',
      'egyptian' => 'egyptian',
      'karachi' => 'karachi',
      'umm_al_qura' => 'umm_al_qura',
      'dubai' => 'dubai',
      'moon_sighting_committee' => 'moon_sighting_committee',
      'north_america' => 'north_america',
      'kuwait' => 'kuwait',
      'qatar' => 'qatar',
      'singapore' => 'singapore',
      'turkey' => 'turkey',
      'tehran' => 'tehran',
      'jafari' => 'jafari',
      _ => 'other',
    };
  }

  static String settingsCalculationMethodChangedTo(String method) {
    return 'calc_method_to_${calculationMethodValue(method)}';
  }

  static String juristicMethodValue(String method) {
    return switch (method) {
      'hanafi' => 'hanafi',
      'others' => 'standard',
      _ => 'other',
    };
  }

  static String settingsJuristicMethodChangedTo(String method) {
    return 'juristic_method_to_${juristicMethodValue(method)}';
  }

  static String highLatitudeRuleValue(String rule) {
    return switch (rule) {
      'angleBased' => 'angle_based',
      'middleOfTheNight' => 'middle_of_night',
      'oneSeventh' => 'one_seventh',
      _ => 'other',
    };
  }

  static String settingsHighLatitudeRuleChangedTo(String rule) {
    return 'high_latitude_rule_to_${highLatitudeRuleValue(rule)}';
  }

  static String hijriCorrectionValue(String correction) {
    return switch (correction) {
      'minus2Days' => 'minus_2_days',
      'minus1Day' => 'minus_1_day',
      'none' => 'none',
      'plus1Day' => 'plus_1_day',
      'plus2Days' => 'plus_2_days',
      _ => 'other',
    };
  }

  static String settingsHijriCorrectionChangedTo(String correction) {
    return 'hijri_correction_to_${hijriCorrectionValue(correction)}';
  }

  static List<String> get all {
    return [
      settingsLanguageScreenOpened,
      settingsLocationScreenOpened,
      settingsThemeScreenOpened,
      settingsCalculationScreenOpened,
      settingsJuristicScreenOpened,
      settingsHighLatitudeScreenOpened,
      settingsHijriCorrectionScreenOpened,
      settingsLanguageChangedTo('en'),
      settingsLanguageChangedTo('ur'),
      settingsThemeChangedTo('light'),
      settingsThemeChangedTo('dark'),
      settingsThemeChangedTo('system'),
      settingsLocationChangedToAutomatic,
      settingsLocationChangedToManual,
      for (final method in <String>[
        'muslim_world_league',
        'egyptian',
        'karachi',
        'umm_al_qura',
        'dubai',
        'moon_sighting_committee',
        'north_america',
        'kuwait',
        'qatar',
        'singapore',
        'turkey',
        'tehran',
        'jafari',
      ])
        settingsCalculationMethodChangedTo(method),
      settingsJuristicMethodChangedTo('hanafi'),
      settingsJuristicMethodChangedTo('others'),
      settingsHighLatitudeRuleChangedTo('angleBased'),
      settingsHighLatitudeRuleChangedTo('middleOfTheNight'),
      settingsHighLatitudeRuleChangedTo('oneSeventh'),
      for (final correction in <String>[
        'minus2Days',
        'minus1Day',
        'none',
        'plus1Day',
        'plus2Days',
      ])
        settingsHijriCorrectionChangedTo(correction),
      settingsFeedbackTapped,
      settingsRateAppTapped,
      settingsShareAppTapped,
      quranJuzDownloadStarted,
      quranJuzDownloadCompleted,
      quranJuzDownloadFailed,
      quranJuzFileChecked,
      quranJuzCacheSync,
      quranJuzViewed,
      quranJuzSwitched,
      asmaUlHusnaVideosDialogOpened,
      asmaUlHusnaVideoPlayed,
    ];
  }
}
