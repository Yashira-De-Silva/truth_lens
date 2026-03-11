import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart' as svc;
import 'profile_model.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier()
      : super(UserProfile(name: 'User Name', email: 'user@example.com')) {
    _load();
  }

  static const _key = 'user_profile_v1';

  // ── Load: local cache first, then refresh from backend ──────────────────

  Future<void> _load() async {
    // 1. Load locally persisted profile immediately for fast UI
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = UserProfile.fromJson(jsonDecode(raw));
    }

    // 2. Refresh from backend if we have a token
    await refreshFromBackend();
  }

  /// Fetch the latest user data from GET /api/me and update state + cache.
  Future<void> refreshFromBackend() async {
    final token = await svc.loadToken();
    if (token == null) return;
    try {
      final data = await svc.me(token);
      // Merge backend data but preserve local-only fields (phone, avatarPath)
      state = state.copyWith(
        name: data['name'] as String?,
        email: data['email'] as String?,
        bio: data['bio'] as String? ?? '',
        apiKey: data['api_key'] as String?,
        avatarPath: data['profile_image'] as String? ?? state.avatarPath,
        id: data['id'] as int?,
      );
      
      final isPremium = data['is_premium'] == 1 || data['is_premium'] == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_plan', isPremium ? 'premium' : 'basic');

      await _save();
    } catch (_) {
      // Silently fail — cached data stays
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  // ── Update locally (edit profile form) ──────────────────────────────────

  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? avatarPath,
  }) async {
    state = state.copyWith(
      name: name,
      email: email,
      bio: bio,
      avatarPath: avatarPath,
    );
    await _save();

    // Sync name & bio to backend
    final token = await svc.loadToken();
    if (token != null) {
      try {
        final updated = await svc.updateProfile(
          token: token,
          name: name ?? state.name,
          bio: bio ?? state.bio,
        );
        // Update state with confirmed backend data
        state = state.copyWith(
          name: updated['name'] as String?,
          bio: updated['bio'] as String? ?? '',
          apiKey: updated['api_key'] as String?,
        );
        await _save();
      } catch (_) {
        // Local update already applied — backend sync failed silently
      }
    }
  }

  Future<void> upgradeToPremium() async {
    final token = await svc.loadToken();
    if (token != null) {
      await svc.upgradeToPremium(token);
      await refreshFromBackend();
    }
  }

  Future<void> cancelPremium() async {
    final token = await svc.loadToken();
    if (token != null) {
      await svc.cancelPremium(token);
      await refreshFromBackend();
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>(
  (ref) => ProfileNotifier(),
);
