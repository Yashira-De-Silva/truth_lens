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
    
    // Hardening: Don't call backend if the session is known to be expired
    final expired = await svc.isSessionExpired();
    if (expired) return;
    try {
      final data = await svc.me(token);
      final newUser = UserProfile.fromJson(data);
      
      // Safety: If we have a local avatar path and the backend returns null,
      // keep the local one for now (might be a sync delay or ephemeral storage issue)
      if (newUser.avatarPath == null && state.avatarPath != null) {
        state = newUser.copyWith(avatarPath: state.avatarPath);
      } else {
        state = newUser;
      }
      
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
    bool removeImage = false,
  }) async {
    state = state.copyWith(
      name: name,
      email: email,
      bio: bio,
      avatarPath: removeImage ? null : avatarPath,
    );
    await _save();

    final token = await svc.loadToken();
    if (token != null) {
      try {
        final updated = await svc.updateProfile(
          token: token,
          name: name ?? state.name,
          bio: bio ?? state.bio,
          avatarPath: avatarPath,
          removeImage: removeImage,
        );
        
        final newAvatar = updated['profile_image'] as String?;
        state = state.copyWith(
          name: updated['name'] as String?,
          bio: updated['bio'] as String? ?? '',
          apiKey: updated['api_key'] as String?,
          avatarPath: newAvatar ?? state.avatarPath, // Keep existing if backend returns null
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
