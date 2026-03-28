import 'dart:async';

class AiService {
  Future<String> summarize(String article) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'This is a 3-4 line AI summary of the article, intended as a mock.';
  }

  Future<double> fakeNewsScore(String article) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 0.18;
  }

  Future<String> detectBias(String article) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'neutral';
  }
}
