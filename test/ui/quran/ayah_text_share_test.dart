import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/data/model/quran_models.dart';
import 'package:rafeeq/ui/quran/ayah_text_share.dart';

void main() {
  const ayah = Ayah(
    number: 1,
    numberInSurah: 1,
    text: 'Arabic ayah',
    juz: 1,
    surahNumber: 1,
  );

  test('builds share text with the available translation', () {
    expect(
      buildAyahShareText(
        ayah: ayah,
        surahName: 'Al-Fatihah',
        arabicText: 'Arabic ayah',
        translation: 'English translation',
      ),
      'Arabic ayah\n\nEnglish translation\n\n'
      'Al-Fatihah 1:1\n\nShared from Rafeeq App',
    );
  });

  test('omits an unavailable translation without empty share content', () {
    expect(
      buildAyahShareText(
        ayah: ayah,
        surahName: 'Al-Fatihah',
        arabicText: 'Arabic ayah',
      ),
      'Arabic ayah\n\nAl-Fatihah 1:1\n\nShared from Rafeeq App',
    );
  });
}
