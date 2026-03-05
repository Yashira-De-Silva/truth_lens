class Comment {
  final int id;
  final int articleId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });

  Comment copyWith({
    int? id,
    int? articleId,
    int? userId,
    String? userName,
    String? userAvatar,
    String? text,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return Comment(
      id: (json['id'] as num).toInt(),
      articleId: (json['article_id'] as num).toInt(),
      userId: (user['id'] as num?)?.toInt() ?? 0,
      userName: user['name'] as String? ?? 'Unknown',
      userAvatar: user['profile_image'] as String?,
      text: json['body'] as String? ?? '',
      timestamp: DateTime.parse(json['created_at'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'article_id': articleId,
        'user_id': userId,
        'body': text,
        'likes': likes,
        'is_liked': isLiked,
        'created_at': timestamp.toIso8601String(),
      };
}

