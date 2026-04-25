import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'chat_service.dart' as svc;

class CallState {
  final Map<String, dynamic>? activeCall;
  final bool isLoading;

  CallState({this.activeCall, this.isLoading = false});

  CallState copyWith({
    Map<String, dynamic>? activeCall,
    bool clearCall = false,
    bool? isLoading,
  }) {
    return CallState(
      activeCall: clearCall ? null : (activeCall ?? this.activeCall),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CallNotifier extends StateNotifier<CallState> {
  final Ref ref;
  Timer? _pollTimer;

  CallNotifier(this.ref) : super(CallState()) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && _pollTimer == null) {
        _startPolling();
      } else if (next.token == null && _pollTimer != null) {
        _stopPolling();
      }
    }, fireImmediately: true);
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollActiveCall();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (state.activeCall != null) {
      state = state.copyWith(clearCall: true);
    }
  }

  Future<void> _pollActiveCall() async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    try {
      final call = await svc.getActiveCall(token);
      if (call == null || call['status'] == 'ended' || call['status'] == 'rejected') {
        if (state.activeCall != null) {
          state = state.copyWith(clearCall: true);
        }
      } else {
        // Simplistic check by serializing to string, or just update blindly
        final currStr = state.activeCall?.toString();
        final newStr = call.toString();
        if (currStr != newStr) {
          state = state.copyWith(activeCall: call);
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<int?> initiate(int receiverId, {bool isVideo = false}) async {
    final token = ref.read(authProvider).token;
    if (token == null) return null;
    
    state = state.copyWith(isLoading: true);
    try {
      final call = await svc.initiateCall(token, receiverId, isVideo: isVideo);
      state = state.copyWith(activeCall: call, isLoading: false);
      return call['id'] as int;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  Future<void> updateStatus(int callId, String status) async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    try {
      if (state.activeCall != null && state.activeCall!['id'] == callId) {
        final updatedCall = Map<String, dynamic>.from(state.activeCall!);
        updatedCall['status'] = status;
        state = state.copyWith(activeCall: updatedCall);
      }
      await svc.updateCallStatus(token, callId, status);
      if (status == 'ended' || status == 'rejected') {
        state = state.copyWith(clearCall: true);
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier(ref);
});
