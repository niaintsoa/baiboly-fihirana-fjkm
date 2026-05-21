class BookModel {
  final int id;
  final int number;
  final String name;
  final String testament;
  final int totalChapters;

  BookModel({
    required this.id,
    required this.number,
    required this.name,
    required this.testament,
    required this.totalChapters,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as int? ?? map['_id'] as int? ?? 0,
      number: map['number'] as int? ?? map['book_number'] as int? ?? 0,
      name: map['name'] as String? ?? map['book_name'] as String? ?? 'N/A',
      testament: map['testament'] as String? ?? 'Old',
      totalChapters: map['total_chapters'] as int? ?? map['chapters'] as int? ?? 1,
    );
  }

  factory BookModel.empty() {
    return BookModel(
      id: 0,
      number: 0,
      name: '',
      testament: '',
      totalChapters: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'testament': testament,
      'total_chapters': totalChapters,
    };
  }

  bool get isNewTestament => testament.toLowerCase() == 'new' || testament.toLowerCase() == 'nouveau';
}
