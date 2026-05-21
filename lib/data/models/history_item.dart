class HistoryItem {
  final int bookNumber;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const HistoryItem({
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookNumber': bookNumber,
      'bookName': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      bookNumber: map['bookNumber'] as int? ?? 0,
      bookName: map['bookName'] as String? ?? '',
      chapter: map['chapter'] as int? ?? 1,
      verse: map['verse'] as int? ?? 1,
      text: map['text'] as String? ?? '',
    );
  }
}
