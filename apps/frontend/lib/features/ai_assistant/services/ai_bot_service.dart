import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';
import '../models/ai_message.dart';

class BotResponse {
  final String reply;
  final List<RelatedNewsItem> relatedNews;

  BotResponse({required this.reply, required this.relatedNews});
}

class AiBotService {
  Future<BotResponse> askBot(String message) async {
    try {
      final baseUrl = await ApiConfig.mlServiceUrl;
      final uri = Uri.parse('$baseUrl/api/bot/ask');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final reply = data['reply'] ?? 'I received an empty response.';
          final rawNews = data['related_news'] as List<dynamic>? ?? [];
          final relatedNews = rawNews
              .map((e) => RelatedNewsItem.fromJson(e as Map<String, dynamic>))
              .toList();
          return BotResponse(reply: reply, relatedNews: relatedNews);
        } else {
          final msg = data['reply'] ?? data['message'] ?? 'An error occurred server-side.';
          return BotResponse(reply: msg, relatedNews: []);
        }
      } else {
        final data = jsonDecode(response.body);
        final serverMsg = data['message'] ?? '';
        if (serverMsg.contains('429') || serverMsg.contains('quota')) {
          return BotResponse(
            reply: 'The AI service has reached its usage limit. Please try again later.',
            relatedNews: [],
          );
        }
        return BotResponse(
          reply: serverMsg.isNotEmpty
              ? 'AI service error: $serverMsg'
              : 'Sorry, I am having trouble connecting to the TruthLens AI backend.',
          relatedNews: [],
        );
      }
    } catch (e) {
      return BotResponse(reply: 'Sorry, a network error occurred: $e', relatedNews: []);
    }
  }
}
