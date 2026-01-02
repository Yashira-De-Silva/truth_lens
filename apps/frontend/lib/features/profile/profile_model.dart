class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String bio;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'User Name',
      email: json['email'] ?? 'user@example.com',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
    );
  }
}
