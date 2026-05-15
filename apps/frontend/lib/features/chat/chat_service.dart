import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';

Map<String, String> _authHeaders(String token) => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

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
Future<List<BackendUser>> getUsers(String token) async {
  final base = ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/chat/users'), headers: _authHeaders(token))
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) => BackendUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(body['message'] ?? 'Failed to load users');
}
Future<BackendConversation> getOrCreateConversation(
    String token, int otherUserId) async {
  final base = ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chat/conversations'),
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
Future<List<BackendConversation>> getConversations(String token) async {
  final base = ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/chat/conversations'), headers: _authHeaders(token))
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List)
        .map((e) => BackendConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(body['message'] ?? 'Failed to load conversations');
}
Future<List<BackendMessage>> getMessages(
    String token, String conversationId) async {
  final base = ApiConfig.baseUrl;
  final res = await http
      .get(
        Uri.parse('$base/chat/conversations/$conversationId/messages'),
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
Future<BackendMessage> sendMessage(
  String token,
  String conversationId,
  String messageBody, {
  int? replyToId,
}) async {
  final payload = <String, dynamic>{'body': messageBody};
  if (replyToId != null) payload['reply_to_id'] = replyToId;
  final base = ApiConfig.baseUrl;
  final res = await http
      .post(
        Uri.parse('$base/chat/conversations/$conversationId/messages'),
        headers: _authHeaders(token),
        body: jsonEncode(payload),
      )
      .timeout(const Duration(seconds: 15));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if ((res.statusCode == 200 || res.statusCode == 201) &&
      body['success'] == true) {
    return BackendMessage.fromJson(body['data'] as Map<String, dynamic>);
  }
  throw Exception(body['message'] ?? 'Failed to send message');
}

/// Delete a message. [scope] = "me" or "everyone".
Future<void> deleteMessage(
    String token, int messageId, String scope) async {
  final base = ApiConfig.baseUrl;
  await http
      .delete(
        Uri.parse('$base/chat/messages/$messageId'),
        headers: _authHeaders(token),
        body: jsonEncode({'scope': scope}),
      )
      .timeout(const Duration(seconds: 10));
}
Future<void> markConversationRead(
    String token, String conversationId) async {
  final base = ApiConfig.baseUrl;
  await http
      .post(
        Uri.parse('$base/chat/conversations/$conversationId/read'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));
}

// ── Call Signaling ────────────────────────────────────────────────────────
Future<Map<String, dynamic>> initiateCall(String token, int receiverId, {bool isVideo = false}) async {
  final base = ApiConfig.baseUrl;
  final res = await http.post(
    Uri.parse('$base/chat/calls/initiate'),
    headers: _authHeaders(token),
    body: jsonEncode({
      'receiver_id': receiverId,
      'type': isVideo ? 'video' : 'audio'
    }),
  ).timeout(const Duration(seconds: 15));
  
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if ((res.statusCode == 200 || res.statusCode == 201) && body['success'] == true) {
    return body['data'] as Map<String, dynamic>;
  }
  throw Exception(body['message'] ?? 'Failed to initiate call');
}

Future<Map<String, dynamic>?> getActiveCall(String token) async {
  final base = ApiConfig.baseUrl;
  final res = await http.get(
    Uri.parse('$base/chat/calls/active'),
    headers: _authHeaders(token),
  ).timeout(const Duration(seconds: 10));
  
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return body['data'] as Map<String, dynamic>?;
  }
  throw Exception(body['message'] ?? 'Failed to check active calls');
}

Future<void> updateCallStatus(String token, int callId, String status) async {
  final base = ApiConfig.baseUrl;
  final res = await http.put(
    Uri.parse('$base/chat/calls/$callId/status'),
    headers: _authHeaders(token),
    body: jsonEncode({'status': status}),
  ).timeout(const Duration(seconds: 10));
  
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode != 200 || body['success'] != true) {
    throw Exception(body['message'] ?? 'Failed to update call status');
  }
}

