class AiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory AiMessage.user(String message) {
    return AiMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.bot(String message) {
    return AiMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
