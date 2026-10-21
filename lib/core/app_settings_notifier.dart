import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/current_day_provider.dart';
import 'package:rafeeq/data/models/hijri_correction.dart';
import 'package:rafeeq/data/storage/storage_box.dart';

final appSettingsStorageBoxProvider = Provider<StorageBox<AppSettings>>((ref) {
  final factory = ref.watch(storageBoxProvider);
  return factory.create<AppSettings>(
    "app_settings",
    encoder: (AppSettings value) => jsonEncode(value.toMap()),
    decoder: (String value) => AppSettings.fromSharedPrefsString(value),
    defaultValue: const AppSettings(
      language: AppLanguage.en,
      hijriCorrection: HijriCorrection.none,
      themeMode: ThemeMode.dark,
      themeIndex: 0,
      ramadanViewMode: 0,
    ),
  );
});

final appSettingsNotifierProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

final correctedDateTimeProvider = Provider.autoDispose<DateTime>((ref) {
  final hijriCorrection = ref.watch(
    appSettingsNotifierProvider.select((e) => e.hijriCorrection),
  );
  // Re-evaluate when the day changes so the Hijri date doesn't go stale.
  ref.watch(currentDayProvider);
  return clock.now().getAdjusted(hijriCorrection);
});

class AppSettingsNotifier extends Notifier<AppSettings> {
  late final StorageBox<AppSettings> _storageBox;

  @override
  AppSettings build() {
    _storageBox = ref.watch(appSettingsStorageBoxProvider);
    return _storageBox.get();
  }

  @override
  set state(AppSettings value) {
    super.state = value;
    _storageBox.set(value);
  }

  void setThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void setHijriCorrection(HijriCorrection hijriCorrection) {
    state = state.copyWith(hijriCorrection: hijriCorrection);
  }

  void setThemeIndex(int index) {
    state = state.copyWith(themeIndex: index);
  }

  void setRamadanViewMode(int mode) {
    state = state.copyWith(ramadanViewMode: mode);
  }

  void setEventPreview(HomeEvent event, bool enabled) {
    state = state.copyWith(
      eventPreviews: enabled
          ? {...state.eventPreviews, event}
          : state.eventPreviews.difference({event}),
    );
  }
}

/// Special days that get their own card on home.
enum HomeEvent { friday, ramadan, eid }

class AppSettings {
  final AppLanguage language;
  final HijriCorrection hijriCorrection;
  final ThemeMode themeMode;
  final int themeIndex;
  final int ramadanViewMode;

  /// Developer toggles that preview an event's dialog on any day.
  final Set<HomeEvent> eventPreviews;

  const AppSettings({
    required this.language,
    required this.hijriCorrection,
    this.themeMode = ThemeMode.dark,
    this.themeIndex = 0,
    this.ramadanViewMode = 0,
    this.eventPreviews = const {},
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? useMaterial3,
    HijriCorrection? hijriCorrection,
    int? themeIndex,
    int? ramadanViewMode,
    Set<HomeEvent>? eventPreviews,
  }) {
    return AppSettings(
      language: language ?? this.language,
      hijriCorrection: hijriCorrection ?? this.hijriCorrection,
      themeMode: themeMode ?? this.themeMode,
      themeIndex: themeIndex ?? this.themeIndex,
      ramadanViewMode: ramadanViewMode ?? this.ramadanViewMode,
      eventPreviews: eventPreviews ?? this.eventPreviews,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language.languageCode,
      'hijriCorrection': hijriCorrection.name,
      'themeMode': themeMode.name,
      'themeIndex': themeIndex,
      'ramadanViewMode': ramadanViewMode,
      'eventPreviews': [for (final event in eventPreviews) event.name],
    };
  }

  String toSharedPrefsString() => jsonEncode(toMap());

  factory AppSettings.fromSharedPrefsString(String? prefsValue) {
    if (prefsValue != null && prefsValue.isNotEmpty) {
      try {
        final map = jsonDecode(prefsValue) as Map<String, dynamic>;
        AppLanguage language = map['language'] != null
            ? AppLanguage.values.firstWhere(
                (element) => element.languageCode == map['language'],
                orElse: () => AppLanguage.en,
              )
            : AppLanguage.en;
        final hijriCorrection = map['hijriCorrection'] != null
            ? HijriCorrection.values.firstWhere(
                (element) => element.name == map['hijriCorrection'],
                orElse: () => HijriCorrection.none,
              )
            : HijriCorrection.none;
        final themeIndex = map['themeIndex'] as int? ?? 0;
        final themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == map['themeMode'],
          orElse: () => ThemeMode.dark,
        );
        final ramadanViewMode = map['ramadanViewMode'] as int? ?? 0;
        final eventPreviews = {
          for (final name in map['eventPreviews'] as List? ?? const [])
            ...HomeEvent.values.where((event) => event.name == name),
        };

        return AppSettings(
          language: language,
          hijriCorrection: hijriCorrection,
          themeMode: themeMode,
          themeIndex: themeIndex,
          ramadanViewMode: ramadanViewMode,
          eventPreviews: eventPreviews,
        );
      } catch (e) {
        debugPrint('Error parsing AppSettingsState from shared prefs: $e');
      }
    }

    return const AppSettings(
      language: AppLanguage.en,
      hijriCorrection: HijriCorrection.none,
      themeMode: ThemeMode.dark,
      themeIndex: 0,
    );
  }
}

enum AppLanguage {
  en('en', 'English'),
  ur('ur', 'اردو');

  final String languageCode;
  final String label;

  const AppLanguage(this.languageCode, this.label);
}
