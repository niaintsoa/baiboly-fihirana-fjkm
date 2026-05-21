class FandaharanaItem {
  final String id;
  final String type; // 'verse' or 'hymn'
  final String title;
  final String subtitle;
  final String data; // JSON representation of the underlying model

  const FandaharanaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'data': data,
    };
  }

  factory FandaharanaItem.fromMap(Map<String, dynamic> map) {
    return FandaharanaItem(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      data: map['data'] as String? ?? '',
    );
  }
}
