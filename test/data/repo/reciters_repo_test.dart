import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rafeeq/data/repo/recitors_repo.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late RecitersRepo repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rxPrefs = RxSharedPreferences(
      prefs,
      const RxSharedPreferencesDefaultLogger(),
    );

    container = ProviderContainer(
      overrides: [rxSharedPreferencesProvider.overrideWithValue(rxPrefs)],
    );

    repo = container.read(recitersRepoProvider);
  });

  tearDown(() => container.dispose());

  group('RecitersRepo - Reciter', () {
    test('getReciter() returns first reciter when nothing is stored', () async {
      final reciter = await repo.getReciter();
      expect(reciter, kAllRecitersList.first);
    });

    test('setReciter() persists and getReciter() retrieves it', () async {
      final target = Reciter.alafasy;
      await repo.setReciter(target);
      final result = await repo.getReciter();
      expect(result, target);
    });

    test('getReciterStream() emits updated reciter on change', () async {
      final target = Reciter.alafasy;

      expectLater(
        repo.getReciterStream(),
        emitsInOrder([kAllRecitersList.first, target]),
      );

      await repo.setReciter(target);
    });
  });

  group('RecitersRepo - SurahReciter', () {
    test('getSurahReciter() returns first when nothing is stored', () async {
      final reciter = await repo.getSurahReciter();
      expect(reciter, SurahReciter.values.first);
    });

    test(
      'setSurahReciter() persists and getSurahReciter() retrieves it',
      () async {
        final target = SurahReciter.misharyrashidalafasy;
        await repo.setSurahReciter(target);
        final result = await repo.getSurahReciter();
        expect(result, target);
      },
    );

    test('getSurahReciterStream() emits updated reciter on change', () async {
      final target = SurahReciter.misharyrashidalafasy;

      expectLater(
        repo.getSurahReciterStream(),
        emitsInOrder([SurahReciter.values.first, target]),
      );

      await repo.setSurahReciter(target);
    });
  });
}
