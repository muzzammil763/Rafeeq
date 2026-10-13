import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rafeeq/data/app_database/app_database.dart';
import 'package:rafeeq/data/app_database/daos/quran_text_cache_dao.dart';

/// Provider for Firebase Analytics instance
final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  throw UnimplementedError(
    'analyticsProvider must be overridden with a real FirebaseAnalytics instance',
  );
});

/// Provider for PackageInfo instance
final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError(
    'packageInfoProvider must be overridden with a real PackageInfo instance',
  );
});

/// Provider for AppDatabase instance
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with a real AppDatabase instance',
  );
});

/// Provider for QuranTextCacheDao
final quranTextCacheDaoProvider = Provider<QuranTextCacheDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return QuranTextCacheDao(db.database);
});
