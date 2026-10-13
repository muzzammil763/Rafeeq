import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rafeeq/data/services/country_city_service.dart';

void main() {
  test('loads and caches countries and per-country cities', () async {
    var countryRequests = 0;
    var cityRequests = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/metadata/countries.json')) {
        countryRequests++;
        return http.Response(
          '[{"name":"Pakistan","iso2":"PK","emoji":"🇵🇰"},'
          '{"name":"United Arab Emirates","iso2":"AE","emoji":"🇦🇪"}]',
          HttpStatus.ok,
          headers: const {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      }
      if (request.url.path.endsWith('/flat-cities/PK.json')) {
        cityRequests++;
        return http.Response(
          '["Lahore","Jhelum","Karachi","Jhelum"]',
          HttpStatus.ok,
        );
      }
      return http.Response('Not found', HttpStatus.notFound);
    });
    final service = CountryCityService(client: client);

    final countries = await service.fetchCountries();
    final cities = await service.fetchCities('pk');
    await service.fetchCountries();
    await service.fetchCities('PK');

    expect(countries.map((country) => country.code), ['PK', 'AE']);
    expect(cities, ['Jhelum', 'Karachi', 'Lahore']);
    expect(countryRequests, 1);
    expect(cityRequests, 1);
  });

  test('reports non-success responses', () async {
    final service = CountryCityService(
      client: MockClient(
        (request) async =>
            http.Response('Unavailable', HttpStatus.serviceUnavailable),
      ),
    );

    expect(service.fetchCountries(), throwsA(isA<HttpException>()));
  });

  test('rejects an invalid country code before requesting cities', () async {
    final service = CountryCityService(
      client: MockClient((request) async => http.Response('[]', HttpStatus.ok)),
    );

    expect(service.fetchCities('../PK'), throwsA(isA<FormatException>()));
  });
}
