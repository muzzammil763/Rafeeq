class DailyPrayer {
  final String id;
  final String arabicText;
  final String transliteration;
  final String englishTranslation;
  final String urduTranslation;
  final String? reference;
  final int? recommendedCount;
  final String category;
  final int order;

  const DailyPrayer({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.englishTranslation,
    required this.urduTranslation,
    this.reference,
    this.recommendedCount,
    required this.category,
    required this.order,
  });
}

class PrayerCategory {
  final String id;
  final String nameEn;
  final String nameUr;
  final String icon;
  final int order;

  const PrayerCategory({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.icon,
    required this.order,
  });
}
