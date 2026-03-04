class Article {
  final int id;
  final String title;
  final String summary;
  final String source;

  /// 'REAL' or 'FAKE' — from ML model. Defaults to 'REAL'.
  final String label;

  /// Confidence score 0.0–1.0 (how confident the model is in the label).
  final double confidence;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    this.label = 'REAL',
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'source': source,
    'label': label,
    'confidence': confidence,
  };

  static Article fromJson(Map<String, dynamic> j) => Article(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: j['title'] as String? ?? '',
    summary: j['summary'] as String? ?? '',
    source: j['source'] as String? ?? '',
    label: j['label'] as String? ?? 'REAL',
    confidence: (j['confidence'] as num?)?.toDouble() ?? 1.0,
  );
}
