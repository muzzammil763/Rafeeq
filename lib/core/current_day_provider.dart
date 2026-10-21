import 'dart:async';

import 'package:clock/clock.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The current local calendar day, as a date-only [DateTime].
///
/// Invalidates itself at the next local midnight so everything derived from
/// the date refreshes without a restart. Invalidate it on app resume as well,
/// since timers don't fire while the app is suspended.
final currentDayProvider = Provider.autoDispose<DateTime>((ref) {
  final now = clock.now();
  final today = DateTime(now.year, now.month, now.day);
  final timer = Timer(
    DateTime(now.year, now.month, now.day + 1).difference(now),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
  return today;
});
