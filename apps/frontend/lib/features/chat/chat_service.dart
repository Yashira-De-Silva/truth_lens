import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_constants.dart';

// ── Headers ───────────────────────────────────────────────────────────────────

Map<String, String> _authHeaders(String token) => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

// ── Models ────────────────────────────────────────────────────────────────────

class BackendUser {
  final int id;
  final String name;
  final String email;
  final String? profileImage;

  const BackendUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory BackendUser.fromJson(Map<String, dynamic> j) => BackendUser(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String,
        profileImage: j['profile_image'] as String?,
      );
}

class BackendConversation {
  final String conversationId;
  final BackendUser otherUser;
  final BackendMessage? lastMessage;
  final int unreadCount;
  final String? updatedAt;

  const BackendConversation({
    required this.conversationId,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
  });

  factory BackendConversation.fromJson(Map<String, dynamic> j) =>
      BackendConversation(
        conversationId: j['conversation_id'] as String,
        otherUser: BackendUser.fromJson(
            j['other_user'] as Map<String, dynamic>),
        lastMessage: j['last_message'] != null
            ? BackendMessage.fromJson(
                j['last_message'] as Map<String, dynamic>)
            : null,
        unreadCount: (j['unread_count'] as int?) ?? 0,
        updatedAt: j['updated_at'] as String?,
      );
}

class BackendMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final String type;
  final bool isRead;
  final bool isEdited;
  final bool deletedForMe;
  final bool deletedForEveryone;
  final int? replyToId;
  final BackendReplyTo? replyTo;
  final String createdAt;

  const BackendMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.type = 'text',
    required this.isRead,
    required this.isEdited,
    required this.deletedForMe,
    required this.deletedForEveryone,
    this.replyToId,
    this.replyTo,
    required this.createdAt,
  });

  factory BackendMessage.fromJson(Map<String, dynamic> j) => BackendMessage(
        id: j['id'] as int,
        conversationId: j['conversation_id'] as int,
        senderId: j['sender_id'] as int,
        body: j['body'] as String? ?? '',
        type: j['type'] as String? ?? 'text',
        isRead: j['is_read'] as bool? ?? false,
        isEdited: j['is_edited'] as bool? ?? false,
        deletedForMe: j['deleted_for_me'] as bool? ?? false,
        deletedForEveryone: j['deleted_for_everyone'] as bool? ?? false,
        replyToId: j['reply_to_id'] as int?,
        replyTo: j['reply_to'] != null
            ? BackendReplyTo.fromJson(j['reply_to'] as Map<String, dynamic>)
            : null,
        createdAt: j['created_at'] as String,
      );
}

class BackendReplyTo {
  final int id;
  final int senderId;
  final String body;

  const BackendReplyTo(
      {required this.id, required this.senderId, required this.body});

  factory BackendReplyTo.fromJson(Map<String, dynamic> j) => BackendReplyTo(
        id: j['id'] as int,
        senderId: j['sender_id'] as int,
        body: j['body'] as String,
      );
}

// ── API calls ─────────────────────────────────────────────────────────────────

/// Fetch all users except the logged-in user.
Future<List<BackendUser>> getUsers(String token) async {
  final res = await http
      .get(Uri.parse('$kBaseUrl/chat/users'), headers: _authHeaders(token))
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) => BackendUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(body['message'] ?? 'Failed to load users');
}

/// Get or create a conversation with another user. Returns conversationId + other user.
Future<BackendConversation> getOrCreateConversation(
    String token, int otherUserId) async {
  final res = await http
      .post(
        Uri.parse('$kBaseUrl/chat/conversations'),
        headers: _authHeaders(token),
        body: jsonEncode({'other_user_id': otherUserId}),
      )
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if ((res.statusCode == 200 || res.statusCode == 201) &&
      body['success'] == true) {
    final data = body['data'] as Map<String, dynamic>;
    return BackendConversation(
      conversationId: data['conversation_id'] as String,
      otherUser:
          BackendUser.fromJson(data['other_user'] as Map<String, dynamic>),
    );
  }
  throw Exception(body['message'] ?? 'Failed to get conversation');
}

/// Fetch all conversations for the logged-in user.
Future<List<BackendConversation>> getConversations(String token) async {
  final res = await http
      .get(Uri.parse('$kBaseUrl/chat/conversations'),
          headers: _authHeaders(token))
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) =>
            BackendConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(body['message'] ?? 'Failed to load conversations');
}

/// Fetch all messages in a conversation.
Future<List<BackendMessage>> getMessages(
    String token, String conversationId) async {
  final res = await http
      .get(
        Uri.parse('$kBaseUrl/chat/conversations/$conversationId/messages'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) => BackendMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(body['message'] ?? 'Failed to load messages');
}

/// Send a message in a conversation.
Future<BackendMessage> sendMessage(
  String token,
  String conversationId,
  String messageBody, {
  int? replyToId,
}) async {
  final payload = <String, dynamic>{'body': messageBody};
  if (replyToId != null) payload['reply_to_id'] = replyToId;

  final res = await http
      .post(
        Uri.parse('$kBaseUrl/chat/conversations/$conversationId/messages'),
        headers: _authHeaders(token),
        body: jsonEncode(payload),
      )
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if ((res.statusCode == 200 || res.statusCode == 201) &&
      body['success'] == true) {
    return BackendMessage.fromJson(
        body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to send message');
}

/// Delete a message. [scope] = "me" or "everyone".
Future<void> deleteMessage(
    String token, int messageId, String scope) async {
  await http
      .delete(
        Uri.parse('$kBaseUrl/chat/messages/$messageId'),
        headers: _authHeaders(token),
        body: jsonEncode({'scope': scope}),
      )
      .timeout(const Duration(seconds: 10));
}

/// Mark all messages in a conversation as read.
Future<void> markConversationRead(
    String token, String conversationId) async {
  await http
      .post(
        Uri.parse('$kBaseUrl/chat/conversations/$conversationId/read'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));
}
