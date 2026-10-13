class QuranSearchResult {
  final int count;
  final List<SearchMatch> matches;

  QuranSearchResult({required this.count, required this.matches});

  factory QuranSearchResult.fromJson(Map<String, dynamic> json) {
    return QuranSearchResult(
      count: json['count'] as int? ?? 0,
      matches:
          (json['matches'] as List<dynamic>?)
              ?.map((e) => SearchMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SearchMatch {
  final int number;
  final String text;
  final int numberInSurah;
  final SearchSurah surah;
  final String? editionIdentifier;

  SearchMatch({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.surah,
    this.editionIdentifier,
  });

  factory SearchMatch.fromJson(Map<String, dynamic> json) {
    return SearchMatch(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
      surah: SearchSurah.fromJson(json['surah'] as Map<String, dynamic>),
      editionIdentifier:
          (json['edition'] as Map<String, dynamic>?)?['identifier'] as String?,
    );
  }
}

class SearchSurah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;

  SearchSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
  });

  factory SearchSurah.fromJson(Map<String, dynamic> json) {
    return SearchSurah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
    );
  }
}
