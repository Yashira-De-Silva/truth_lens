import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart' as svc;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    Map<String, dynamic>? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        token: token ?? this.token,
        user: user ?? this.user,
        error: error ?? this.error,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  String get displayName => user?['name'] as String? ?? 'User';
  String get displayEmail => user?['email'] as String? ?? '';
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restore();
  }
  Future<void> _restore() async {
    final token = await svc.loadToken();
    final user = await svc.loadUser();
    if (token != null && user != null) {
      final expired = await svc.isSessionExpired();
      if (expired) {
        await svc.clearToken();
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final result = await svc.register(
        name: name,
        email: email,
        password: password,
      );
      await Future.wait([
        svc.saveToken(result.token),
        svc.saveUser(result.user),
        svc.saveLoginTimestamp(),
      ]);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: result.token,
        user: result.user,
      );
    } on svc.AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Could not connect to server. Check your connection.',
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final result = await svc.login(email: email, password: password);
      await Future.wait([
        svc.saveToken(result.token),
        svc.saveUser(result.user),
        svc.saveLoginTimestamp(),
      ]);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: result.token,
        user: result.user,
      );
    } on svc.AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Could not connect to server. Check your connection.',
      );
    }
  }

  Future<void> logout() async {
    final token = state.token;
    state = state.copyWith(status: AuthStatus.loading);
    if (token != null) await svc.logout(token);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: null,
      );
    }
  }
}
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
