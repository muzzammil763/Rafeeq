import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/models/fasting_data.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late FastingRepository repo;
  late RxSharedPreferences rxPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    rxPrefs = RxSharedPreferences(
      prefs,
      const RxSharedPreferencesDefaultLogger(),
    );

    container = ProviderContainer(
      overrides: [rxSharedPreferencesProvider.overrideWithValue(rxPrefs)],
    );

    repo = container.read(fastingRepositoryProvider);
  });

  tearDown(() => container.dispose());

  group('FastingStatus enum', () {
    test('has three values: none, fasting, missed', () {
      expect(FastingStatus.values, hasLength(3));
      expect(FastingStatus.values, contains(FastingStatus.none));
      expect(FastingStatus.values, contains(FastingStatus.fasting));
      expect(FastingStatus.values, contains(FastingStatus.missed));
    });
  });

  group('FastingRepository - setStatus and getStatus', () {
    test('getStatus returns none when nothing is stored', () async {
      final date = DateTime(2024, 3, 15);
      final status = await repo.getStatus(date);
      expect(status, FastingStatus.none);
    });

    test('setStatus persists and getStatus retrieves fasting status', () async {
      final date = DateTime(2024, 3, 15);
      await repo.setStatus(date, FastingStatus.fasting);
      final result = await repo.getStatus(date);
      expect(result, FastingStatus.fasting);
    });

    test('setStatus persists and getStatus retrieves missed status', () async {
      final date = DateTime(2024, 3, 15);
      await repo.setStatus(date, FastingStatus.missed);
      final result = await repo.getStatus(date);
      expect(result, FastingStatus.missed);
    });

    test('setStatus with none removes the key', () async {
      final date = DateTime(2024, 3, 15);
      await repo.setStatus(date, FastingStatus.fasting);
      await repo.setStatus(date, FastingStatus.none);
      final result = await repo.getStatus(date);
      expect(result, FastingStatus.none);
    });

    test('different dates have independent statuses', () async {
      final date1 = DateTime(2024, 3, 15);
      final date2 = DateTime(2024, 3, 16);

      await repo.setStatus(date1, FastingStatus.fasting);
      await repo.setStatus(date2, FastingStatus.missed);

      expect(await repo.getStatus(date1), FastingStatus.fasting);
      expect(await repo.getStatus(date2), FastingStatus.missed);
    });
  });

  group('FastingRepository - watchStatus', () {
    test('emits none initially when nothing is stored', () async {
      final date = DateTime(2024, 3, 15);

      expectLater(repo.watchStatus(date), emits(FastingStatus.none));
    });

    test('emits updated status when changed', () async {
      final date = DateTime(2024, 3, 15);

      expectLater(
        repo.watchStatus(date),
        emitsInOrder([FastingStatus.none, FastingStatus.fasting]),
      );

      await repo.setStatus(date, FastingStatus.fasting);
    });

    test('emits multiple status changes', () async {
      final date = DateTime(2024, 3, 15);

      expectLater(
        repo.watchStatus(date),
        emitsInOrder([
          FastingStatus.none,
          FastingStatus.fasting,
          FastingStatus.missed,
          FastingStatus.none,
        ]),
      );

      await repo.setStatus(date, FastingStatus.fasting);
      await repo.setStatus(date, FastingStatus.missed);
      await repo.setStatus(date, FastingStatus.none);
    });
  });

  group('FastingRepository - getStatsForRange', () {
    test('returns all zeros for empty date list', () async {
      final stats = await repo.getStatsForRange([]);
      expect(stats[FastingStatus.fasting], 0);
      expect(stats[FastingStatus.missed], 0);
      expect(stats[FastingStatus.none], 0);
    });

    test('counts fasting statuses correctly', () async {
      final dates = [
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 16),
        DateTime(2024, 3, 17),
      ];

      await repo.setStatus(dates[0], FastingStatus.fasting);
      await repo.setStatus(dates[1], FastingStatus.fasting);
      await repo.setStatus(dates[2], FastingStatus.none);

      final stats = await repo.getStatsForRange(dates);
      expect(stats[FastingStatus.fasting], 2);
      expect(stats[FastingStatus.missed], 0);
      expect(stats[FastingStatus.none], 1);
    });

    test('counts mixed statuses correctly', () async {
      final dates = [
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 16),
        DateTime(2024, 3, 17),
        DateTime(2024, 3, 18),
        DateTime(2024, 3, 19),
      ];

      await repo.setStatus(dates[0], FastingStatus.fasting);
      await repo.setStatus(dates[1], FastingStatus.missed);
      await repo.setStatus(dates[2], FastingStatus.fasting);
      await repo.setStatus(dates[3], FastingStatus.none);
      // dates[4] stays as none (default)

      final stats = await repo.getStatsForRange(dates);
      expect(stats[FastingStatus.fasting], 2);
      expect(stats[FastingStatus.missed], 1);
      expect(stats[FastingStatus.none], 2);
    });

    test('handles all missed statuses', () async {
      final dates = [DateTime(2024, 3, 15), DateTime(2024, 3, 16)];

      await repo.setStatus(dates[0], FastingStatus.missed);
      await repo.setStatus(dates[1], FastingStatus.missed);

      final stats = await repo.getStatsForRange(dates);
      expect(stats[FastingStatus.fasting], 0);
      expect(stats[FastingStatus.missed], 2);
      expect(stats[FastingStatus.none], 0);
    });
  });

  group('fastingRepositoryProvider', () {
    test('provides a FastingRepository instance', () {
      final repository = container.read(fastingRepositoryProvider);
      expect(repository, isA<FastingRepository>());
    });
  });

  group('fastingStatusProvider', () {
    test('provides an AsyncValue of FastingStatus', () {
      final date = DateTime(2024, 3, 15);
      final asyncValue = container.read(fastingStatusProvider(date));
      expect(asyncValue, isA<AsyncValue<FastingStatus>>());
    });

    test('emits loading then data with none as initial value', () async {
      final date = DateTime(2024, 3, 15);
      final subscription = container.listen(
        fastingStatusProvider(date),
        (previous, next) {},
      );

      // Wait a bit for the stream to emit
      await Future.delayed(const Duration(milliseconds: 50));

      final asyncValue = container.read(fastingStatusProvider(date));
      expect(asyncValue, isA<AsyncData<FastingStatus>>());
      expect(asyncValue.value, FastingStatus.none);

      subscription.close();
    });
  });
}
