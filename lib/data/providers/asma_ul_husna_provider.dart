import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/raw/asma_ul_husna_raw.dart';

class AsmaUlHusna {
  final String name;
  final String transliteration;
  final int number;
  final String found;
  final String meaning;
  final String desc;
  final List<String> videoIds;

  const AsmaUlHusna({
    required this.name,
    required this.transliteration,
    required this.number,
    required this.found,
    required this.meaning,
    required this.desc,
    this.videoIds = const [],
  });

  factory AsmaUlHusna.fromJson(Map<String, dynamic> json) {
    return AsmaUlHusna(
      name: json['name'] as String,
      transliteration: json['transliteration'] as String,
      number: json['number'] as int,
      found: json['found'] as String,
      meaning: json['meaning'] as String,
      desc: json['desc'] as String,
      videoIds: json['videoIds'] != null
          ? List<String>.from(json['videoIds'] as List)
          : const [],
    );
  }

  @override
  String toString() {
    return '$name ($transliteration) - $number - $meaning';
  }
}

final asmaUlHusnaProvider = Provider<List<AsmaUlHusna>>((ref) {
  final json = jsonDecode(asmaUlHusnaJson) as List<dynamic>;
  return json
      .map((e) => AsmaUlHusna.fromJson(e as Map<String, dynamic>))
      .toList();
});
