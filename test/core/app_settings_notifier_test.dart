import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';

import '../test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = await setupTestContainer();
  });

  tearDown(() => clearSharedPreferences(container));

  group('AppSettings', () {
    test('event previews default to none', () {
      expect(
        container.read(appSettingsNotifierProvider).eventPreviews,
        isEmpty,
      );
    });

    test('event previews toggle independently and persist', () {
      final notifier = container.read(appSettingsNotifierProvider.notifier);
      notifier.setEventPreview(HomeEvent.friday, true);
      notifier.setEventPreview(HomeEvent.eid, true);
      notifier.setEventPreview(HomeEvent.friday, false);

      final storedValue = container
          .read(sharedPreferencesProvider)
          .getString('app_settings');
      expect(container.read(appSettingsNotifierProvider).eventPreviews, {
        HomeEvent.eid,
      });
      expect(storedValue, contains('"eventPreviews":["eid"]'));
    });

    test('theme mode updates and persists', () {
      container
          .read(appSettingsNotifierProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final storedValue = container
          .read(sharedPreferencesProvider)
          .getString('app_settings');
      expect(
        container.read(appSettingsNotifierProvider).themeMode,
        ThemeMode.light,
      );
      expect(storedValue, contains('"themeMode":"light"'));
    });
  });
}
