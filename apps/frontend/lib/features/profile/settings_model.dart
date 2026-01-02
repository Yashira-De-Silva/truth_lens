class AppSettings {
  final String language;
  final bool notifications;

  AppSettings({
    this.language = 'en',
    this.notifications = true,
  });

  AppSettings copyWith({
    String? language,
    bool? notifications,
  }) {
    return AppSettings(
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'en',
      notifications: json['notifications'] ?? true,
    );
  }

  String get languageDisplayName {
    switch (language) {
      case 'en':
        return 'English';
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      default:
        return 'English';
    }
  }

  String get languageNativeName {
    switch (language) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }
}
