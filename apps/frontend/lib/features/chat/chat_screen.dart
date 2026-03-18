import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'chat_provider.dart';
import 'chat_service.dart' as svc;
import 'chat_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final svc.BackendUser otherUser;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  svc.BackendMessage? _replyingTo;
  ChatTheme _currentTheme = ChatTheme.classic;

  @override
  void initState() {
    super.initState();
    _loadChatTheme();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeKey = 'chat_theme_${widget.conversationId}';
    final themeTypeString = prefs.getString(themeKey);
    final themeType = ChatTheme.typeFromString(themeTypeString);
    if (mounted) {
      setState(() {
        _currentTheme = ChatTheme.fromType(themeType);
      });
    }
  }

  Future<void> _saveChatTheme(ChatTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final themeKey = 'chat_theme_${widget.conversationId}';
    await prefs.setString(themeKey, theme.type.toString());
    setState(() {
      _currentTheme = theme;
    });
  }

  int get _myId {
    final user = ref.read(authProvider).user;
    if (user == null) return 0;
    return int.tryParse(user['id'].toString()) ?? 0;
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final replyId = _replyingTo?.id;
    setState(() {
      _replyingTo = null;
    });
    _messageController.clear();
    await ref
        .read(messagesProvider(widget.conversationId).notifier)
        .send(text, replyToId: replyId);
    _scrollToBottom();
  }

  Future<void> _deleteForMe(svc.BackendMessage message) async {
    await ref
        .read(messagesProvider(widget.conversationId).notifier)
        .delete(message.id, 'me');
  }

  Future<void> _deleteForEveryone(svc.BackendMessage message) async {
    await ref
        .read(messagesProvider(widget.conversationId).notifier)
        .delete(message.id, 'everyone');
  }

  void _replyToMessage(svc.BackendMessage message) {
    setState(() {
      _replyingTo = message;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _messageController.clear();
    });
  }

  void _showThemeSelector() {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  const Text(
                    'Choose Chat Theme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ChatTheme.allThemes.length,
                itemBuilder: (context, index) {
                  final theme = ChatTheme.allThemes[index];
                  final isSelected = theme.type == _currentTheme.type;
                  return GestureDetector(
                    onTap: () {
                      _saveChatTheme(theme);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: theme.backgroundGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.myMessageColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.theirMessageColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            theme.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            Icon(
                              Icons.check_circle,
                              color: AppColors.secondary,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showMessageActions(svc.BackendMessage message, bool isMe) {
    final now = DateTime.now();
    final sent = DateTime.tryParse(message.createdAt) ?? now;
    final timeDiff = now.difference(sent);
    final canDeleteForEveryone =
        isMe && timeDiff.inHours < 2 && !message.deletedForEveryone;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
            if (!message.deletedForEveryone)
              _buildActionTile(
                icon: Icons.reply,
                label: 'Reply',
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
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
            if (canDeleteForEveryone)
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

  void _showDeleteForEveryoneConfirmation(svc.BackendMessage message) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Delete for everyone?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This message will be deleted for both you and ${widget.otherUser.name}.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteForEveryone(message);
              },
              child: Text('Delete',
                  style: TextStyle(color: AppColors.error)),
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
      leading: Icon(icon, color: color ?? Colors.white),
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
    final msgsState = ref.watch(messagesProvider(widget.conversationId));
    final myId = _myId;

    // Auto-scroll when new messages arrive
    if (!msgsState.isLoading && msgsState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: _currentTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: msgsState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : msgsState.messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: msgsState.messages.length,
                            itemBuilder: (context, index) {
                              final msg = msgsState.messages[index];
                              final isMe = msg.senderId == myId;
                              final showTimestamp = index == 0 ||
                                  _timeDiffMinutes(
                                        msgsState.messages[index - 1]
                                            .createdAt,
                                        msg.createdAt,
                                      ) >
                                      30;
                              return Column(
                                children: [
                                  if (showTimestamp)
                                    _buildTimestamp(msg.createdAt),
                                  _buildMessageBubble(msg, isMe, myId),
                                ],
                              );
                            },
                          ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  int _timeDiffMinutes(String earlier, String later) {
    final a = DateTime.tryParse(earlier);
    final b = DateTime.tryParse(later);
    if (a == null || b == null) return 0;
    return b.difference(a).inMinutes.abs();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
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
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
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
                widget.otherUser.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.otherUser.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showThemeSelector,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildTimestamp(String createdAt) {
    final timestamp = DateTime.tryParse(createdAt) ?? DateTime.now();
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

  Widget _buildMessageBubble(
      svc.BackendMessage message, bool isMe, int myId) {
    if (message.deletedForMe) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showMessageActions(message, isMe),
            onLongPress: () => _showMessageActions(message, isMe),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? _currentTheme.myMessageColor
                    : _currentTheme.theirMessageColor,
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
                  if (message.replyTo != null) ...[
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
                                : _currentTheme.myMessageColor
                                    .withValues(alpha: 0.8),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.replyTo!.senderId == myId
                                ? 'You'
                                : widget.otherUser.name,
                            style: TextStyle(
                              color: isMe
                                  ? _currentTheme.myMessageTextColor
                                      .withValues(alpha: 0.9)
                                  : _currentTheme.myMessageColor
                                      .withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.replyTo!.body,
                            style: TextStyle(
                              color: isMe
                                  ? _currentTheme.myMessageTextColor
                                      .withValues(alpha: 0.6)
                                  : _currentTheme.theirMessageTextColor
                                      .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text(
                    message.deletedForEveryone
                        ? 'This message was deleted'
                        : message.body,
                    style: TextStyle(
                      color: isMe
                          ? _currentTheme.myMessageTextColor
                          : _currentTheme.theirMessageTextColor,
                      fontSize: 15,
                      fontStyle: message.deletedForEveryone
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(
                          DateTime.tryParse(message.createdAt) ??
                              DateTime.now(),
                        ),
                        style: TextStyle(
                          color: isMe
                              ? _currentTheme.myMessageTextColor
                                  .withValues(alpha: 0.6)
                              : _currentTheme.theirMessageTextColor
                                  .withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                      if (isMe && !message.deletedForEveryone) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppColors.accent
                              : _currentTheme.myMessageTextColor
                                  .withValues(alpha: 0.6),
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
          top:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              if (_replyingTo != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
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
                                Icon(Icons.reply,
                                    size: 16,
                                    color: AppColors.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Replying to ${_replyingTo!.senderId == _myId ? 'yourself' : widget.otherUser.name}',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _replyingTo!.body,
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color:
                                Colors.white.withValues(alpha: 0.6),
                            size: 20),
                        onPressed: _cancelReply,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentTheme.inputBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _currentTheme.inputBorderColor,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style:
                              const TextStyle(color: Colors.white),
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization:
                              TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            isDense: true,
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
                              AppColors.secondary
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 20),
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
