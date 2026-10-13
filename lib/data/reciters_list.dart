enum Reciter {
  abdullahbasfar(
    "ar.abdullahbasfar",
    "عبد الله بصفر",
    "Abdullah Basfar",
    "https://www.assabile.com/media/photo/full_size/abdullah-basfar.jpg",
    bitrate: 64,
  ),
  abdurrahmaansudais(
    "ar.abdurrahmaansudais",
    "عبدالرحمن السديس",
    "Abdurrahmaan As-Sudais",
    "https://www.assabile.com/media/person/280x219/abdul-rahman-al-sudais.png",
    bitrate: 64,
  ),
  abdulsamad(
    "ar.abdulsamad",
    "عبدالباسط عبدالصمد",
    "Abdul Samad",
    "https://i1.sndcdn.com/artworks-uxNTGLCV3g9UzJto-lBaJkw-t500x500.jpg",
    bitrate: 64,
  ),
  shaatree(
    "ar.shaatree",
    "أبو بكر الشاطري",
    "Abu Bakr Ash-Shaatree",
    "https://i.ytimg.com/vi/zDdAK7GCbhQ/hq720.jpg?sqp=-oaymwExCK4FEIIDSFryq4qpAyMIARUAAIhCGAHwAQH4AdQGgALgA4oCDAgAEAEYZSBfKFUwDw==&rs=AOn4CLDEHPin-gBryHkvcG6El7F2hUCPsA",
    bitrate: 64,
  ),
  ahmedajamy(
    "ar.ahmedajamy",
    "أحمد بن علي العجمي",
    "Ahmed ibn Ali al-Ajamy",
    "https://static.qurancdn.com/images/reciters/10/ahmed-ibn-ali-al-ajamy-profile.jpeg?v=1",
    bitrate: 64,
  ),
  alafasy(
    "ar.alafasy",
    "مشاري العفاسي",
    "Alafasy",
    "https://static.qurancdn.com/images/reciters/6/mishary-rashid-alafasy-profile.jpeg?v=1",
    bitrate: 64,
  ),
  hanirifai(
    "ar.hanirifai",
    "هاني الرفاعي",
    "Hani Rifai",
    "https://static.qurancdn.com/images/reciters/5/hani-ar-rifai-profile.jpeg?v=1",
    bitrate: 64,
  ),
  husary(
    "ar.husary",
    "محمود خليل الحصري",
    "Husary",
    "https://www.assabile.com/media/photo/full_size/mahmoud-khalil-al-hussary.jpg",
    bitrate: 64,
  ),
  husarymujawwad(
    "ar.husarymujawwad",
    "محمود خليل الحصري (المجود)",
    "Husary (Mujawwad)",
    "https://www.assabile.com/media/photo/full_size/mahmoud-khalil-al-hussary.jpg",
    bitrate: 64,
  ),
  hudhaify(
    "ar.hudhaify",
    "علي بن عبدالرحمن الحذيفي",
    "Hudhaify",
    "https://www.assabile.com/media/photo/full_size/ali-al-huthaify.jpg",
    bitrate: 64,
  ),
  ibrahimakhbar(
    "ar.ibrahimakhbar",
    "إبراهيم الأخضر",
    "Ibrahim Akhdar",
    "https://www.assabile.com/media/photo/full_size/ibrahim-al-akhdar.jpg",
    bitrate: 32,
  ),
  mahermuaiqly(
    "ar.mahermuaiqly",
    "ماهر المعيقلي",
    "Maher Al Muaiqly",
    "https://upload.wikimedia.org/wikipedia/commons/9/90/Maher_Al_Mueaqly.png",
    bitrate: 64,
  ),
  muhammadayyoub(
    "ar.muhammadayyoub",
    "محمد أيوب",
    "Muhammad Ayyoub",
    "https://www.assabile.com/media/photo/full_size/mohammed-ayyoub.jpg",
    bitrate: 128,
  ),
  muhammadjibreel(
    "ar.muhammadjibreel",
    "محمد جبريل",
    "Muhammad Jibreel",
    "https://www.assabile.com/media/photo/full_size/mohamed-jebril.jpg",
    bitrate: 128,
  ),
  saoodshuraym(
    "ar.saoodshuraym",
    "سعود الشريم",
    "Saood bin Ibraaheem Ash-Shuraym",
    "https://www.assabile.com/media/photo/full_size/saoud-shuraim.jpg",
    bitrate: 64,
  ),
  parhizgar(
    "ar.parhizgar",
    "شهریار پرهیزگار",
    "Parhizgar",
    "https://qurancentral.com/wp-content/uploads/2016/04/shahriar-parhizgar-2.jpg",
    bitrate: 48,
  ),
  aymanswoaid(
    "ar.aymanswoaid",
    "أيمن سويد",
    "Ayman Sowaid",
    "https://www.assabile.com/media/photo/full_size/ayman-swed.jpg",
    bitrate: 64,
  ),
  yasseraldousary(
    "ar.yasseraldousary",
    "ياسر الدوسري",
    "Yasser Al Dousary",
    "https://upload.wikimedia.org/wikipedia/commons/6/6f/Yasser_Al_Dosari.jpg",
    bitrate: 64,
  );

  const Reciter(
    this.identifier,
    this.name,
    this.englishName,
    this.imageUrl, {
    required this.bitrate,
  });

  final String identifier;
  final String name;
  final String englishName;
  final String imageUrl;
  final int bitrate;

  String getAyahLink(int ayahNumber, {int? surahNumber, int? ayahInSurah}) {
    if (this == Reciter.yasseraldousary) {
      if (surahNumber != null && ayahInSurah != null) {
        return "https://the-quran-project.github.io/Quran-Audio/Data/4/$surahNumber"
            "_$ayahInSurah.mp3";
      }
      throw ArgumentError(
        'surahNumber and ayahInSurah are required for Yasser Al Dousary',
      );
    }
    return "https://cdn.islamic.network/quran/audio/$bitrate/$identifier/$ayahNumber.mp3";
  }
}

