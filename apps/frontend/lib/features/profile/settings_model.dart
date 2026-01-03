class AppSettings {
  final String language;
  final bool notifications;
  final Set<String> preferredCategories;

  AppSettings({
    this.language = 'en',
    this.notifications = true,
    Set<String>? preferredCategories,
  }) : preferredCategories = preferredCategories ?? {'all'};

  AppSettings copyWith({
    String? language,
    bool? notifications,
    Set<String>? preferredCategories,
  }) {
    return AppSettings(
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications,
      'preferredCategories': preferredCategories.toList(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'en',
      notifications: json['notifications'] ?? true,
      preferredCategories: json['preferredCategories'] != null
          ? Set<String>.from(json['preferredCategories'])
          : {'all'},
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
