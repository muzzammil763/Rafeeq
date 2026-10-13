import 'models/ramadan_ashra_dua.dart';

const List<RamadanAshraDua> kRamadanAshras = [
  RamadanAshraDua(
    ashra: 1,
    name: "Mercy (Rehmah)",
    days: "1-10",
    dua: AshraDua(
      arabic: "رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ",
      transliteration: "Rabbi-ghfir war-ham wa Anta Khair-ur-Rahimeen",
      translation:
          "My Lord! Forgive and have mercy, for You are the best of those who show mercy.",
    ),
  ),
  RamadanAshraDua(
    ashra: 2,
    name: "Forgiveness (Maghfirah)",
    days: "11-20",
    dua: AshraDua(
      arabic: "أَسْتَغْفِرُ اللهَ رَبِّي مِنْ كُلِّ ذَنْبٍ وَأَتُوبُ إِلَيْهِ",
      transliteration:
          "Astaghfirullaha Rabbi min kulli zambin wa atoobu ilayhi",
      translation:
          "I seek forgiveness from Allah, my Lord, from every sin and I turn to Him in repentance.",
    ),
  ),
  RamadanAshraDua(
    ashra: 3,
    name: "Salvation (Nijat)",
    days: "21-30",
    dua: AshraDua(
      arabic: "اَللَّهُمَّ أَجِرْنِي مِنَ النَّارِ",
      transliteration: "Allahumma Ajirni min-an-Naar",
      translation: "O Allah! Save me from the Fire (of Hell).",
    ),
    specialDua: AshraDua(
      event: "Laylat al-Qadr",
      arabic: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
      transliteration: "Allahumma innaka 'afuwwun, tuhibbul-'afwa, fa'fu 'anni",
      translation:
          "O Allah, You are Forgiving and love forgiveness, so forgive me.",
    ),
  ),
];
