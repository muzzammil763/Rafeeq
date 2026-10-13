class QuranEdition {
  final String identifier;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String language;

  QuranEdition({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    required this.language,
  });

  factory QuranEdition.fromJson(Map<String, dynamic> json) {
    return QuranEdition(
      identifier: json['identifier'] as String? ?? '',
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      format: json['format'] as String? ?? '',
      type: json['type'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'englishName': englishName,
      'format': format,
      'type': type,
      'language': language,
    };
  }

  // Helper for displaying in UI
  String get displayName => "$englishName ($language)";
}