const kAllRecitersList = Reciter.values;

enum SurahReciter {
  abdulbasit(
    "ar.abdulbasitmujawwad",
    "Abdul Basit",
    image:
        "https://i1.sndcdn.com/artworks-uxNTGLCV3g9UzJto-lBaJkw-t500x500.jpg",
  ),
  // abdulbasitmurattal("ar.abdulbasitmurattal", "Abdul Basit (Murattal)"),
  misharyrashidalafasy(
    "ar.misharyrashidalafasy",
    "Mishary Rashid Alafasy",
    image:
        "https://static.qurancdn.com/images/reciters/6/mishary-rashid-alafasy-profile.jpeg?v=1",
  ),
  sadaqatali(
    "ar.sadaqatali",
    "Qari Syed Sadaqat Ali",
    image:
        "https://yt3.googleusercontent.com/ytc/AIf8zZS_XGJte6U5_jES4rfUmn5jsUdppKqcoh6VDEPu=s900-c-k-c0x00ffffff-no-rj",
  ),
  yousufbinnoahahmad(
    "ar.yousufbinnoahahmad",
    "Yusuf Bin Noah Ahmad",
    image: "https://www.assabile.com/media/person/280x219/akram-al-aalakmi.png",
  ),
  yasseraldousary(
    "ar.yasseraldousary",
    "Yasser Al Dousary",
    image:
        "https://upload.wikimedia.org/wikipedia/commons/6/6f/Yasser_Al_Dosari.jpg",
  );

  final String identifier;
  final String name;
  final String image;

  const SurahReciter(this.identifier, this.name, {required this.image});

  String getSurahLink(int surahNumber) {
    if (this == SurahReciter.yasseraldousary) {
      return "https://github.com/The-Quran-Project/Quran-Audio-Chapters/raw/refs/heads/main/Data/4/$surahNumber.mp3";
    }
    return "https://cdn.islamic.network/quran/audio-surah/128/$identifier/$surahNumber.mp3";
  }
}
