import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../features/news/article_model.dart';
import 'api_config.dart';

/// REST API wrapper for the Python ML service (port 5001).
class NewsApiService {
  final String lang;
  NewsApiService({this.lang = 'en'});

  /// Fetch N articles from the Laravel backend (TiDB Cloud).
  Future<List<Article>> fetchNews({int limit = 20, int offset = 0}) async {
    final baseUrl = await ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse('$baseUrl/news?limit=$limit&offset=$offset&lang=$lang');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch top verified (REAL) articles for the Digest screen from Laravel.
  Future<List<Article>> fetchDigest({int limit = 3}) async {
    final baseUrl = await ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse('$baseUrl/news/digest?limit=$limit&lang=$lang');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Search articles by keyword from Laravel.
  Future<List<Article>> searchNews({
    String query = '',
    String category = 'All',
    int limit = 20,
  }) async {
    final baseUrl = await ApiConfig.baseUrl; // Use Laravel
    final uri = Uri.parse(
      '$baseUrl/news/search?q=${Uri.encodeQueryComponent(query)}'
      '&category=${Uri.encodeQueryComponent(category)}&limit=$limit&lang=$lang',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('Backend error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch live news from The Guardian API, classified by the ML model.
  /// Returns empty list if Guardian API key is not configured yet.
  Future<List<Article>> fetchLiveNews({
    String section = 'All',
    int limit = 20,
  }) async {
    final baseUrl = await ApiConfig.mlServiceUrl;
    final uri = Uri.parse(
      '$baseUrl/news/live?limit=$limit'
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
    final baseUrl = await ApiConfig.mlServiceUrl;
    final uri = Uri.parse('$baseUrl/predict');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'text': text}),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
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
