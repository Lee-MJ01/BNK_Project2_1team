class ChatMessage {
  final bool isUser;
  final String answer;
  final DateTime createdAt;

  ChatMessage({
    required this.isUser,
    required this.answer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.user(String msg) {
    return ChatMessage(isUser: true, answer: msg);
  }

  factory ChatMessage.bot(String msg) {
    return ChatMessage(isUser: false, answer: msg);
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isUser: json['isUser'] ?? false,
      answer: json['answer'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

}
