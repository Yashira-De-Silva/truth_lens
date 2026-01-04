class Comment {
  final int id;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });

  Comment copyWith({
    int? id,
    String? userName,
    String? userAvatar,
    String? text,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
