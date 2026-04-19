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

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = UserProfile.fromJson(jsonDecode(raw));
    }
    await refreshFromBackend();
  }

    Future<void> refreshFromBackend() async {
    final token = await svc.loadToken();
    if (token == null) return;
    try {
      final data = await svc.me(token);
      state = UserProfile.fromJson(data);
      
      final isPremium = data['is_premium'] == 1 || data['is_premium'] == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_plan', isPremium ? 'premium' : 'basic');

      await _save();
    } catch (_) {
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

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

    final token = await svc.loadToken();
    if (token != null) {
      try {
        final updated = await svc.updateProfile(
          token: token,
          name: name ?? state.name,
          bio: bio ?? state.bio,
        );
        state = state.copyWith(
          name: updated['name'] as String?,
          bio: updated['bio'] as String? ?? '',
          apiKey: updated['api_key'] as String?,
        );
        await _save();
      } catch (_) {
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
