class HymnVerseModel {
  final int id;
  final int hymnId;
  final int verseNumber; // 0 pour refrain, 1, 2, 3 pour couplets
  final String lyrics;
  final bool isChorus;

  HymnVerseModel({
    required this.id,
    required this.hymnId,
    required this.verseNumber,
    required this.lyrics,
    required this.isChorus,
  });

  factory HymnVerseModel.fromMap(Map<String, dynamic> map) {
    return HymnVerseModel(
      id: map['id'] as int,
      hymnId: map['hymn_id'] as int,
      verseNumber: map['verse_number'] as int? ?? 0,
      lyrics: map['lyrics'] as String? ?? '',
      isChorus: (map['is_chorus'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hymn_id': hymnId,
      'verse_number': verseNumber,
      'lyrics': lyrics,
      'is_chorus': isChorus ? 1 : 0,
    };
  }
}
