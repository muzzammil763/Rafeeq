import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/storage/storage_box.dart';

import '../../test_helpers.dart';

void main() {
  late ProviderContainer container;
  late StorageBoxFactory boxFactory;

  setUp(() async {
    container = await setupTestContainer();
    boxFactory = container.read(storageBoxProvider);
  });

  tearDown(() => clearSharedPreferences(container));

  group('StorageBox', () {
    test('get() returns defaultValue when nothing is stored', () {
      final box = boxFactory.create<String>(
        'test_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'default',
      );
      expect(box.get(), 'default');
    });

    test('getOrNull() returns null when nothing is stored', () {
      final box = boxFactory.create<String>(
        'test_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'default',
      );
      expect(box.getOrNull(), isNull);
    });

    test('set() persists a value and get() retrieves it', () async {
      final box = boxFactory.create<String>(
        'test_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'default',
      );
      await box.set('hello');
      expect(box.get(), 'hello');
    });

    test('set() overwrites an existing value', () async {
      final box = boxFactory.create<String>(
        'test_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'default',
      );
      await box.set('first');
      await box.set('second');
      expect(box.get(), 'second');
    });

    test('different keys are independent', () async {
      final box1 = boxFactory.create<String>(
        'test_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'default',
      );
      final box2 = boxFactory.create<String>(
        'other_key',
        encoder: (v) => v,
        decoder: (v) => v,
        defaultValue: 'other_default',
      );

      await box1.set('alpha');
      await box2.set('beta');

      expect(box1.get(), 'alpha');
      expect(box2.get(), 'beta');
    });

    test(
      'getOrNull() returns null when stored value is empty string',
      () async {
        final box = boxFactory.create<String>(
          'test_key',
          encoder: (v) => v,
          decoder: (v) => v,
          defaultValue: 'default',
        );
        await box.set('');
        expect(box.getOrNull(), isNull);
      },
    );
  });
}
