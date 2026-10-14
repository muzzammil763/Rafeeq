import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/services/analytics_event_names.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return AnalyticsService(analytics);
});

class AnalyticsService {
  final FirebaseAnalytics? _analytics;

  AnalyticsService(this._analytics);

  Future<void> _logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  // Settings - screen and modal opens
  Future<void> logSettingsLanguageScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsLanguageScreenOpened);

  Future<void> logSettingsLocationScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsLocationScreenOpened);

  Future<void> logSettingsThemeScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsThemeScreenOpened);

  Future<void> logSettingsCalculationScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsCalculationScreenOpened);

  Future<void> logSettingsJuristicScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsJuristicScreenOpened);

  Future<void> logSettingsHighLatitudeScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsHighLatitudeScreenOpened);

  Future<void> logSettingsHijriCorrectionScreenOpened() =>
      _logEvent(name: AnalyticsEventNames.settingsHijriCorrectionScreenOpened);

  // Settings - preference changes
  Future<void> logSettingsLanguageChanged(String languageCode) {
    final language = AnalyticsEventNames.languageValue(languageCode);
    return _logEvent(
      name: AnalyticsEventNames.settingsLanguageChangedTo(languageCode),
      parameters: {'language': language},
    );
  }

  Future<void> logSettingsThemeChanged(String themeMode) {
    final theme = AnalyticsEventNames.themeValue(themeMode);
    return _logEvent(
      name: AnalyticsEventNames.settingsThemeChangedTo(themeMode),
      parameters: {'theme': theme},
    );
  }

  Future<void> logSettingsLocationChangedToAutomatic() =>
      _logEvent(name: AnalyticsEventNames.settingsLocationChangedToAutomatic);

  Future<void> logSettingsLocationChangedToManual() =>
      _logEvent(name: AnalyticsEventNames.settingsLocationChangedToManual);

  Future<void> logSettingsCalculationMethodChanged(String method) {
    final value = AnalyticsEventNames.calculationMethodValue(method);
    return _logEvent(
      name: AnalyticsEventNames.settingsCalculationMethodChangedTo(method),
      parameters: {'calculation_method': value},
    );
  }

  Future<void> logSettingsJuristicMethodChanged(String method) {
    final value = AnalyticsEventNames.juristicMethodValue(method);
    return _logEvent(
      name: AnalyticsEventNames.settingsJuristicMethodChangedTo(method),
      parameters: {'juristic_method': value},
    );
  }

  Future<void> logSettingsHighLatitudeRuleChanged(String rule) {
    final value = AnalyticsEventNames.highLatitudeRuleValue(rule);
    return _logEvent(
      name: AnalyticsEventNames.settingsHighLatitudeRuleChangedTo(rule),
      parameters: {'high_latitude_rule': value},
    );
  }

  Future<void> logSettingsHijriCorrectionChanged(String correction) {
    final value = AnalyticsEventNames.hijriCorrectionValue(correction);
    return _logEvent(
      name: AnalyticsEventNames.settingsHijriCorrectionChangedTo(correction),
      parameters: {'hijri_correction': value},
    );
  }

  // Settings - engagement
  Future<void> logSettingsFeedbackTapped() =>
      _logEvent(name: AnalyticsEventNames.settingsFeedbackTapped);

  Future<void> logSettingsRateAppTapped() =>
      _logEvent(name: AnalyticsEventNames.settingsRateAppTapped);

  Future<void> logSettingsShareAppTapped() =>
      _logEvent(name: AnalyticsEventNames.settingsShareAppTapped);

  // 16-Line Quran - Download events
  Future<void> logQuranJuzDownloadStarted(int juzNumber) => _logEvent(
    name: AnalyticsEventNames.quranJuzDownloadStarted,
    parameters: {'juz_number': juzNumber},
  );

  Future<void> logQuranJuzDownloadCompleted(int juzNumber) => _logEvent(
    name: AnalyticsEventNames.quranJuzDownloadCompleted,
    parameters: {'juz_number': juzNumber},
  );

  Future<void> logQuranJuzDownloadFailed(int juzNumber, String error) =>
      _logEvent(
        name: AnalyticsEventNames.quranJuzDownloadFailed,
        parameters: {'juz_number': juzNumber, 'error': error},
      );

  // 16-Line Quran - Cache/File events
  Future<void> logQuranJuzFileChecked(int juzNumber, bool exists) => _logEvent(
    name: AnalyticsEventNames.quranJuzFileChecked,
    parameters: {'juz_number': juzNumber, 'exists': exists ? 1 : 0},
  );

  Future<void> logQuranJuzCacheSync(
    int juzNumber,
    bool wasMarkedDownloaded,
    bool fileExists,
  ) => _logEvent(
    name: AnalyticsEventNames.quranJuzCacheSync,
    parameters: {
      'juz_number': juzNumber,
      'was_marked_downloaded': wasMarkedDownloaded ? 1 : 0,
      'file_exists': fileExists ? 1 : 0,
    },
  );

  // 16-Line Quran - View events
  Future<void> logQuranJuzViewed(int juzNumber) => _logEvent(
    name: AnalyticsEventNames.quranJuzViewed,
    parameters: {'juz_number': juzNumber},
  );

  Future<void> logQuranJuzSwitched(int fromJuz, int toJuz) => _logEvent(
    name: AnalyticsEventNames.quranJuzSwitched,
    parameters: {'from_juz': fromJuz, 'to_juz': toJuz},
  );

  // Generic screen view logging
  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  // Asma ul Husna video events
  Future<void> logAsmaUlHusnaVideosDialogOpened(String name) => _logEvent(
    name: AnalyticsEventNames.asmaUlHusnaVideosDialogOpened,
    parameters: {'name': name},
  );

  Future<void> logAsmaUlHusnaVideoPlayed(String name) => _logEvent(
    name: AnalyticsEventNames.asmaUlHusnaVideoPlayed,
    parameters: {'name': name},
  );
}
