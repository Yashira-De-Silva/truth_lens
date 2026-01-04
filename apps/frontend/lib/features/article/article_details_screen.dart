import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../news/article_model.dart';
import 'comment_model.dart';
import '../profile/profile_provider.dart';

class ArticleDetailsScreen extends ConsumerStatefulWidget {
  final Article? article;
  const ArticleDetailsScreen({this.article, super.key});

  @override
  ConsumerState<ArticleDetailsScreen> createState() =>
      _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends ConsumerState<ArticleDetailsScreen> {
  bool showSummary = true;
  double fakeProbability = 0.18; // mock

  // Comments state
  final List<Comment> _comments = [
    Comment(
      id: 1,
      userName: 'Kasun Silva',
      userAvatar: 'assets/avatar1.png',
      text: 'This is very informative. Thanks for sharing!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      isLiked: false,
    ),
    Comment(
      id: 2,
      userName: 'Nimali Fernando',
      userAvatar: 'assets/avatar2.png',
      text: 'I had doubts about this news. Good to see the verification.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 8,
      isLiked: true,
    ),
    Comment(
      id: 3,
      userName: 'Ravindu Perera',
      userAvatar: 'assets/avatar3.png',
      text: 'Can you provide more sources?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 3,
      isLiked: false,
    ),
  ];

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    // Read current user profile from provider
    final profile = ref.read(profileProvider);
    final displayName = profile.name.isNotEmpty ? profile.name : 'User';

    setState(() {
      _comments.insert(
        0,
        Comment(
          id: _comments.length + 1,
          userName: displayName,
          userAvatar: 'assets/default_avatar.png',
          text: _commentController.text.trim(),
          timestamp: DateTime.now(),
          likes: 0,
          isLiked: false,
        ),
      );
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }

  void _toggleLike(Comment comment) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(
          isLiked: !comment.isLiked,
          likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
        );
      }
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isVerified = fakeProbability < 0.3;
    final isBiased = fakeProbability >= 0.3 && fakeProbability < 0.7;
    final statusColor = isVerified
        ? AppColors.success
        : (isBiased ? AppColors.accent : AppColors.error);
    final statusText = isVerified
        ? 'Verified'
        : (isBiased ? 'Biased' : 'Possibly Fake');

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
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.article?.title ?? 'Sample headline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => showSummary = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: showSummary
                                ? const Color(0xFF0B1220).withValues(alpha: 0.8)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: showSummary
                                    ? AppColors.secondary
                                    : Colors.white.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'AI Summary',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: showSummary
                                  ? AppColors.secondary
                                  : Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => showSummary = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !showSummary
                                ? const Color(0xFF0B1220).withValues(alpha: 0.8)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: !showSummary
                                    ? AppColors.secondary
                                    : Colors.white.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Full Article',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !showSummary
                                  ? AppColors.secondary
                                  : Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Misinformation Confidence
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Misinformation Confidence: ${(fakeProbability * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: 1 - fakeProbability,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    color: statusColor,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Summary/Article Content
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Text(
                              showSummary
                                  ? (widget.article?.summary ??
                                        'AI generated 3-4 line summary...')
                                  : 'Full article content would be displayed here. This is a detailed view of the article with all the information from the original source. The content would include all paragraphs, quotes, and supporting information that provides comprehensive coverage of the news story.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Related trusted sources
                      Text(
                        'Related trusted sources',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSourceChip('Trusted Source A'),
                          _buildSourceChip('Trusted Source B'),
                          _buildSourceChip('Trusted Source C'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Comments Section
                      Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Comment input
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.secondary.withValues(
                                alpha: 0.2,
                              ),
                              child: profile.name.isNotEmpty
                                  ? Text(
                                      profile.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _addComment,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      Color(0xFF4338CA),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comments list
                      ..._comments.map((comment) => _buildCommentItem(comment)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: AppColors.secondary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getTimeAgo(comment.timestamp),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleLike(comment),
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: comment.isLiked
                          ? AppColors.error
                          : Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likes}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0A2540),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
