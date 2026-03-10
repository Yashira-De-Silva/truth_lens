import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'article_model.dart';

class BookmarksNotifier extends StateNotifier<List<Article>> {
  BookmarksNotifier(): super([]) {
    _load();
  }

  static const _key = 'bookmarks_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw.map((s) => Article.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = state.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> add(Article a) async {
    if (state.any((x) => x.id == a.id)) return;
    
    // Check subscription plan limit
    final prefs = await SharedPreferences.getInstance();
    final plan = prefs.getString('subscription_plan') ?? 'basic';
    if (plan == 'basic' && state.length >= 10) {
      throw Exception('Upgrade to Premium to save more than 10 articles.');
    }
    
    state = [...state, a];
    await _save();
  }

  Future<void> removeById(int id) async {
    state = state.where((a) => a.id != id).toList();
    await _save();
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<Article>>((ref) => BookmarksNotifier());
