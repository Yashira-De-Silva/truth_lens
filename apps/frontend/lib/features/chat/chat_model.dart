class ChatUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOnline = false,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class ChatConversation {
  final String id;
  final ChatUser user;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.user,
    this.lastMessage,
    this.unreadCount = 0,
  });
}
