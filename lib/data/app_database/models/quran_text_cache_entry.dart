import 'package:equatable/equatable.dart';

class QuranTextCacheEntry extends Equatable {
  final String editionId;
  final String fetchType;
  final int fetchNumber;
  final int ayahNumber;
  final String ayahText;

  const QuranTextCacheEntry({
    required this.editionId,
    required this.fetchType,
    required this.fetchNumber,
    required this.ayahNumber,
    required this.ayahText,
  });

  factory QuranTextCacheEntry.fromMap(Map<String, dynamic> map) {
    return QuranTextCacheEntry(
      editionId: map['edition_id'] as String,
      fetchType: map['fetch_type'] as String,
      fetchNumber: map['fetch_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      ayahText: map['ayah_text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'edition_id': editionId,
      'fetch_type': fetchType,
      'fetch_number': fetchNumber,
      'ayah_number': ayahNumber,
      'ayah_text': ayahText,
    };
  }

  @override
  List<Object?> get props => [
    editionId,
    fetchType,
    fetchNumber,
    ayahNumber,
    ayahText,
  ];
}
