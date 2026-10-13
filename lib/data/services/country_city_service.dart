import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

const _locationDataBaseUrl =
    'https://cdn.jsdelivr.net/gh/srestre/'
    'world-countries-cities-db@main';

final countryCityServiceProvider = Provider<CountryCityService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return CountryCityService(client: client);
});

final countriesProvider = FutureProvider<List<CountryOption>>((ref) {
  return ref.watch(countryCityServiceProvider).fetchCountries();
});

final citiesProvider = FutureProvider.family<List<String>, String>((ref, code) {
  return ref.watch(countryCityServiceProvider).fetchCities(code);
});

class CountryOption {
  const CountryOption({
    required this.name,
    required this.code,
    required this.emoji,
  });

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    return CountryOption(
      name: json['name'] as String,
      code: (json['iso2'] as String).toUpperCase(),
      emoji: json['emoji'] as String? ?? '',
    );
  }

  final String name;
  final String code;
  final String emoji;
}

class CountryCityService {
  CountryCityService({required http.Client client}) : _client = client;

  final http.Client _client;
  List<CountryOption>? _countries;
  final Map<String, List<String>> _cities = {};

  Future<List<CountryOption>> fetchCountries() async {
    final cached = _countries;
    if (cached != null) return cached;

    final response = await _client.get(
      Uri.parse('$_locationDataBaseUrl/metadata/countries.json'),
      headers: const {HttpHeaders.acceptHeader: 'application/json'},
    );
    _ensureSuccess(response, resource: 'countries');

    final countries = await compute(parseCountries, response.body);
    _countries = countries;
    return countries;
  }

  Future<List<String>> fetchCities(String countryCode) async {
    final code = countryCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
      throw const FormatException('Country code must be ISO-2.');
    }

    final cached = _cities[code];
    if (cached != null) return cached;

    final response = await _client.get(
      Uri.parse('$_locationDataBaseUrl/flat-cities/$code.json'),
      headers: const {HttpHeaders.acceptHeader: 'application/json'},
    );
    _ensureSuccess(response, resource: 'cities for $code');

    final cities = await compute(parseCities, response.body);
    _cities[code] = cities;
    return cities;
  }

  void _ensureSuccess(http.Response response, {required String resource}) {
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to load $resource (HTTP ${response.statusCode}).',
        uri: response.request?.url,
      );
    }
  }
}

@visibleForTesting
List<CountryOption> parseCountries(String responseBody) {
  final decoded = jsonDecode(responseBody);
  if (decoded is! List) {
    throw const FormatException('Country data must be a JSON list.');
  }

  final countries = decoded
      .whereType<Map<String, dynamic>>()
      .map(CountryOption.fromJson)
      .where((country) => country.name.isNotEmpty && country.code.isNotEmpty)
      .toList();
  countries.sort((first, second) => first.name.compareTo(second.name));
  return List.unmodifiable(countries);
}

@visibleForTesting
List<String> parseCities(String responseBody) {
  final decoded = jsonDecode(responseBody);
  if (decoded is! List) {
    throw const FormatException('City data must be a JSON list.');
  }

  final cities =
      decoded
          .whereType<String>()
          .map((city) => city.trim())
          .where((city) => city.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return List.unmodifiable(cities);
}
