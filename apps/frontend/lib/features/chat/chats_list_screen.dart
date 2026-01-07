import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import 'chat_model.dart';
import 'chat_screen.dart';
import 'select_user_screen.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  // Mock data for available users
  final List<ChatUser> _availableUsers = [
    ChatUser(
      id: '1',
      name: 'Sarah Johnson',
      email: 'sarah@example.com',
      isOnline: true,
    ),
    ChatUser(
      id: '2',
      name: 'Michael Chen',
      email: 'michael@example.com',
      isOnline: false,
    ),
    ChatUser(
      id: '3',
      name: 'Emma Rodriguez',
      email: 'emma@example.com',
      isOnline: true,
    ),
  ];

  List<ChatConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<ChatConversation> loadedConversations = [];

    for (final user in _availableUsers) {
      final chatKey = 'chat_messages_${user.id}';
      final messagesJson = prefs.getString(chatKey);
      
      if (messagesJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(messagesJson);
          final messages = decoded.map((json) => ChatMessage.fromJson(json)).toList();
          
          if (messages.isNotEmpty) {
            // Get the last message (even if deleted for everyone)
            // Only skip messages deleted for me
            ChatMessage? lastMessage;
            int unreadCount = 0;
            
            for (var i = messages.length - 1; i >= 0; i--) {
              // Show last message even if deleted for everyone
              // Only skip if deleted for me
              if (lastMessage == null && !messages[i].isDeletedForMe) {
                lastMessage = messages[i];
              }
              // Count unread messages
              if (messages[i].senderId != 'me' && !messages[i].isRead && !messages[i].isDeletedForMe) {
                unreadCount++;
              }
            }
            
            if (lastMessage != null) {
              loadedConversations.add(
                ChatConversation(
                  id: user.id,
                  user: user,
                  lastMessage: lastMessage,
                  unreadCount: unreadCount,
                ),
              );
            }
          }
        } catch (e) {
          // Skip if there's an error loading this conversation
          continue;
        }
      }
    }

    // Sort by last message timestamp (most recent first)
    loadedConversations.sort((a, b) {
      if (a.lastMessage == null && b.lastMessage == null) return 0;
      if (a.lastMessage == null) return 1;
      if (b.lastMessage == null) return -1;
      return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
    });

    setState(() {
      _conversations = loadedConversations;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Messages',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectUserScreen(),
                          ),
                        );
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

              // Conversations List
              Expanded(
                child: _conversations.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          return _buildConversationCard(conversation);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationCard(ChatConversation conversation) {
    final formattedTime = _formatTime(conversation.lastMessage?.timestamp);
    final lastMessage = conversation.lastMessage;
    
    // Determine what to display based on message status
    String displayMessage = 'No messages yet';
    bool isItalic = false;
    
    if (lastMessage != null) {
      if (lastMessage.isDeletedForEveryone) {
        displayMessage = 'This message was deleted';
        isItalic = true;
      } else if (lastMessage.isDeletedForMe) {
        displayMessage = 'Message deleted';
        isItalic = true;
      } else {
        // Show "You: " prefix if you sent the message
        final prefix = lastMessage.senderId == 'me' ? 'You: ' : '';
        displayMessage = prefix + lastMessage.message;
      }
    }
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(user: conversation.user),
          ),
        );
        // Reload conversations when returning from chat
        _loadConversations();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: conversation.unreadCount > 0
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
                // Avatar
                Stack(
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
                          conversation.user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (conversation.user.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0B1220),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Message Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conversation.user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: conversation.unreadCount > 0
                                  ? AppColors.secondary
                                  : Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: conversation.unreadCount > 0
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
                                color: conversation.unreadCount > 0
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: conversation.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
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
                                '${conversation.unreadCount}',
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

  Widget _buildEmptyState() {
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
            'No Messages Yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with someone',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectUserScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('New Message'),
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

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
