import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import 'chat_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatMessage? _replyingTo;
  ChatMessage? _editingMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatKey() {
    // Create a unique key for this chat conversation
    return 'chat_messages_${widget.user.id}';
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final chatKey = _getChatKey();
    final messagesJson = prefs.getString(chatKey);
    
    if (messagesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        setState(() {
          _messages.clear();
          _messages.addAll(
            decoded.map((json) => ChatMessage.fromJson(json)).toList(),
          );
        });
      } catch (e) {
        // If there's an error loading, start with empty messages
        setState(() {
          _messages.clear();
        });
      }
    }

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final chatKey = _getChatKey();
    final messagesJson = jsonEncode(
      _messages.map((msg) => msg.toJson()).toList(),
    );
    await prefs.setString(chatKey, messagesJson);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      if (_editingMessage != null) {
        // Edit existing message
        final index = _messages.indexWhere((m) => m.id == _editingMessage!.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            message: _messageController.text.trim(),
            isEdited: true,
          );
        }
        _editingMessage = null;
      } else {
        // Send new message
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'me',
            receiverId: widget.user.id,
            message: _messageController.text.trim(),
            timestamp: DateTime.now(),
            isRead: false,
            replyToMessageId: _replyingTo?.id,
            replyToMessage: _replyingTo,
          ),
        );
        _replyingTo = null;
      }
      _messageController.clear();
    });

    // Save messages to persistence
    _saveMessages();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteForMe(ChatMessage message) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isDeletedForMe: true);
      }
    });
    _saveMessages();
  }

  void _deleteForEveryone(ChatMessage message) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isDeletedForEveryone: true);
      }
    });
    _saveMessages();
  }

  void _editMessage(ChatMessage message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.message;
      _replyingTo = null;
    });
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyingTo = message;
      _editingMessage = null;
    });
  }

  void _cancelReplyOrEdit() {
    setState(() {
      _replyingTo = null;
      _editingMessage = null;
      _messageController.clear();
    });
  }

  void _showMessageActions(ChatMessage message, bool isMe) {
    final now = DateTime.now();
    final timeDiff = now.difference(message.timestamp);
    final canDeleteForEveryone = isMe && timeDiff.inHours < 2;
    final canEdit = isMe && timeDiff.inMinutes < 10;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!message.isDeletedForEveryone)
              _buildActionTile(
                icon: Icons.reply,
                label: 'Reply',
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
              ),
            if (canEdit && !message.isDeletedForEveryone)
              _buildActionTile(
                icon: Icons.edit,
                label: 'Edit',
                subtitle: 'Available for 10 minutes',
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
            _buildActionTile(
              icon: Icons.delete_outline,
              label: 'Delete for me',
              onTap: () {
                Navigator.pop(context);
                _deleteForMe(message);
              },
            ),
            if (canDeleteForEveryone && !message.isDeletedForEveryone)
              _buildActionTile(
                icon: Icons.delete_forever,
                label: 'Delete for everyone',
                subtitle: 'Available for 2 hours',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteForEveryoneConfirmation(message);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteForEveryoneConfirmation(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          title: const Text(
            'Delete for everyone?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This message will be deleted for both you and ${widget.user.name}.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteForEveryone(message);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.white,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
    );
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
              _buildHeader(),
              
              // Messages List
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == 'me';
                          final showTimestamp = index == 0 ||
                              _messages[index - 1].timestamp
                                  .difference(message.timestamp)
                                  .inMinutes
                                  .abs() > 30;

                          return Column(
                            children: [
                              if (showTimestamp) _buildTimestamp(message.timestamp),
                              _buildMessageBubble(message, isMe),
                            ],
                          );
                        },
                      ),
              ),

              // Message Input
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
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
                        widget.user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.user.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.user.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: widget.user.isOnline
                            ? AppColors.success
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String displayText;

    if (difference.inDays == 0) {
      displayText = DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays == 1) {
      displayText = 'Yesterday';
    } else if (difference.inDays < 7) {
      displayText = DateFormat('EEEE').format(timestamp);
    } else {
      displayText = DateFormat('MMM d, yyyy').format(timestamp);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    // Don't show deleted messages
    if (message.isDeletedForMe) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _showMessageActions(message, isMe),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isMe ? null : const Color(0xFF0B1220).withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (message.replyToMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: isMe 
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.secondary,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyToMessage!.senderId == 'me' 
                                ? 'You' 
                                : widget.user.name,
                            style: TextStyle(
                              color: isMe 
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.replyToMessage!.isDeletedForEveryone
                                ? 'Message deleted'
                                : message.replyToMessage!.message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontStyle: message.replyToMessage!.isDeletedForEveryone
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Message content
                  Text(
                    message.isDeletedForEveryone 
                        ? 'This message was deleted'
                        : message.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: message.isDeletedForEveryone 
                          ? FontStyle.italic 
                          : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited && !message.isDeletedForEveryone) ...[
                        Text(
                          'Edited',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        DateFormat('h:mm a').format(message.timestamp),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                      if (isMe && !message.isDeletedForEveryone) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Reply or Edit Preview
              if (_replyingTo != null || _editingMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _editingMessage != null 
                              ? AppColors.accent 
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _editingMessage != null 
                                      ? Icons.edit 
                                      : Icons.reply,
                                  size: 16,
                                  color: _editingMessage != null 
                                      ? AppColors.accent 
                                      : AppColors.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _editingMessage != null 
                                      ? 'Edit message' 
                                      : 'Replying to ${_replyingTo!.senderId == 'me' ? 'yourself' : widget.user.name}',
                                  style: TextStyle(
                                    color: _editingMessage != null 
                                        ? AppColors.accent 
                                        : AppColors.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _editingMessage?.message ?? _replyingTo!.message,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onPressed: _cancelReplyOrEdit,
                      ),
                    ],
                  ),
                ),
              // Input Field
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _editingMessage != null 
                                ? 'Edit your message...' 
                                : 'Type a message...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _editingMessage != null ? Icons.check : Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            'Start the conversation!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
