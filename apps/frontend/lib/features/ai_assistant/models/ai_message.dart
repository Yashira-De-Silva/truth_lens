class RelatedNewsItem {
  final String title;
  final String description;
  final String url;
  final String source;
  final String thumbnail;

  RelatedNewsItem({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.thumbnail,
  });

  factory RelatedNewsItem.fromJson(Map<String, dynamic> json) {
    return RelatedNewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class AiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<RelatedNewsItem> relatedNews;

  AiMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.relatedNews = const [],
  });

  factory AiMessage.user(String message) {
    return AiMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.bot(String message, {List<RelatedNewsItem>? relatedNews}) {
    return AiMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
      relatedNews: relatedNews ?? [],
    );
  }
}
