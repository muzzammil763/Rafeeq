import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/models/user_location.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userLocationNotifierProvider =
    NotifierProvider<UserLocationNotifier, UserLocation?>(
      UserLocationNotifier.new,
    );

class UserLocationNotifier extends Notifier<UserLocation?> {
  late final SharedPreferences _sharedPreferences = ref.read(
    sharedPreferencesProvider,
  );

  @override
  UserLocation? build() {
    final location = _sharedPreferences.getUserLocation();
    if (location != null && location.city == null && location.country == null) {
      _reverseGeocodeLegacyLocation(location);
    }
    return location;
  }

  Future<void> _reverseGeocodeLegacyLocation(UserLocation location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        debugPrint(
          "[Placemark] name: \${pm.name}, locality: \${pm.locality}, subLocality: \${pm.subLocality}, adminArea: \${pm.administrativeArea}, subAdminArea: \${pm.subAdministrativeArea}, country: \${pm.country}",
        );

        final city = [
          pm.locality,
          pm.subAdministrativeArea,
          pm.administrativeArea,
          pm.subLocality,
        ].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);

        final country = pm.country;

        final newLocation = UserLocation(
          location.latitude,
          location.longitude,
          city: city,
          country: country,
          countryCode: pm.isoCountryCode,
          source: location.source,
        );
        state = newLocation;
        await _sharedPreferences.setUserLocation(newLocation);
      }
    } catch (e) {
      debugPrint("Legacy location geocode error: $e");
    }
  }

  Future<bool> updateUserLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String? city;
    String? country;
    String? countryCode;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        debugPrint(
          "[Placemark] name: \${pm.name}, locality: \${pm.locality}, subLocality: \${pm.subLocality}, adminArea: \${pm.administrativeArea}, subAdminArea: \${pm.subAdministrativeArea}, country: \${pm.country}",
        );

        city = [
          pm.locality,
          pm.subAdministrativeArea,
          pm.administrativeArea,
          pm.subLocality,
        ].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);

        country = pm.country;
        countryCode = pm.isoCountryCode;
      }
    } catch (e) {
      debugPrint("Geocoding error string: $e");
    }

    final location = UserLocation(
      position.latitude,
      position.longitude,
      city: city,
      country: country,
      countryCode: countryCode,
      source: UserLocationSource.automatic,
    );
    state = location;
    await _sharedPreferences.setUserLocation(location);
    return true;
  }

  Future<bool> setManualLocation({
    required String country,
    required String countryCode,
    required String city,
  }) async {
    try {
      final matches = await locationFromAddress('$city, $country');
      if (matches.isEmpty) return false;

      final match = matches.first;
      final location = UserLocation(
        match.latitude,
        match.longitude,
        city: city,
        country: country,
        countryCode: countryCode,
        source: UserLocationSource.manual,
      );
      state = location;
      await _sharedPreferences.setUserLocation(location);
      return true;
    } catch (error) {
      debugPrint('Manual location geocoding failed: $error');
      return false;
    }
  }

  /// Silently requests location if not already saved.
  /// Called automatically on first app load.
  Future<void> autoRequestLocationIfNeeded() async {
    // Already have a saved location
    if (state != null) return;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          return; // User denied, don't force
        }
      } else if (permission == LocationPermission.deniedForever) {
        return; // Can't request, don't bother
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String? city;
      String? country;
      String? countryCode;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          debugPrint(
            "[Placemark] name: \${pm.name}, locality: \${pm.locality}, subLocality: \${pm.subLocality}, adminArea: \${pm.administrativeArea}, subAdminArea: \${pm.subAdministrativeArea}, country: \${pm.country}",
          );

          city = [
            pm.locality,
            pm.subAdministrativeArea,
            pm.administrativeArea,
            pm.subLocality,
          ].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);

          country = pm.country;
          countryCode = pm.isoCountryCode;
        }
      } catch (e) {
        debugPrint("Geocoding error silently fetched: $e");
      }

      final location = UserLocation(
        position.latitude,
        position.longitude,
        city: city,
        country: country,
        countryCode: countryCode,
        source: UserLocationSource.automatic,
      );
      state = location;
      await _sharedPreferences.setUserLocation(location);
    } catch (_) {
      // Silently fail — user will see the placeholder
    }
  }
}

extension UserLocationX on SharedPreferences {
  UserLocation? getUserLocation() {
    final value = getString(UserLocation.prefsKey);
    if (value == null || value.isEmpty) return null;
    return UserLocation.fromMap(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> setUserLocation(UserLocation location) async {
    await setString(UserLocation.prefsKey, jsonEncode(location.toMap()));
  }
}
