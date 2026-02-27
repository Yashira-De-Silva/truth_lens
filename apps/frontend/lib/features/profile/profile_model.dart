class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? avatarPath;
  final String? apiKey;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatarPath,
    this.apiKey,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarPath,
    String? apiKey,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'avatarPath': avatarPath,
      'apiKey': apiKey,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'User Name',
      email: json['email'] ?? 'user@example.com',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      avatarPath: json['avatarPath'] ?? json['profile_image'],
      apiKey: json['apiKey'] ?? json['api_key'],
    );
  }

  /// Build from the raw backend user map (snake_case keys).
  factory UserProfile.fromBackend(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      avatarPath: json['profile_image'],
      apiKey: json['api_key'],
    );
  }
}
