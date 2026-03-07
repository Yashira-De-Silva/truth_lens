import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'chat_provider.dart';
import 'chat_service.dart';
import 'chat_screen.dart';
import 'select_user_screen.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0A2540)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.messages,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectUserScreen(),
                          ),
                        );
                        ref.read(conversationsProvider.notifier).load();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_square,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      )
                    : !state.isAuthenticated
                    ? _buildNotLoggedIn(context)
                    : state.error != null && state.conversations.isEmpty
                    ? _buildError(context, ref, state.error!)
                    : state.conversations.isEmpty
                    ? _buildEmptyState(context, ref)
                    : RefreshIndicator(
                        color: AppColors.secondary,
                        backgroundColor: const Color(0xFF0B1220),
                        onRefresh: () =>
                            ref.read(conversationsProvider.notifier).load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.conversations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) =>
                              _buildCard(ctx, ref, state.conversations[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    BackendConversation conv,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final last = conv.lastMessage;
    String displayMessage = l10n.noMessages;
    bool isItalic = false;
    if (last != null) {
      if (last.deletedForEveryone) {
        displayMessage = l10n.thisMessageWasDeleted;
        isItalic = true;
      } else if (last.deletedForMe) {
        displayMessage = l10n.messageDeleted;
        isItalic = true;
      } else {
        displayMessage = last.body;
      }
    }
    final formattedTime = last != null
        ? _formatTime(DateTime.tryParse(last.createdAt))
        : '';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conv.conversationId,
              otherUser: conv.otherUser,
            ),
          ),
        );
        ref.read(conversationsProvider.notifier).load();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: conv.unreadCount > 0
                ? AppColors.secondary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.secondary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      conv.otherUser.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conv.otherUser.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: conv.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: conv.unreadCount > 0
                                  ? AppColors.secondary
                                  : Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: conv.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayMessage,
                              style: TextStyle(
                                color: conv.unreadCount > 0
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: conv.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontStyle: isItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 72,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Log in to access messages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to start chatting with other users',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noMessagesYet,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startConversation,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelectUserScreen()),
              );
              ref.read(conversationsProvider.notifier).load();
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.newMessage),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load messages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(conversationsProvider.notifier).load(),
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time.toLocal());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(time.toLocal());
  }
}
