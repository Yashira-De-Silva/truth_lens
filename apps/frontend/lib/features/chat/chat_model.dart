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
  final bool isEdited;
  final bool isDeletedForMe;
  final bool isDeletedForEveryone;
  final String? replyToMessageId;
  final ChatMessage? replyToMessage;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isEdited = false,
    this.isDeletedForMe = false,
    this.isDeletedForEveryone = false,
    this.replyToMessageId,
    this.replyToMessage,
  });

  ChatMessage copyWith({
    String? message,
    bool? isEdited,
    bool? isDeletedForMe,
    bool? isDeletedForEveryone,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message ?? this.message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeletedForMe: isDeletedForMe ?? this.isDeletedForMe,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      replyToMessageId: replyToMessageId,
      replyToMessage: replyToMessage,
    );
  }
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
