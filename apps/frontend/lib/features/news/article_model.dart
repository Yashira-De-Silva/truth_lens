class Article {
  final int id;
  final String title;
  final String summary;
  final String? fullText;
  final String source;

  final String label;

  final double confidence;

  final String? url;

  final String? published;

  final bool isLive;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    this.fullText,
    required this.source,
    this.label = 'REAL',
    this.confidence = 1.0,
    this.url,
    this.published,
    this.isLive = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'full_text': fullText,
    'source': source,
    'label': label,
    'confidence': confidence,
    'url': url,
    'published': published,
    'is_live': isLive,
  };

  static Article fromJson(Map<String, dynamic> j) => Article(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: j['title'] as String? ?? '',
    summary: j['summary'] as String? ?? '',
    fullText: j['full_text'] as String?,
    source: j['source'] as String? ?? '',
    label: j['label'] as String? ?? 'REAL',
    confidence: (j['confidence'] as num?)?.toDouble() ?? 1.0,
    url: j['url'] as String?,
    published: j['published'] as String?,
    isLive: j['is_live'] as bool? ?? false,
  );
}
