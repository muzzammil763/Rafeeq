import 'package:flutter/material.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:share_plus/share_plus.dart';

String buildAyahShareText({
  required Ayah ayah,
  required String surahName,
  required String arabicText,
  String? translation,
}) {
  final translatedText = translation?.trim();
  return [
    arabicText.trim(),
    if (translatedText != null && translatedText.isNotEmpty) translatedText,
    '$surahName ${ayah.surahNumber}:${ayah.numberInSurah}',
    'Shared from Rafeeq App',
  ].join('\n\n');
}

Future<void> shareAyahAsText(
  BuildContext context, {
  required Ayah ayah,
  required String surahName,
  required String arabicText,
  String? translation,
}) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: buildAyahShareText(
        ayah: ayah,
        surahName: surahName,
        arabicText: arabicText,
        translation: translation,
      ),
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
