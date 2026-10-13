import 'dart:convert';
import 'package:rafeeq/data/models/namaz_prayer.dart';

List<NamazPrayer> kNamazPrayers = [];
List<WuduStep> kWuduSteps = [];

void initializeNamazPrayers(String jsonString) {
  final decoded = jsonDecode(jsonString) as List<dynamic>;
  kNamazPrayers = decoded
      .map((e) => NamazPrayer.fromJson(e as Map<String, dynamic>))
      .toList();
}

void initializeWuduSteps(String jsonString) {
  final decoded = jsonDecode(jsonString) as List<dynamic>;
  kWuduSteps = decoded
      .map((e) => WuduStep.fromJson(e as Map<String, dynamic>))
      .toList();
}

NamazPrayer? getNamazById(String id) {
  try {
    return kNamazPrayers.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
}
