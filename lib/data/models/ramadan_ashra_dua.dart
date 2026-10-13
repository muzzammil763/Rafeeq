class RamadanAshraDua {
  final int ashra;
  final String name;
  final String days;
  final AshraDua dua;
  final AshraDua? specialDua;

  const RamadanAshraDua({
    required this.ashra,
    required this.name,
    required this.days,
    required this.dua,
    this.specialDua,
  });
}

class AshraDua {
  final String? event;
  final String arabic;
  final String transliteration;
  final String translation;

  const AshraDua({
    this.event,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });
}
