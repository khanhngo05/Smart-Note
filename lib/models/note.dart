import 'dart:convert';

class Note {
  final String id;
  String title;
  String content;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  /// Chuyển đổi object sang Map để encode JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Tạo Note từ Map (khi decode JSON)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Encode list ghi chú sang chuỗi JSON
  static String encodeList(List<Note> notes) {
    return jsonEncode(notes.map((n) => n.toJson()).toList());
  }

  /// Decode chuỗi JSON sang list ghi chú
  static List<Note> decodeList(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded
        .map((item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Tạo bản sao có cập nhật một số trường
  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
