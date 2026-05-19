import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../features/news/article_model.dart';
import 'api_config.dart';

/// REST API wrapper for the Python ML service (port 5001).
class NewsApiService {
  final String lang;
  NewsApiService({this.lang = 'en'});

  /// Helper to batch translate articles in Sinhala or Tamil.
  Future<List<Article>> _translateArticlesIfRequired(List<Article> articles) async {
    if (articles.isEmpty || lang == 'en') return articles;
    try {
      final mlUrl = ApiConfig.mlServiceUrl;
      final uri = Uri.parse('$mlUrl/api/news/translate');
      final body = jsonEncode({
        'lang': lang,
        'articles': articles.map((a) => {
          'id': a.id,
          'title': a.title,
          'summary': a.summary,
        }).toList(),
      });
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));
      
      if (res.statusCode == 200) {
        final resBody = jsonDecode(res.body) as Map<String, dynamic>;
        final translatedList = resBody['data'] as List<dynamic>;
        
        final Map<int, Map<String, String>> translations = {};
        for (var t in translatedList) {
          final tMap = t as Map<String, dynamic>;
          final id = tMap['id'] as int;
          translations[id] = {
            'title': tMap['title'] as String,
            'summary': tMap['summary'] as String,
          };
        }
        
        return articles.map((a) {
          final t = translations[a.id];
          if (t != null) {
            return a.copyWith(
              title: t['title'] ?? a.title,
              summary: t['summary'] ?? a.summary,
            );
          }
          return a;
        }).toList();
      }
    } catch (_) {}
    return articles;
  }

  /// Helper to translate a single block of text on the fly.
  Future<String> _translateTextIfRequired(String text) async {
    if (text.isEmpty || lang == 'en') return text;
    try {
      final mlUrl = ApiConfig.mlServiceUrl;
      final uri = Uri.parse('$mlUrl/api/translate/text');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'lang': lang}),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['translated_text'] ?? text;
      }
    } catch (_) {}
    return text;
  }

  /// Fetch N articles from the Laravel backend (TiDB Cloud).
  Future<NewsResponse> fetchNews({int limit = 20, int offset = 0}) async {
    final baseUrl = ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse('$baseUrl/news?limit=$limit&offset=$offset&lang=$lang');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    var articles = data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    articles = await _translateArticlesIfRequired(articles);
    return NewsResponse(articles: articles, total: body['total'] ?? 0);
  }

  /// Fetch top verified (REAL) articles for the Digest screen from Laravel.
  Future<List<Article>> fetchDigest({int limit = 3}) async {
    final baseUrl = ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse('$baseUrl/news/digest?limit=$limit&lang=$lang');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    final articles = data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    return _translateArticlesIfRequired(articles);
  }

  /// Search articles by keyword from Laravel.
  Future<List<Article>> searchNews({
    String query = '',
    String category = 'All',
    int limit = 20,
  }) async {
    final baseUrl = ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse(
      '$baseUrl/news/search?q=${Uri.encodeQueryComponent(query)}'
      '&category=${Uri.encodeQueryComponent(category)}&limit=$limit&lang=$lang',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    final articles = data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    return _translateArticlesIfRequired(articles);
  }

  /// Fetch live news from The Guardian API, classified by the ML model.
  /// Returns empty list if Guardian API key is not configured yet.
  Future<List<Article>> fetchLiveNews({
    String section = 'All',
    int limit = 20,
  }) async {
    final baseUrl = ApiConfig.mlServiceUrl;
    final uri = Uri.parse(
      '$baseUrl/api/news/live?limit=$limit'
      '&section=${Uri.encodeQueryComponent(section)}&lang=$lang',
    );
    // Render free tier cold-starts can take 50+ seconds
    final res = await http.get(uri).timeout(const Duration(seconds: 60));
    if (res.statusCode == 503) return []; // Guardian key not set yet
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Verify custom news article user input
  Future<Map<String, dynamic>> verifyNews({
    required String title,
    required String text,
  }) async {
    final baseUrl = ApiConfig.mlServiceUrl;
    final uri = Uri.parse('$baseUrl/api/predict');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'text': text}),
    ).timeout(const Duration(seconds: 90));
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Fetch a single article by ID from Laravel.
  Future<Article> fetchArticleById(int id) async {
    final baseUrl = ApiConfig.baseUrl;
    final uri = Uri.parse('$baseUrl/news/$id');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    var article = Article.fromJson(body['data'] as Map<String, dynamic>);
    
    if (lang != 'en') {
      final title = await _translateTextIfRequired(article.title);
      final summary = await _translateTextIfRequired(article.summary);
      final fullText = article.fullText != null 
          ? await _translateTextIfRequired(article.fullText!) 
          : null;
      article = article.copyWith(title: title, summary: summary, fullText: fullText);
    }
    return article;
  }

  /// Request a 3-bullet-point AI summary from the ML service.
  Future<String> summarizeArticle(String text) async {
    final baseUrl = ApiConfig.mlServiceUrl;
    final uri = Uri.parse('$baseUrl/api/summarize');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'lang': lang}),
    ).timeout(const Duration(seconds: 60));
    
    if (res.statusCode != 200)
      throw Exception('Summarization failed: ${res.statusCode}');
    
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['summary'] ?? 'Summary could not be generated.';
  }
}

class NewsResponse {
  final List<Article> articles;
  final int total;
  NewsResponse({required this.articles, required this.total});
}

// ── Legacy stub kept for compatibility with news_providers.dart ───────────────
class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Future<List<dynamic>> fetchNews({String? category, String? country}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
}
