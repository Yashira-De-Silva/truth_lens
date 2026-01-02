import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_model.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier()
      : super(UserProfile(
          name: 'User Name',
          email: 'user@example.com',
        )) {
    _load();
  }

  static const _key = 'user_profile_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = UserProfile.fromJson(jsonDecode(raw));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      bio: bio,
    );
    await _save();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) => ProfileNotifier());
