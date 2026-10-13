import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/prefs.dart';

import '../test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = await setupTestContainer();
  });

  tearDown(() => clearSharedPreferences(container));

  group('Prefs - isQuranAutoScrollEnabled', () {
    test('defaults to true when no value is stored', () {
      final prefs = container.read(prefsProvider);
      expect(prefs.isQuranAutoScrollEnabled, isTrue);
    });

    test('returns false after setting it to false', () async {
      final prefs = container.read(prefsProvider);
      await prefs.setQuranAutoScrollEnabled(false);
      expect(prefs.isQuranAutoScrollEnabled, isFalse);
    });

    test('returns true after setting it to true', () async {
      final prefs = container.read(prefsProvider);
      await prefs.setQuranAutoScrollEnabled(false);
      await prefs.setQuranAutoScrollEnabled(true);
      expect(prefs.isQuranAutoScrollEnabled, isTrue);
    });
  });
}
