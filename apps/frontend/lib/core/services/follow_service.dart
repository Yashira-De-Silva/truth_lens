import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';
import '../../features/profile/profile_model.dart';

Map<String, String> _headers(String token) => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
};

// ── Models ────────────────────────────────────────────────────────────────────

class FollowStatus {
  final bool isFollowing;
  final bool isMutual;
  const FollowStatus({required this.isFollowing, required this.isMutual});
  factory FollowStatus.from(Map<String, dynamic> j) => FollowStatus(
    isFollowing: j['is_following'] as bool? ?? false,
    isMutual: j['is_mutual'] as bool? ?? false,
  );
  factory FollowStatus.none() =>
      const FollowStatus(isFollowing: false, isMutual: false);
}

class PublicUserProfile {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? profileImage;
  final int articlesReadCount;
  final int commentsCount;
  final int bookmarksCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isMutual;
  final List<Activity> activities;

  const PublicUserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profileImage,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isMutual,
    this.articlesReadCount = 0,
    this.commentsCount = 0,
    this.bookmarksCount = 0,
    this.activities = const [],
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> j) =>
      PublicUserProfile(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String? ?? '',
        bio: j['bio'] as String?,
        profileImage: j['profile_image'] as String?,
        followersCount: j['followers_count'] as int? ?? 0,
        followingCount: j['following_count'] as int? ?? 0,
        isFollowing: j['is_following'] as bool? ?? false,
        isMutual: j['is_mutual'] as bool? ?? false,
        articlesReadCount: j['articles_read_count'] ?? 0,
        commentsCount: j['comments_count'] ?? 0,
        bookmarksCount: j['bookmarks_count'] ?? 0,
        activities: (j['activities'] as List?)
                ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class FollowUser {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  const FollowUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });
  factory FollowUser.fromJson(Map<String, dynamic> j) => FollowUser(
    id: j['id'] as int,
    name: j['name'] as String,
    email: j['email'] as String? ?? '',
    profileImage: j['profile_image'] as String?,
  );
}

// ── API calls ─────────────────────────────────────────────────────────────────

Future<FollowStatus> followUser(String token, int userId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .post(Uri.parse('$base/follow/$userId'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) return FollowStatus.from(body);
  throw Exception(body['message'] ?? 'Failed to follow');
}

Future<FollowStatus> unfollowUser(String token, int userId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .delete(Uri.parse('$base/follow/$userId'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) return FollowStatus.from(body);
  throw Exception(body['message'] ?? 'Failed to unfollow');
}

Future<FollowStatus> getFollowStatus(String token, int userId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/follow/status/$userId'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) return FollowStatus.from(body);
  return FollowStatus.none();
}

Future<List<FollowUser>> getFollowers(String token) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/followers'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) {
    return (body['data'] as List)
        .map((e) => FollowUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

Future<List<FollowUser>> getFollowing(String token) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/following'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) {
    return (body['data'] as List)
        .map((e) => FollowUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

Future<PublicUserProfile?> getUserProfile(String token, int userId) async {
  final base = await ApiConfig.baseUrl;
  final res = await http
      .get(Uri.parse('$base/users/$userId/profile'), headers: _headers(token))
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 && body['success'] == true) {
    return PublicUserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }
  return null;
}
