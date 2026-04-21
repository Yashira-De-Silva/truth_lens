import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../news/article_model.dart';
import 'comment_model.dart';
import 'comment_provider.dart';
import '../profile/profile_provider.dart';
import '../auth/auth_service.dart' as svc;
import '../news/news_providers.dart';

class ArticleDetailsScreen extends ConsumerStatefulWidget {
  final Article? article;
  const ArticleDetailsScreen({this.article, super.key});

  @override
  ConsumerState<ArticleDetailsScreen> createState() =>
      _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends ConsumerState<ArticleDetailsScreen> {
  bool showSummary = true;
  String? _aiSummary;
  bool _isSummarizing = false;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  int get _articleId => widget.article?.id ?? 0;

  @override
  void initState() {
    super.initState();
    _aiSummary = widget.article?.summary;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(commentsProvider(_articleId).notifier).load();
      
      // Log read activity
      if (widget.article != null) {
        final token = await svc.loadToken();
        if (token != null) {
          await svc.logRead(token, widget.article!.id);
          // Refresh profile stats after reading
          ref.read(profileProvider.notifier).refreshFromBackend();
        }

        // Start dynamic summarization if it's a long article
        if (widget.article!.fullText != null && widget.article!.fullText!.length > 500) {
          _fetchAiSummary();
        }
      }
    });
  }

  Future<void> _fetchAiSummary() async {
    if (widget.article == null || widget.article!.fullText == null) return;
    
    setState(() {
      _isSummarizing = true;
    });

    try {
      final summary = await ref.read(newsApiProvider).summarizeArticle(widget.article!.fullText!);
      if (mounted) {
        setState(() {
          _aiSummary = summary;
          _isSummarizing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSummarizing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    _commentFocusNode.unfocus();
    await ref.read(commentsProvider(_articleId).notifier).addComment(text);
  }

  Future<void> _toggleLike(Comment comment) async {
    await ref
        .read(commentsProvider(_articleId).notifier)
        .toggleLike(comment.id);
  }

  Future<void> _deleteComment(int commentId) async {
    await ref
        .read(commentsProvider(_articleId).notifier)
        .deleteComment(commentId);
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

    final double fakeProbability;
    if (widget.article == null) {
      fakeProbability = 0.18;
    } else {
      // Standardize confidence mapping for display
      if (widget.article!.label == 'FAKE') {
        fakeProbability = widget.article!.confidence;
      } else if (widget.article!.label == 'REAL') {
        fakeProbability = 1.0 - widget.article!.confidence;
      } else {
        fakeProbability = 0.5; // Verifying state
      }
    }

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
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
                                _isSummarizing 
                                  ? Row(
                                      children: [
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'AI is summarizing...',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      showSummary
                                          ? (_aiSummary ??
                                                'No summary available.')
                                          : (widget.article?.fullText != null &&
                                                        widget
                                                            .article!
                                                            .fullText!
                                                            .isNotEmpty
                                                    ? widget.article!.fullText!
                                                    : (widget.article?.summary ??
                                                          'No content available.')) +
                                                (widget.article?.url != null
                                                    ? '\n\nOriginal article is available at:\n${widget.article!.url}'
                                                    : ''),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 15,
                                        height: 1.6,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final isSubmitting = ref
                                      .watch(commentsProvider(_articleId))
                                      .isSubmitting;
                                  return Container(
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
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, _) {
                          final state = ref.watch(commentsProvider(_articleId));
                          if (state.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (state.error != null && state.comments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Could not load comments.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          if (state.comments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'No comments yet. Be the first!',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: state.comments
                                .map((c) => _buildCommentItem(c))
                                .toList(),
                          );
                        },
                      ),
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
    final profile = ref.read(profileProvider);
    final isOwn = profile.id != null && profile.id == comment.userId;
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
              if (isOwn) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _deleteComment(comment.id),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ),
              ],
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
}
