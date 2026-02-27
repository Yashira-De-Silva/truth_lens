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

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isEdited': isEdited,
      'isDeletedForMe': isDeletedForMe,
      'isDeletedForEveryone': isDeletedForEveryone,
      'replyToMessageId': replyToMessageId,
      'replyToMessage': replyToMessage?.toJson(),
    };
  }

  // Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeletedForMe: json['isDeletedForMe'] as bool? ?? false,
      isDeletedForEveryone: json['isDeletedForEveryone'] as bool? ?? false,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessage: json['replyToMessage'] != null
          ? ChatMessage.fromJson(json['replyToMessage'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ChatConversation {
  final String id;           // local/display id
  final String conversationId; // backend UUID
  final ChatUser user;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.conversationId,
    required this.user,
    this.lastMessage,
    this.unreadCount = 0,
  });
}
