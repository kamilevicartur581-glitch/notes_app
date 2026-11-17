class Note {
  final int? id;
  final String title;
  final String content;
  final int timestamp;

  Note({
    this.id,
    required this.title,
    required this.content,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'timestamp': timestamp,
  };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
    id: map['id'] as int?,
    title: map['title'] as String,
    content: map['content'] as String,
    timestamp: map['timestamp'] as int,
  );

  Note copyWith({int? id, String? title, String? content, int? timestamp}) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
      );
}