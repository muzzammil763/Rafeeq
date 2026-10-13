class JuzNamesProvider {
  static const List<String> _juzUrduNames = [
    "الم",
    "سیقول",
    "تلک الرسل",
    "لن تنالوا",
    "والمحصنات",
    "لا یحب اللہ",
    "واذا سمعوا",
    "ولو اننا",
    "قال الملاء",
    "واعلموا",
    "یعتذرون",
    "وما من دابة",
    "وما ابری",
    "ربما",
    "سبحان الذی",
    "قال الم",
    "اقترب للناس",
    "قد افلح",
    "وقال الذین",
    "امن خلق",
    "اتل ما اوحی",
    "ومن یقنت",
    "وما لی",
    "فمن اظلم",
    "الیہ یرد",
    "حم",
    "قال فما خطبکم",
    "قد سمع اللہ",
    "تبارک الذی",
    "عم یتساءلون",
  ];

  static const List<String> _juzArabicNames = [
    "الم",
    "سَيَقُولُ",
    "تِلْكَ الرُّسُلُ",
    "لَنْ تَنَالُوا",
    "وَالْمُحْصَنَاتُ",
    "لَا يُحِبُّ اللهُ",
    "وَإِذَا سَمِعُوا",
    "وَلَوْ أَنَّنَا",
    "قَالَ الْمَلَأُ",
    "وَاعْلَمُوا",
    "يَعْتَذِرُونَ",
    "وَمَا مِنْ دَابَّةٍ",
    "وَمَا أُبَرِّئُ",
    "رُبَمَا",
    "سُبْحَانَ الَّذِي",
    "قَالَ أَلَمْ",
    "اقْتَرَبَ لِلنَّاسِ",
    "قَدْ أَفْلَحَ",
    "وَقَالَ الَّذِينَ",
    "أَمَّنْ خَلَقَ",
    "اتْلُ مَا أُوحِيَ",
    "وَمَنْ يَقْنُتْ",
    "وَمَا لِي",
    "فَمَنْ أَظْلَمُ",
    "إِلَيْهِ يُرَدُّ",
    "حم",
    "قَالَ فَمَا خَطْبُكُمْ",
    "قَدْ سَمِعَ اللهُ",
    "تَبَارَكَ الَّذِي",
    "عَمَّ يَتَسَاءَلُونَ",
  ];

  static const List<String> _juzEnglishNames = [
    "Alif Lam Meem",
    "Sayaqool",
    "Tilkal Rusull",
    "Lan Tana Loo",
    "Wal Mohsanat",
    "La Yuhibbullah",
    "Wa Iza Samiu",
    "Wa Lau Annana",
    "Qalal Malao",
    "Wa A'lamu",
    "Yatazeroon",
    "Wa Mamin Da'abat",
    "Wa Ma Ubrioo",
    "Rubama",
    "Subhanallazi",
    "Qala Alam",
    "Iqtaraba Linnas",
    "Qadd Aflaha",
    "Wa Qalallazina",
    "Aman Khalaqa",
    "Utlu Ma Oohi",
    "Wa Manyaqnut",
    "Wa Mali",
    "Faman Azlam",
    "Elahe Yuruddu",
    "Ha Meem",
    "Qala Fama Khatbukum",
    "Qadd Sami Allah",
    "Tabarakallazi",
    "Amma Yatasa'aloon",
  ];

  static const List<String> _juzUrduOrdinalNames = [
    'پہلا سپارہ',
    'دوسرا سپارہ',
    'تیسرا سپارہ',
    'چوتھا سپارہ',
    'پانچواں سپارہ',
    'چھٹا سپارہ',
    'ساتواں سپارہ',
    'آٹھواں سپارہ',
    'نواں سپارہ',
    'دسواں سپارہ',
    'گیارہواں سپارہ',
    'بارہواں سپارہ',
    'تیرہواں سپارہ',
    'چودہواں سپارہ',
    'پندرہواں سپارہ',
    'سولہواں سپارہ',
    'سترہواں سپارہ',
    'اٹھارہواں سپارہ',
    'انیسواں سپارہ',
    'بیسواں سپارہ',
    'اکیسواں سپارہ',
    'بائیسواں سپارہ',
    'تئیسواں سپارہ',
    'چوبیسواں سپارہ',
    'پچیسواں سپارہ',
    'چھبیسواں سپارہ',
    'ستائیسواں سپارہ',
    'اٹھائیسواں سپارہ',
    'انتیسواں سپارہ',
    'تیسواں سپارہ',
  ];

  static String getUrduName(int juzNumber) {
    return _juzUrduNames[juzNumber - 1];
  }

  static String getEnglishName(int juzNumber) {
    return _juzEnglishNames[juzNumber - 1];
  }

  static String getUrduOrdinalName(int juzNumber) {
    return _juzUrduOrdinalNames[juzNumber - 1];
  }

  static String getArabicName(int juzNumber) {
    return _juzArabicNames[juzNumber - 1];
  }
}
