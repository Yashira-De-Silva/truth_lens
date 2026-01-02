class Article {
  final int id;
  final String title;
  final String summary;
  final String source;

  Article({required this.id, required this.title, required this.summary, required this.source});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'summary': summary, 'source': source};
  static Article fromJson(Map<String, dynamic> j) => Article(id: j['id'], title: j['title'], summary: j['summary'], source: j['source']);
}
