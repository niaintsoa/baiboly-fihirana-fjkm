class BookmarkModel {
  final int id;
  final int bookNumber;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String createdAt;

  BookmarkModel({
    required this.id,
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as int? ?? map['_id'] as int? ?? 0,
      bookNumber: map['book_number'] as int? ?? 0,
      bookName: map['book_name'] as String? ?? 'N/A',
      chapter: map['chapter'] as int? ?? 0,
      verse: map['verse'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
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
      'created_at': createdAt,
    };
  }
}
