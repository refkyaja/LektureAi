class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    content: json['content'] as String,
  );
}

class ChatSession {
  final String id;
  final String title;
  final int updatedAt;
  final List<ChatMessage> messages;
  final List<String> noteIds;

  ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
    required this.noteIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'updatedAt': updatedAt,
    'messages': messages.map((m) => m.toJson()).toList(),
    'noteIds': noteIds,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String,
    updatedAt: json['updatedAt'] as int,
    messages: List<ChatMessage>.from((json['messages'] as List).map((x) => ChatMessage.fromJson(Map<String, dynamic>.from(x)))),
    noteIds: List<String>.from(json['noteIds'] ?? []),
  );

  ChatSession copyWith({
    List<ChatMessage>? messages,
    int? updatedAt,
    List<String>? noteIds,
  }) => ChatSession(
    id: id,
    title: title,
    updatedAt: updatedAt ?? this.updatedAt,
    messages: messages ?? this.messages,
    noteIds: noteIds ?? this.noteIds,
  );
}
