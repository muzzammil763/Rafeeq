import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One occurrence of an event: a particular Friday, this year's Ramadan or
/// this year's Eid. The dialog shows once per occurrence.
class HomeEventOccurrence {
  const HomeEventOccurrence(this.event, this.id);

  final HomeEvent event;
  final String id;
}

/// The events to greet the user with today: real ones from the calendar plus
/// any turned on in the developer panel.
List<HomeEventOccurrence> homeEventsOn(
  DateTime now,
  HijriCalendar hijri,
  Set<HomeEvent> previews,
) {
  final isEid =
      (hijri.hMonth == 10 && hijri.hDay == 1) ||
      (hijri.hMonth == 12 && hijri.hDay == 10);
  return [
    if (now.weekday == DateTime.friday || previews.contains(HomeEvent.friday))
      HomeEventOccurrence(
        HomeEvent.friday,
        'friday-${now.year}-${now.month}-${now.day}',
      ),
    if (hijri.hMonth == 9 || previews.contains(HomeEvent.ramadan))
      HomeEventOccurrence(HomeEvent.ramadan, 'ramadan-${hijri.hYear}'),
    if (isEid || previews.contains(HomeEvent.eid))
      HomeEventOccurrence(HomeEvent.eid, 'eid-${hijri.hYear}-${hijri.hMonth}'),
  ];
}

/// Remembers which event dialogs the user has closed. Only the latest
/// occurrence of each event is kept, so old entries don't pile up.
class HomeEventDialogTracker {
  const HomeEventDialogTracker(this._preferences);

  final SharedPreferences _preferences;

  static String _key(HomeEvent event) => 'home_event_dialog_seen_${event.name}';

  bool wasSeen(HomeEventOccurrence occurrence) =>
      _preferences.getString(_key(occurrence.event)) == occurrence.id;

  Future<void> markSeen(HomeEventOccurrence occurrence) =>
      _preferences.setString(_key(occurrence.event), occurrence.id);

  /// Lets the dialog for [event] show again, for testing from the developer
  /// panel.
  Future<void> reset(HomeEvent event) => _preferences.remove(_key(event));
}

final homeEventDialogTrackerProvider = Provider<HomeEventDialogTracker>(
  (ref) => HomeEventDialogTracker(ref.watch(sharedPreferencesProvider)),
);
