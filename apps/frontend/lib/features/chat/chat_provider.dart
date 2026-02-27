import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'chat_service.dart' as svc;

// ── Users list provider ───────────────────────────────────────────────────────

final chatUsersProvider =
    FutureProvider.autoDispose<List<svc.BackendUser>>((ref) async {
  final token = ref.watch(authProvider).token;
  if (token == null) return [];
  return svc.getUsers(token);
});

// ── Conversations list state ──────────────────────────────────────────────────

class ConversationsState {
  final List<svc.BackendConversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<svc.BackendConversation>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      ConversationsState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final String token;

  ConversationsNotifier(this.token)
      : super(const ConversationsState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final convs = await svc.getConversations(token);
      state = state.copyWith(conversations: convs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final conversationsProvider =
    StateNotifierProvider.autoDispose<ConversationsNotifier, ConversationsState>(
  (ref) {
    final token = ref.watch(authProvider).token ?? '';
    return ConversationsNotifier(token);
  },
);

// ── Messages state ────────────────────────────────────────────────────────────

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
  }) =>
      MessagesState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: error,
      );
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final String token;
  final String conversationId;

  MessagesNotifier(this.token, this.conversationId)
      : super(const MessagesState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final msgs = await svc.getMessages(token, conversationId);
      state = state.copyWith(messages: msgs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> send(String body, {int? replyToId}) async {
    if (body.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      final msg = await svc.sendMessage(token, conversationId, body.trim(),
          replyToId: replyToId);
      state = state.copyWith(
        messages: [...state.messages, msg],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> delete(int messageId, String scope) async {
    try {
      await svc.deleteMessage(token, messageId, scope);
      // Reload to get fresh deleted flags from server
      await load();
    } catch (_) {}
  }

  Future<void> markRead() async {
    try {
      await svc.markConversationRead(token, conversationId);
    } catch (_) {}
  }
}

/// Family provider — one MessagesNotifier per conversationId.
final messagesProvider = StateNotifierProvider.autoDispose
    .family<MessagesNotifier, MessagesState, String>(
  (ref, conversationId) {
    final token = ref.watch(authProvider).token ?? '';
    return MessagesNotifier(token, conversationId);
  },
);
