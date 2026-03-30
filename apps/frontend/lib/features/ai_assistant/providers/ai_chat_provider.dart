import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message.dart';
import '../services/ai_bot_service.dart';

final aiBotServiceProvider = Provider((ref) => AiBotService());

class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;

  AiChatState({required this.messages, this.isLoading = false});

  AiChatState copyWith({List<AiMessage>? messages, bool? isLoading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref.watch(aiBotServiceProvider));
});

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiBotService _aiBotService;

  AiChatNotifier(this._aiBotService)
      : super(AiChatState(messages: [
          AiMessage.bot('Hello! I am TruthBot. How can I help you today?')
        ]));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    final replyText = await _aiBotService.askBot(text);
    
    final botMsg = AiMessage.bot(replyText);
    state = state.copyWith(
      messages: [...state.messages, botMsg],
      isLoading: false,
    );
  }
}
