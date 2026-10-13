import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

enum FastingStatus {
  none,
  fasting,
  missed;

  String getLabel(BuildContext context) {
    switch (this) {
      case FastingStatus.none:
        return context.loc.statusNone;
      case FastingStatus.fasting:
        return context.loc.statusFasting;
      case FastingStatus.missed:
        return context.loc.statusMissed;
    }
  }

  Color getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case FastingStatus.none:
        return colorScheme.outline.withValues(alpha: 0.3);
      case FastingStatus.fasting:
        return colorScheme.primary;
      case FastingStatus.missed:
        return Colors.red;
    }
  }

  IconData getIcon() {
    switch (this) {
      case FastingStatus.none:
        return Icons.circle_outlined;
      case FastingStatus.fasting:
        return Icons.check_circle_rounded;
      case FastingStatus.missed:
        return Icons.cancel_rounded;
    }
  }
}

class FastingRepository {
  final RxSharedPreferences _prefs;

  FastingRepository(this._prefs);

  String _getKey(DateTime date) =>
      'fasting_status_${date.toIso8601String().substring(0, 10)}';

  Future<void> setStatus(DateTime date, FastingStatus status) async {
    final key = _getKey(date);
    if (status == FastingStatus.none) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, status.name);
    }
  }

  Stream<FastingStatus> watchStatus(DateTime date) {
    final key = _getKey(date);
    return _prefs.getStringStream(key).map((value) {
      if (value == null) return FastingStatus.none;
      return FastingStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => FastingStatus.none,
      );
    });
  }

  Future<FastingStatus> getStatus(DateTime date) async {
    final key = _getKey(date);
    final value = await _prefs.getString(key);
    if (value == null) return FastingStatus.none;
    return FastingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FastingStatus.none,
    );
  }

  Future<Map<FastingStatus, int>> getStatsForRange(List<DateTime> dates) async {
    final stats = <FastingStatus, int>{
      FastingStatus.fasting: 0,
      FastingStatus.missed: 0,
      FastingStatus.none: 0,
    };

    for (final date in dates) {
      final status = await getStatus(date);
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }
}

final fastingRepositoryProvider = Provider((ref) {
  return FastingRepository(ref.watch(rxSharedPreferencesProvider));
});

final fastingStatusProvider = StreamProvider.family<FastingStatus, DateTime>((
  ref,
  date,
) {
  return ref.watch(fastingRepositoryProvider).watchStatus(date);
});
