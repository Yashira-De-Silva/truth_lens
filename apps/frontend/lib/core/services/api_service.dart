// http and json imports are intentionally omitted in the mock implementation.

// Mock REST API service wrapper prepared for Laravel backend
class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Future<List<dynamic>> fetchNews({String? category, String? country}) async {
    // Mock response for now
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(6, (i) => {'id': i, 'title': 'Headline $i', 'source': 'Source $i'});

    // Example real request:
    // final res = await http.get(Uri.parse('$baseUrl/news?category=$category&country=$country'));
    // return jsonDecode(res.body);
  }
}
