class ChatMessage {
  final bool isUser;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.isUser,
    required this.message,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.user(String msg) {
    return ChatMessage(isUser: true, message: msg);
  }

  factory ChatMessage.bot(String msg) {
    return ChatMessage(isUser: false, message: msg);
  }
}
