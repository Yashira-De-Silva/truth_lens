class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? avatarPath;
  final String? apiKey;
  final int articlesReadCount;
  final int commentsCount;
  final int bookmarksCount;
  final int followersCount;
  final int followingCount;
  final List<Activity> activities;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatarPath,
    this.apiKey,
    this.articlesReadCount = 0,
    this.commentsCount = 0,
    this.bookmarksCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.activities = const [],
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarPath,
    String? apiKey,
    int? articlesReadCount,
    int? commentsCount,
    int? bookmarksCount,
    int? followersCount,
    int? followingCount,
    List<Activity>? activities,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      apiKey: apiKey ?? this.apiKey,
      articlesReadCount: articlesReadCount ?? this.articlesReadCount,
      commentsCount: commentsCount ?? this.commentsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'avatarPath': avatarPath,
      'apiKey': apiKey,
      'articles_read_count': articlesReadCount,
      'comments_count': commentsCount,
      'bookmarks_count': bookmarksCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int?,
      name: json['name'] ?? 'User Name',
      email: json['email'] ?? 'user@example.com',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      avatarPath: json['avatarPath'] ?? json['profile_image'],
      apiKey: json['apiKey'] ?? json['api_key'],
      articlesReadCount: json['articles_read_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      bookmarksCount: json['bookmarks_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      activities: (json['activities'] as List?)
              ?.map((a) => Activity.fromJson(a))
              .toList() ??
          [],
    );
  }

  factory UserProfile.fromBackend(Map<String, dynamic> json) {
    return UserProfile.fromJson(json);
  }
}

class Activity {
  final int id;
  final String type;
  final String description;
  final int? articleId;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    this.articleId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'article_id': articleId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int? ?? 0,
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? '',
      articleId: json['article_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
