import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/qibla/qibla_compass.dart';
import 'package:rafeeq/ui/qibla/qibla_screen.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QiblaAlignment', () {
    test('recognizes an aligned direction', () {
      expect(
        QiblaAlignment.fromAngle(358).direction,
        QiblaTurnDirection.aligned,
      );
    });

    test('reports the shortest left turn', () {
      final alignment = QiblaAlignment.fromAngle(85);

      expect(alignment.direction, QiblaTurnDirection.left);
      expect(alignment.degrees, 85);
    });

    test('reports the shortest right turn', () {
      final alignment = QiblaAlignment.fromAngle(275);

      expect(alignment.direction, QiblaTurnDirection.right);
      expect(alignment.degrees, 85);
    });
  });

  testWidgets('uses the shared app bar and shows the saved location', (
    tester,
  ) async {
    const location = UserLocation(
      32.89,
      73.76,
      city: 'Sarai Alamgir',
      country: 'Pakistan',
    );
    SharedPreferences.setMockInitialValues({
      UserLocation.prefsKey: jsonEncode(location.toMap()),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          compassSupportedProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const QiblaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RafeeqAppBar), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Sarai Alamgir, Pakistan'), findsOneWidget);
    expect(find.text('Compass not supported on this device'), findsOneWidget);
  });

  testWidgets('minimal compass dial renders cardinal points and Qibla marker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: QiblaCompassDial(
              size: 300,
              heading: 0,
              qiblahAngle: 85,
              palette: SettingsPalette.light,
            ),
          ),
        ),
      ),
    );

    for (final cardinal in ['N', 'E', 'S', 'W']) {
      expect(find.text(cardinal), findsOneWidget);
    }
    expect(find.byIcon(FlutterIslamicIcons.solidKaaba), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
