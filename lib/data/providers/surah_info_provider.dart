import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/raw/surahs_raw.dart';

class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }
}

final surahInfoProvider = Provider<List<SurahInfo>>((ref) {
  final json = jsonDecode(surahsJson) as List<dynamic>;
  return json
      .map((e) => SurahInfo.fromJson(e as Map<String, dynamic>))
      .toList();
});
