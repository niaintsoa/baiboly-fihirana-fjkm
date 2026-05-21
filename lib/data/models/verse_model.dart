class VerseModel {
  final int id;
  final int bookNumber;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  VerseModel({
    required this.id,
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory VerseModel.fromMap(Map<String, dynamic> map, {String? defaultBookName}) {
    return VerseModel(
      id: map['id'] as int? ?? map['_id'] as int? ?? 0,
      bookNumber: map['book_number'] as int? ?? map['bookNumber'] as int? ?? map['book'] as int? ?? map['book_id'] as int? ?? 0,
      bookName: map['book_name'] as String? ?? map['bookName'] as String? ?? defaultBookName ?? 'N/A',
      chapter: map['chapter'] as int? ?? map['chapter_number'] as int? ?? 0,
      verse: map['verse'] as int? ?? map['verse_number'] as int? ?? 0,
      text: map['text'] as String? ?? map['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_number': bookNumber,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }
}
