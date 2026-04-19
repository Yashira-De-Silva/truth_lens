import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart' as svc;
import '../profile/profile_provider.dart';
import 'article_model.dart';

class BookmarksNotifier extends StateNotifier<List<Article>> {
  final Ref _ref;
  BookmarksNotifier(this._ref): super([]) {
    _init();
  }

  static const _key = 'bookmarks_v1';

  Future<void> _init() async {
    await _load();
    await _syncWithBackend();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw.map((s) => Article.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _syncWithBackend() async {
    final token = await svc.loadToken();
    if (token == null) return;
    try {
      final remote = await svc.fetchBookmarks(token);
      final remoteArticles = remote.map((b) => Article.fromJson(b['raw_data'] ?? b)).toList();
      
      // Merge unique articles
      final Map<int, Article> merged = {};
      for (var a in state) merged[a.id] = a;
      for (var a in remoteArticles) merged[a.id] = a;
      
      state = merged.values.toList();
      await _save();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = state.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> add(Article a) async {
    if (state.any((x) => x.id == a.id)) return;
    
    final prefs = await SharedPreferences.getInstance();
    final plan = prefs.getString('subscription_plan') ?? 'basic';
    if (plan == 'basic' && state.length >= 10) {
      throw Exception('Upgrade to Premium to save more than 10 articles.');
    }
    
    state = [...state, a];
    await _save();

    // Sync with backend
    final token = await svc.loadToken();
    if (token != null) {
      try {
        await svc.saveBookmark(
          token: token,
          articleId: a.id,
          title: a.title,
          source: a.source,
          summary: a.summary,
          rawData: a.toJson(),
        );
        _ref.read(profileProvider.notifier).refreshFromBackend();
      } catch (_) {}
    }
  }

  Future<void> removeById(int id) async {
    state = state.where((a) => a.id != id).toList();
    await _save();

    // Sync with backend
    final token = await svc.loadToken();
    if (token != null) {
      try {
        await svc.removeBookmark(token, id);
        _ref.read(profileProvider.notifier).refreshFromBackend();
      } catch (_) {}
    }
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<Article>>((ref) => BookmarksNotifier(ref));
