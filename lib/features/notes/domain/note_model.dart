class Note {
  final String id;
  final String title;
  final String body;
  final String tag;
  final int createdAt;
  final int updatedAt;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'tag': tag,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'isPinned': isPinned,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    tag: json['tag'] as String? ?? 'General',
    createdAt: json['createdAt'] as int,
    updatedAt: json['updatedAt'] as int,
    isPinned: json['isPinned'] as bool? ?? false,
  );

  Note copyWith({
    String? title,
    String? body,
    String? tag,
    int? updatedAt,
    bool? isPinned,
  }) => Note(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    tag: tag ?? this.tag,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPinned: isPinned ?? this.isPinned,
  );
}
