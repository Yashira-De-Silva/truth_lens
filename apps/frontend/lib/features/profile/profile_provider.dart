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
      var loadedProfile = UserProfile.fromJson(jsonDecode(raw));
      // Fallback to safe zone if needed
      if (loadedProfile.avatarPath == null) {
        final lastKnown = prefs.getString('last_known_avatar');
        if (lastKnown != null) {
          loadedProfile = loadedProfile.copyWith(avatarPath: lastKnown);
        }
      }
      state = loadedProfile;
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
      
      final prefs = await SharedPreferences.getInstance();
      final lastKnown = prefs.getString('last_known_avatar');
      
      print('DEBUG: Backend profile_image: ${newUser.avatarPath}');
      print('DEBUG: Local safe_zone: $lastKnown');

      // Hardening: Ignore empty strings or paths that are just the base storage URL
      String? backendAvatar = newUser.avatarPath;
      if (backendAvatar != null && (backendAvatar.isEmpty || backendAvatar.endsWith('/storage/'))) {
        backendAvatar = null;
      }

      // Safety: Use backend image if valid, otherwise fallback to our safe zone
      final finalAvatar = backendAvatar ?? lastKnown ?? state.avatarPath;
      print('DEBUG: Final resolved avatar: $finalAvatar');
      
      state = newUser.copyWith(avatarPath: finalAvatar);
      
      final isPremium = data['is_premium'] == 1 || data['is_premium'] == true;
      await prefs.setString('subscription_plan', isPremium ? 'premium' : 'basic');

      await _save();
    } catch (_) {
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    // Explicitly save the avatar path to a separate key for extra safety
    if (state.avatarPath != null) {
      await prefs.setString('last_known_avatar', state.avatarPath!);
    } else {
      await prefs.remove('last_known_avatar');
    }
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
        
        if (removeImage) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('last_known_avatar');
        }

        final newAvatar = updated['profile_image'] as String?;
        String? validatedAvatar = newAvatar;
        if (validatedAvatar != null && (validatedAvatar.isEmpty || validatedAvatar.endsWith('/storage/'))) {
          validatedAvatar = null;
        }

        state = state.copyWith(
          name: updated['name'] as String?,
          bio: updated['bio'] as String? ?? '',
          apiKey: updated['api_key'] as String?,
          avatarPath: validatedAvatar,
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
