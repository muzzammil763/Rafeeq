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
    test('show all cards defaults to false', () {
      expect(container.read(appSettingsNotifierProvider).showAllCards, isFalse);
    });

    test('show all cards updates and persists', () {
      container
          .read(appSettingsNotifierProvider.notifier)
          .toggleShowAllCards(true);

      final storedValue = container
          .read(sharedPreferencesProvider)
          .getString('app_settings');
      expect(container.read(appSettingsNotifierProvider).showAllCards, isTrue);
      expect(storedValue, contains('"showAllCards":true'));
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
