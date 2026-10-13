import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/model/quran_models.dart';

final quranDataProvider = FutureProvider<QuranData>((ref) async {
  final fileContent = await rootBundle.loadString("assets/quran.json");
  return compute(parseQuranData, fileContent);
});

Future<QuranData> parseQuranData(String value) async {
  final json = jsonDecode(value) as Map<String, dynamic>;
  final dataJson = json["data"] as Map<String, dynamic>;
  final quranData = QuranData.fromJson(dataJson);
  return quranData;
}
