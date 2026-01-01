import '../../core/services/api_service.dart';

class NewsRepository {
  final ApiService api;
  NewsRepository(this.api);

  Future<List<dynamic>> getLatest({String? category, String? country}) async {
    return api.fetchNews(category: category, country: country);
  }
}
