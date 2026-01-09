class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? avatarPath;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatarPath,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'avatarPath': avatarPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'User Name',
      email: json['email'] ?? 'user@example.com',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      avatarPath: json['avatarPath'],
    );
  }
}
