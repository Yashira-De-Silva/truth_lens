import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import 'news_repository.dart';

final newsApiProvider = Provider<NewsApiService>((ref) => NewsApiService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService(baseUrl: 'https://api.example.com'));
final newsRepoProvider = Provider<NewsRepository>((ref) => NewsRepository(ref.watch(apiServiceProvider)));
final latestNewsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(newsRepoProvider);
  return repo.getLatest();
});
