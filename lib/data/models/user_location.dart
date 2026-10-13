import 'package:equatable/equatable.dart';

enum UserLocationSource { automatic, manual }

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? countryCode;
  final UserLocationSource source;

  const UserLocation(
    this.latitude,
    this.longitude, {
    this.city,
    this.country,
    this.countryCode,
    this.source = UserLocationSource.automatic,
  });

  static const String prefsKey = "prefs.user_location";

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    city,
    country,
    countryCode,
    source,
  ];

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'countryCode': countryCode,
      'source': source.name,
    };
  }

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      (map['latitude'] as num? ?? 0).toDouble(),
      (map['longitude'] as num? ?? 0).toDouble(),
      city: map['city'] as String?,
      country: map['country'] as String?,
      countryCode: map['countryCode'] as String?,
      source: UserLocationSource.values.firstWhere(
        (source) => source.name == map['source'],
        orElse: () => UserLocationSource.automatic,
      ),
    );
  }
}
