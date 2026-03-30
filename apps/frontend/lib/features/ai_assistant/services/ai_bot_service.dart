import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';

class AiBotService {
  Future<String> askBot(String message) async {
    try {
      final baseUrl = await ApiConfig.mlServiceUrl;
      final uri = Uri.parse('$baseUrl/api/bot/ask');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['reply'] ?? 'I received an empty response.';
        } else {
          return data['reply'] ?? data['message'] ?? 'An error occurred server-side.';
        }
      } else {
        return 'Sorry, I am having trouble connecting to the TruthLens AI backend.';
      }
    } catch (e) {
      return 'Sorry, a network error occurred: $e';
    }
  }
}
