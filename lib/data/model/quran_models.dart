class QuranData {
  final List<Surah> surah;

  QuranData({required this.surah});

  List<Ayah>? _ayahs;

  static QuranData fromJson(Map<String, dynamic> json) {
    final surahList = json["surahs"] as List<dynamic>;
    final surah = List<Surah>.generate(
      surahList.length,
      (index) =>
          Surah.fromJson(surahList[index] as Map<String, dynamic>, index + 1),
    );
    return QuranData(surah: surah);
  }

  List<Ayah> get ayahs {
    return _ayahs ??= surah.expand((element) => element.ayahs).toList();
  }
}

class Surah {
  final int surahNumber;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final List<Ayah> ayahs;

  Surah({
    required this.surahNumber,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahs,
  });

  static Surah fromJson(Map<String, dynamic> json, int surahNumber) {
    return Surah(
      surahNumber: surahNumber,
      name: json["name"] as String,
      englishName: json["englishName"] as String,
      englishNameTranslation: json["englishNameTranslation"] as String,
      revelationType: json["revelationType"] as String,
      ayahs: (json["ayahs"] as List<dynamic>)
          .map((e) => Ayah.fromJson(e as Map<String, dynamic>, surahNumber))
          .toList(),
    );
  }
}

class Ayah {
  final int number;
  final int numberInSurah;
  final int juz;
  final String text;
  final int surahNumber;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.surahNumber,
  });

  static Ayah fromJson(Map<String, dynamic> json, int surahNumber) {
    return Ayah(
      surahNumber: surahNumber,
      number: json["number"] as int,
      numberInSurah: json["numberInSurah"] as int,
      text: json["text"] as String,
      juz: json["juz"] as int,
    );
  }
}

enum Juz {
  first("الْحَمْدُ لِلَّهِ"),
  second("سَيَقُولُ"),
  third("تِلْكَ الرُّسُلُ"),
  fourth("لَنْ تَنَالُوا"),
  fifth("وَالْمُحْصَنَاتُ"),
  sixth("لَا يُحِبُّ اللَّهُ"),
  seventh("وَإِذَا سَمِعُوا"),
  eighth("وَلَوْ أَنَّنَا"),
  ninth("قَالَ الْمَلَأُ"),
  tenth("وَاعْلَمُوا"),
  eleventh("يَعْتَذِرُونَ"),
  twelfth("وَمَا مِنْ دَابَّةٍ"),
  thirteenth("وَمَا أُبَرِّئُ"),
  fourteenth("رُبَمَا"),
  fifteenth("سُبْحَانَ الَّذِي"),
  sixteenth("قَالَ أَلَمْ"),
  seventeenth("اقْتَرَبَ لِلنَّاسِ"),
  eighteenth("قَدْ أَفْلَحَ"),
  nineteenth("وَقَالَ الَّذِينَ"),
  twentieth("أَمَّنْ خَلَقَ"),
  twentyFirst("اتْلُ مَا أُوحِيَ"),
  twentySecond("وَمَنْ يَقْنُتْ"),
  twentyThird("وَمَا لِيَ"),
  twentyFourth("فَمَنْ أَظْلَمُ"),
  twentyFifth("إِلَيْهِ يُرَدُّ"),
  twentySixth("حم"),
  twentySeventh("قَالَ فَمَا خَطْبُكُمْ"),
  twentyEighth("قَدْ سَمِعَ اللَّهُ"),
  twentyNinth("تَبَارَكَ الَّذِي"),
  thirtieth("عَمَّ يَتَسَاءَلُونَ");

  final String startWord;

  const Juz(this.startWord);

  int get number {
    return index + 1;
  }
}
