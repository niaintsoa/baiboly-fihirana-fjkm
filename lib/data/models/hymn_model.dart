class HymnModel {
  final int id;
  final int number;
  final String category; // 'ffpm', 'fanampiny', 'antema'
  final String title;
  final String author;

  HymnModel({
    required this.id,
    required this.number,
    required this.category,
    required this.title,
    required this.author,
  });

  factory HymnModel.fromMap(Map<String, dynamic> map) {
    return HymnModel(
      id: map['id'] as int,
      number: map['number'] as int,
      category: map['category'] as String,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'category': category,
      'title': title,
      'author': author,
    };
  }
}
