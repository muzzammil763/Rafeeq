import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/ui/app_home/home/home_prayer_data.dart';

import '../../test_helpers.dart';

void main() {
  const location = UserLocation(21.4225, 39.8262);

  test('prayerTimesProvider rolls over to the new day at midnight', () {
    fakeAsync(initialTime: DateTime(2026, 3, 10, 22), (async) {
      setupTestContainer().then((container) {
        addTearDown(container.dispose);
        // The home screen keeps this provider alive while it is mounted.
        final subscription = container.listen(
          prayerTimesProvider(location),
          (_, _) {},
        );
        addTearDown(subscription.close);

        expect(subscription.read().dateComponents.day, 10);

        async.elapse(const Duration(hours: 4));

        final today = subscription.read().dateComponents;
        expect((today.year, today.month, today.day), (2026, 3, 11));
      });
      async.flushMicrotasks();
    });
  });
}
