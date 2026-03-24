import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../core/services/follow_service.dart' as svc;

final followStatusProvider = FutureProvider.autoDispose
    .family<svc.FollowStatus, int>((ref, userId) async {
      final token = ref.watch(authProvider).token ?? '';
      if (token.isEmpty) return svc.FollowStatus.none();
      return svc.getFollowStatus(token, userId);
    });



final followersProvider = FutureProvider.autoDispose<List<svc.FollowUser>>((
  ref,
) async {
  final token = ref.watch(authProvider).token ?? '';
  if (token.isEmpty) return [];
  return svc.getFollowers(token);
});

// ── Who I follow ──────────────────────────────────────────────────────────────

final followingProvider = FutureProvider.autoDispose<List<svc.FollowUser>>((
  ref,
) async {
  final token = ref.watch(authProvider).token ?? '';
  if (token.isEmpty) return [];
  return svc.getFollowing(token);
});

// ── Public user profile ───────────────────────────────────────────────────────

final publicProfileProvider = FutureProvider.autoDispose
    .family<svc.PublicUserProfile?, int>((ref, userId) async {
      final token = ref.watch(authProvider).token ?? '';
      if (token.isEmpty) return null;
      return svc.getUserProfile(token, userId);
    });
