import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  testWidgets('groups settings into titled sections in order', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 6000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsProvider.overrideWithValue(_MockFirebaseAnalytics()),
          packageInfoProvider.overrideWithValue(
            PackageInfo(
              appName: 'Rafeeq',
              packageName: 'com.satechdev.rafeeqapp',
              version: '1.2.21',
              buildNumber: '50',
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    double top(String text) => tester.getTopLeft(find.text(text).first).dy;

    // Each section title sits above its first tile, and sections follow the
    // expected order down the page.
    final order = [
      'General',
      'Language',
      'Prayer & Calendar',
      'Calculation Method',
      "Qur'an",
      'Support Rafeeq',
      'Report an issue',
      'Contribute',
      'Our other apps',
      '99 Names',
      'Quran Khatam Tracker',
      'Budget AI',
      'FM Crafts',
      'App info',
      'Licenses',
      'About',
    ];
    for (var i = 1; i < order.length; i++) {
      expect(
        top(order[i - 1]),
        lessThan(top(order[i])),
        reason: '${order[i - 1]} should come before ${order[i]}',
      );
    }
  });
}
