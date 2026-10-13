import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/models/user_location.dart';

void main() {
  test('legacy saved locations default to automatic source', () {
    final location = UserLocation.fromMap(const {
      'latitude': 32.9405,
      'longitude': 73.7276,
      'city': 'Jhelum',
      'country': 'Pakistan',
    });

    expect(location.source, UserLocationSource.automatic);
    expect(location.countryCode, isNull);
  });

  test('manual location source survives serialization', () {
    const location = UserLocation(
      32.9405,
      73.7276,
      city: 'Jhelum',
      country: 'Pakistan',
      countryCode: 'PK',
      source: UserLocationSource.manual,
    );

    expect(UserLocation.fromMap(location.toMap()), location);
    expect(location.toMap()['countryCode'], 'PK');
  });
}
