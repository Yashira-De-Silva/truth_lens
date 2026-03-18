import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';
import '../auth/auth_service.dart';
import 'comment_model.dart';
class CommentService {
  Future<Map<String, String>> _headers() async {
    final token = await loadToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET /api/articles/{articleId}/comments ───────────────────────────────

  /// Fetch all comments for [articleId], newest first.
  Future<List<Comment>> fetchComments(int articleId) async {
    final base = await ApiConfig.baseUrl;
    final headers = await _headers();
    final res = await http
        .get(Uri.parse('$base/articles/$articleId/comments'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Failed to load comments: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── POST /api/articles/{articleId}/comments ──────────────────────────────

  /// Post a new comment on [articleId].
  Future<Comment> addComment(int articleId, String text) async {
    final base = await ApiConfig.baseUrl;
    final headers = await _headers();
    final res = await http
        .post(
          Uri.parse('$base/articles/$articleId/comments'),
          headers: headers,
          body: jsonEncode({'body': text}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 201) {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Failed to add comment');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Comment.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ── DELETE /api/comments/{commentId} ─────────────────────────────────────

  /// Delete a comment by [commentId].
  Future<void> deleteComment(int commentId) async {
    final base = await ApiConfig.baseUrl;
    final headers = await _headers();
    final res = await http
        .delete(Uri.parse('$base/comments/$commentId'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Failed to delete comment: ${res.statusCode}');
    }
  }

  // ── POST /api/comments/{commentId}/like ──────────────────────────────────

  /// Toggle like on [commentId]. Returns `{likes, is_liked}`.
  Future<({int likes, bool isLiked})> toggleLike(int commentId) async {
    final base = await ApiConfig.baseUrl;
    final headers = await _headers();
    final res = await http
        .post(Uri.parse('$base/comments/$commentId/like'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Failed to toggle like: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return (
      likes: (data['likes'] as num).toInt(),
      isLiked: data['is_liked'] as bool,
    );
  }
}
