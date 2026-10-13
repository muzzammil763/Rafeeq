import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/services/analytics_event_names.dart';

void main() {
  test('uses explicit language-change event names', () {
    expect(
      AnalyticsEventNames.settingsLanguageChangedTo('en'),
      'settings_language_changed_to_english',
    );
    expect(
      AnalyticsEventNames.settingsLanguageChangedTo('ur'),
      'settings_language_changed_to_urdu',
    );
  });

  test('uses explicit theme-change event names', () {
    expect(
      AnalyticsEventNames.settingsThemeChangedTo('light'),
      'settings_theme_changed_to_light',
    );
    expect(
      AnalyticsEventNames.settingsThemeChangedTo('dark'),
      'settings_theme_changed_to_dark',
    );
    expect(
      AnalyticsEventNames.settingsThemeChangedTo('system'),
      'settings_theme_changed_to_system',
    );
  });

  test('uses explicit location event names', () {
    expect(
      AnalyticsEventNames.settingsLocationChangedToAutomatic,
      'settings_location_to_automatic',
    );
    expect(
      AnalyticsEventNames.settingsLocationChangedToManual,
      'settings_location_to_manual',
    );
  });

  test('uses explicit prayer-setting event names', () {
    expect(
      AnalyticsEventNames.settingsCalculationMethodChangedTo('karachi'),
      'calc_method_to_karachi',
    );
    expect(
      AnalyticsEventNames.settingsJuristicMethodChangedTo('hanafi'),
      'juristic_method_to_hanafi',
    );
    expect(
      AnalyticsEventNames.settingsJuristicMethodChangedTo('others'),
      'juristic_method_to_standard',
    );
    expect(
      AnalyticsEventNames.settingsHijriCorrectionChangedTo('plus1Day'),
      'hijri_correction_to_plus_1_day',
    );
    expect(
      AnalyticsEventNames.settingsHighLatitudeRuleChangedTo('middleOfTheNight'),
      'high_latitude_rule_to_middle_of_night',
    );
  });

  test('all custom event names satisfy Firebase naming limits', () {
    final validEventName = RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,39}$');

    for (final eventName in AnalyticsEventNames.all) {
      expect(validEventName.hasMatch(eventName), isTrue, reason: eventName);
      expect(eventName.startsWith('firebase_'), isFalse, reason: eventName);
      expect(eventName.startsWith('google_'), isFalse, reason: eventName);
      expect(eventName.startsWith('ga_'), isFalse, reason: eventName);
    }
  });
}
