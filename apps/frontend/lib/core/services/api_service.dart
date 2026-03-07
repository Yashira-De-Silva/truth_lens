import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../features/news/article_model.dart';
import 'api_constants.dart';

/// REST API wrapper for the Python ML service (port 5000).
class NewsApiService {
  final String baseUrl;
  NewsApiService({String? url}) : baseUrl = url ?? kMlServiceUrl;

  /// Fetch N articles from the ML service.
  Future<List<Article>> fetchNews({int limit = 20, int offset = 0}) async {
    final uri = Uri.parse('$baseUrl/news?limit=$limit&offset=$offset');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch top verified (REAL) articles for the Digest screen.
  Future<List<Article>> fetchDigest({int limit = 3}) async {
    final uri = Uri.parse('$baseUrl/news/digest?limit=$limit');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Search articles by keyword and/or category.
  Future<List<Article>> searchNews({
    String query = '',
    String category = 'All',
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/news/search?q=${Uri.encodeQueryComponent(query)}'
      '&category=${Uri.encodeQueryComponent(category)}&limit=$limit',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
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
    final uri = Uri.parse(
      '$baseUrl/news/live?limit=$limit'
      '&section=${Uri.encodeQueryComponent(section)}',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode == 503) return []; // Guardian key not set yet
    if (res.statusCode != 200)
      throw Exception('ML service error: ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
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
