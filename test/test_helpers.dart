import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a ProviderContainer with mock SharedPreferences for testing.
///
/// Usage:
/// ```dart
/// final container = createTestContainer();
/// // Use container to read providers
/// ```
ProviderContainer createTestContainer([
  Map<String, Object> initialValues = const {},
]) {
  SharedPreferences.setMockInitialValues(initialValues);

  return ProviderContainer(
    overrides: [
      // SharedPreferences will be initialized when needed
    ],
  );
}

/// Sets up a fresh in-memory SharedPreferences instance and provides it as an override.
/// Call this in your test's setUp method.
Future<ProviderContainer> setupTestContainer([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();

  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

/// Creates a test ProviderScope widget for widget tests.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   createTestScope(
///     child: MyWidget(),
///     initialValues: {'key': 'value'},
///   ),
/// );
/// ```
Future<ProviderScope> createTestScope({
  required Widget child,
  Map<String, Object> initialValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: child,
  );
}

/// Clears all keys from the mock SharedPreferences after a test.
Future<void> clearSharedPreferences(ProviderContainer container) async {
  final prefs = container.read(sharedPreferencesProvider);
  await prefs.clear();
}
