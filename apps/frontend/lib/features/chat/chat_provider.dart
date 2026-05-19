import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'chat_service.dart' as svc;

final chatUsersProvider = FutureProvider.autoDispose<List<svc.BackendUser>>((
  ref,
) async {
  final token = ref.watch(authProvider).token;
  if (token == null || token.isEmpty) return [];
  return svc.getUsers(token);
});

class ConversationsState {
  final List<svc.BackendConversation> conversations;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
    this.isAuthenticated = true,
  });

  ConversationsState copyWith({
    List<svc.BackendConversation>? conversations,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isAuthenticated,
  }) => ConversationsState(
    conversations: conversations ?? this.conversations,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
  );
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final String token;
  final AuthStatus authStatus;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 8);

  ConversationsNotifier(this.token, this.authStatus)
    : super(const ConversationsState(isLoading: true)) {
    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      // Auth is still restoring from storage — don't show error, just wait.
      // The provider will rebuild with the correct token once auth settles.
      state = const ConversationsState(isLoading: true, isAuthenticated: true);
    } else if (token.isEmpty || authStatus == AuthStatus.unauthenticated) {
      state = const ConversationsState(isLoading: false, isAuthenticated: false);
    } else {
      load();
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    if (token.isEmpty) return;
    try {
      final convs = await svc.getConversations(token);
      if (!mounted) return;
      // Compare by last-message id or unread count to detect real changes
      final hasChanges = convs.length != state.conversations.length ||
          convs.asMap().entries.any((e) {
            final old = state.conversations.length > e.key
                ? state.conversations[e.key]
                : null;
            if (old == null) return true;
            return e.value.lastMessage?.id != old.lastMessage?.id ||
                e.value.unreadCount != old.unreadCount;
          });
      if (hasChanges) {
        state = state.copyWith(conversations: convs, clearError: true);
      }
    } catch (_) {}
  }

  Future<void> load() async {
    if (token.isEmpty) {
      state = const ConversationsState(isAuthenticated: false);
      return;
    }
    // Only show spinner on the very first load (no conversations yet)
    if (state.conversations.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final convs = await svc.getConversations(token);
      if (!mounted) return;
      state = state.copyWith(
        conversations: convs,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      if (!mounted) return;
      final errStr = e.toString();
      final isAuth =
          !errStr.contains('401') && !errStr.contains('Unauthenticated');
      state = state.copyWith(
        isLoading: false,
        error: errStr,
        isAuthenticated: isAuth,
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
      final authState = ref.watch(authProvider);
      return ConversationsNotifier(authState.token ?? '', authState.status);
    });
class MessagesState {
  final List<svc.BackendMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  MessagesState copyWith({
    List<svc.BackendMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) => MessagesState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    isSending: isSending ?? this.isSending,
    error: clearError ? null : (error ?? this.error),
  );
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final String token;
  final String conversationId;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 5);

  MessagesNotifier(this.token, this.conversationId)
    : super(const MessagesState(isLoading: true)) {
    load();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _silentRefresh());
  }
  Future<void> _silentRefresh() async {
    if (token.isEmpty) return;
    try {
      final msgs = await svc.getMessages(token, conversationId);
      if (!mounted) return;
      // Detect new messages or edits/deletions by checking last id
      final lastNew = msgs.isNotEmpty ? msgs.last.id : null;
      final lastOld =
          state.messages.isNotEmpty ? state.messages.last.id : null;
      if (lastNew != lastOld || msgs.length != state.messages.length) {
        state = state.copyWith(messages: msgs, clearError: true);
      }
    } catch (_) {}
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final msgs = await svc.getMessages(token, conversationId);
      if (!mounted) return;
      state = state.copyWith(messages: msgs, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> send(String body, {int? replyToId}) async {
    if (body.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      final msg = await svc.sendMessage(
        token,
        conversationId,
        body.trim(),
        replyToId: replyToId,
      );
      if (!mounted) return;
      state = state.copyWith(
        messages: [...state.messages, msg],
        isSending: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> delete(int messageId, String scope) async {
    try {
      await svc.deleteMessage(token, messageId, scope);
      await load();
    } catch (_) {}
  }

  Future<void> markRead() async {
    try {
      await svc.markConversationRead(token, conversationId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
final messagesProvider = StateNotifierProvider.autoDispose
    .family<MessagesNotifier, MessagesState, String>((ref, conversationId) {
      final token = ref.watch(authProvider).token ?? '';
      return MessagesNotifier(token, conversationId);
    });
