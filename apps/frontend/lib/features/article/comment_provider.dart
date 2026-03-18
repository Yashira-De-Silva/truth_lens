import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_model.dart';
import 'comment_service.dart';
class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
class CommentsNotifier extends StateNotifier<CommentsState> {
  CommentsNotifier(this._articleId) : super(const CommentsState());

  final int _articleId;
  final _service = CommentService();

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final comments = await _service.fetchComments(_articleId);
      state = state.copyWith(isLoading: false, comments: comments);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final comment = await _service.addComment(_articleId, text.trim());
      state = state.copyWith(
        isSubmitting: false,
        comments: [comment, ...state.comments],
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteComment(int commentId) async {
    try {
      await _service.deleteComment(commentId);
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── Toggle like ────────────────────────────────────────────────────────────

  Future<void> toggleLike(int commentId) async {
    // Optimistic update
    state = state.copyWith(
      comments: state.comments.map((c) {
        if (c.id != commentId) return c;
        return c.copyWith(
          isLiked: !c.isLiked,
          likes: c.isLiked ? c.likes - 1 : c.likes + 1,
        );
      }).toList(),
    );

    try {
      final result = await _service.toggleLike(commentId);
      // Sync with server truth
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.id != commentId) return c;
          return c.copyWith(likes: result.likes, isLiked: result.isLiked);
        }).toList(),
      );
    } catch (e) {
      // Rollback optimistic update
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.id != commentId) return c;
          return c.copyWith(
            isLiked: !c.isLiked,
            likes: c.isLiked ? c.likes - 1 : c.likes + 1,
          );
        }).toList(),
        error: e.toString(),
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Family provider — one notifier per article id.
final commentsProvider = StateNotifierProvider.family<
    CommentsNotifier, CommentsState, int>((ref, articleId) {
  return CommentsNotifier(articleId);
});
