import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/core/app_theme.dart';
import 'package:rafeeq/core/providers.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/core/navigation/analytics_observer.dart';
import 'package:rafeeq/core/navigation/analytics_screen_names.dart';
import 'package:rafeeq/core/navigation/app_router.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/data/app_database/app_database.dart';
import 'package:rafeeq/l10n/app_localizations.dart';
import 'package:rafeeq/ui/app_home/home/app_home_screen.dart';
import 'package:rafeeq/ui/onboarding/onboarding_screen.dart';
import 'package:rafeeq/ui/quran/quran_player_overlay.dart';
import 'package:rafeeq/data/namaz_prayers_data.dart';
import 'package:rafeeq/data/raw/namaz_prayers_raw.dart';
import 'package:rafeeq/data/raw/wudu_steps_raw.dart';

import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rafeeq/ui/prayer_times/prayer_notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load and initialize Namaz Prayers data from JSON string
  initializeNamazPrayers(namazPrayersJson);

  // Load and initialize Wudu steps data from JSON string
  initializeWuduSteps(wuduStepsJson);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Firebase.initializeApp();

  final analytics = FirebaseAnalytics.instance;

  // Initialize Firebase Analytics and Crashlytics only in release mode
  if (kReleaseMode) {
    await analytics.setAnalyticsCollectionEnabled(true);

    // Initialize Crashlytics and pass all uncaught errors to it
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    await analytics.setAnalyticsCollectionEnabled(false);
  }

  final packageInfo = await PackageInfo.fromPlatform();

  final dbDir = await getApplicationDocumentsDirectory();
  final database = await AppDatabase.open(path: '${dbDir.path}/rafeeq_db');
  final sharedPreferences = await SharedPreferences.getInstance();
  final rxSharedPreferences = RxSharedPreferences(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        rxSharedPreferencesProvider.overrideWithValue(rxSharedPreferences),
        analyticsProvider.overrideWithValue(analytics),
        packageInfoProvider.overrideWithValue(packageInfo),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Initialize notification manager
    ref.watch(prayerNotificationManagerProvider);

    var appSettingsState = ref.watch(appSettingsNotifierProvider);
    final language = appSettingsState.language;
    final onboardingCompleted =
        ref
            .watch(sharedPreferencesProvider)
            .getBool('onboarding_completed_v2') ??
        false;

    // Create navigator observers with access to the provider container
    final navigatorObservers = <NavigatorObserver>[
      AnalyticsNavigatorObserver(
        ref,
        initialScreenName: onboardingCompleted
            ? AnalyticsScreenNames.home
            : AnalyticsScreenNames.onboarding,
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.loc.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: onboardingCompleted
          ? const AppHomeScreen()
          : const OnboardingScreen(),
      locale: Locale(language.languageCode, ''),
      theme: AppTheme.getTheme(
        appSettingsState.themeIndex,
        languageCode: language.languageCode,
        brightness: Brightness.light,
      ),
      darkTheme: AppTheme.getTheme(
        appSettingsState.themeIndex,
        languageCode: language.languageCode,
        brightness: Brightness.dark,
      ),
      themeMode: appSettingsState.themeMode,
      builder: (context, child) {
        final content = QuranPlayerHost(
          child: child ?? const SizedBox.shrink(),
        );
        if (language != AppLanguage.ur) return content;

        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _AdditiveTextScaler(mediaQuery.textScaler, 6),
          ),
          child: content,
        );
      },
    );
  }
}

@immutable
class _AdditiveTextScaler extends TextScaler {
  const _AdditiveTextScaler(this.base, this.additionalPixels);

  final TextScaler base;
  final double additionalPixels;

  @override
  double scale(double fontSize) => base.scale(fontSize) + additionalPixels;

  @override
  double get textScaleFactor => 1;

  @override
  bool operator ==(Object other) =>
      other is _AdditiveTextScaler &&
      other.base == base &&
      other.additionalPixels == additionalPixels;

  @override
  int get hashCode => Object.hash(base, additionalPixels);
}
