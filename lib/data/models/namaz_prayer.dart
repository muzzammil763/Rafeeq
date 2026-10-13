// Namaz (Salah) Prayer Models

class NamazPrayer {
  final String id;
  final String nameEn;
  final String nameUr;
  final String arabicName;
  final int rakaatFard;
  final int rakaatSunnah;
  final String timing;
  final String descriptionEn;
  final String descriptionUr;
  final List<NamazComponent> components;
  final List<String>? notes;

  const NamazPrayer({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.arabicName,
    required this.rakaatFard,
    required this.rakaatSunnah,
    required this.timing,
    required this.descriptionEn,
    required this.descriptionUr,
    required this.components,
    this.notes,
  });

  factory NamazPrayer.fromJson(Map<String, dynamic> json) {
    return NamazPrayer(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameUr: json['nameUr'] as String,
      arabicName: json['arabicName'] as String,
      rakaatFard: json['rakaatFard'] as int,
      rakaatSunnah: json['rakaatSunnah'] as int,
      timing: json['timing'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionUr: json['descriptionUr'] as String,
      components: (json['components'] as List<dynamic>)
          .map((e) => NamazComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameUr': nameUr,
      'arabicName': arabicName,
      'rakaatFard': rakaatFard,
      'rakaatSunnah': rakaatSunnah,
      'timing': timing,
      'descriptionEn': descriptionEn,
      'descriptionUr': descriptionUr,
      'components': components.map((e) => e.toJson()).toList(),
      if (notes != null) 'notes': notes,
    };
  }
}

class NamazComponent {
  final String id;
  final String type; // takbeer, qiyam, ruku, sujood, tashahhud, etc.
  final String titleEn;
  final String titleUr;
  final String? arabicText;
  final String? urduTranslation;
  final String? transliteration;
  final String? description;
  final int? repeatCount;
  final bool isOptional;

  const NamazComponent({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleUr,
    this.arabicText,
    this.urduTranslation,
    this.transliteration,
    this.description,
    this.repeatCount,
    this.isOptional = false,
  });

  factory NamazComponent.fromJson(Map<String, dynamic> json) {
    return NamazComponent(
      id: json['id'] as String,
      type: json['type'] as String,
      titleEn: json['titleEn'] as String,
      titleUr: json['titleUr'] as String,
      arabicText: json['arabicText'] as String?,
      urduTranslation: json['urduTranslation'] as String?,
      transliteration: json['transliteration'] as String?,
      description: json['description'] as String?,
      repeatCount: json['repeatCount'] as int?,
      isOptional: json['isOptional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'titleEn': titleEn,
      'titleUr': titleUr,
      if (arabicText != null) 'arabicText': arabicText,
      if (urduTranslation != null) 'urduTranslation': urduTranslation,
      if (transliteration != null) 'transliteration': transliteration,
      if (description != null) 'description': description,
      if (repeatCount != null) 'repeatCount': repeatCount,
      'isOptional': isOptional,
    };
  }
}

class WuduStep {
  final int step;
  final String titleEn;
  final String titleUr;
  final String descriptionEn;
  final String descriptionUr;
  final String? arabicText;
  final int? repeatCount;

  const WuduStep({
    required this.step,
    required this.titleEn,
    required this.titleUr,
    required this.descriptionEn,
    required this.descriptionUr,
    this.arabicText,
    this.repeatCount,
  });

  factory WuduStep.fromJson(Map<String, dynamic> json) {
    return WuduStep(
      step: json['step'] as int,
      titleEn: json['titleEn'] as String,
      titleUr: json['titleUr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionUr: json['descriptionUr'] as String,
      arabicText: json['arabicText'] as String?,
      repeatCount: json['repeatCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'titleEn': titleEn,
      'titleUr': titleUr,
      'descriptionEn': descriptionEn,
      'descriptionUr': descriptionUr,
      if (arabicText != null) 'arabicText': arabicText,
      if (repeatCount != null) 'repeatCount': repeatCount,
    };
  }
}
