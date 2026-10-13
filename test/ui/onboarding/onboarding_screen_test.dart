import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/services/notification_service.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/onboarding/onboarding_screen.dart';
import 'package:rafeeq/ui/prayer_times/user_location_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestNotificationService extends NotificationService {
  int permissionRequests = 0;

  @override
  Future<void> init() async {}

  @override
  Future<bool?> requestPermissions() async {
    permissionRequests++;
    return false;
  }
}

class _TestUserLocationNotifier extends UserLocationNotifier {
  int automaticRequests = 0;

  @override
  build() => null;

  @override
  Future<void> autoRequestLocationIfNeeded() async {
    automaticRequests++;
  }
}

Future<ProviderContainer> _pumpOnboarding(
  WidgetTester tester, {
  NotificationService? notificationService,
  bool useTestLocationNotifier = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        if (notificationService != null)
          notificationServiceProvider.overrideWithValue(notificationService),
        if (useTestLocationNotifier)
          userLocationNotifierProvider.overrideWith(
            _TestUserLocationNotifier.new,
          ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(OnboardingScreen)),
  );
}

void main() {
  testWidgets('starts with the minimal app introduction', (tester) async {
    await _pumpOnboarding(tester);

    expect(
      find.text('Rafeeq - Your Daily Muslim Companion', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/onboarding/welcome.png')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding == const EdgeInsets.only(top: 12, bottom: 64),
      ),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('moves from language to notifications', (tester) async {
    await _pumpOnboarding(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Select a Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Allow Notifications'), findsOneWidget);
    expect(find.text("It's time for the Dhuhr prayer"), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('notification skip continues to location', (tester) async {
    await _pumpOnboarding(
      tester,
      notificationService: _TestNotificationService(),
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Allow Location'), findsOneWidget);
    expect(find.text('Manual Location'), findsOneWidget);
  });

  testWidgets('notification allow requests permission and continues', (
    tester,
  ) async {
    final service = _TestNotificationService();
    await _pumpOnboarding(tester, notificationService: service);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(service.permissionRequests, 1);
    expect(find.text('Location'), findsOneWidget);
  });

  testWidgets('location next automatically requests and denial continues', (
    tester,
  ) async {
    final container = await _pumpOnboarding(
      tester,
      notificationService: _TestNotificationService(),
      useTestLocationNotifier: true,
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final locationNotifier =
        container.read(userLocationNotifierProvider.notifier)
            as _TestUserLocationNotifier;
    expect(locationNotifier.automaticRequests, 1);
    expect(find.text('Juristic Method'), findsOneWidget);
  });
}
