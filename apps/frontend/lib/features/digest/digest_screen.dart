import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../news/article_model.dart';
import '../article/article_details_screen.dart';
import '../news/bookmarks_provider.dart';
import '../../core/widgets/app_snackbar.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _digestSvcProvider = Provider<NewsApiService>((ref) => NewsApiService());

/// Fetches live Guardian news, picks the top 5 most-confidently REAL articles.
/// Falls back to the Kaggle /news/digest endpoint if Guardian key not set.
final digestProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final svc = ref.watch(_digestSvcProvider);

  // Try live first (Guardian endpoint returns [] if no API key configured)
  final live = await svc.fetchLiveNews(limit: 30);
  if (live.isNotEmpty) {
    // Keep only REAL articles, sorted by confidence desc, top 5
    final real = live.where((a) => a.label == 'REAL').toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    if (real.isNotEmpty) return real.take(5).toList();
  }

  // Fallback: Kaggle dataset top verified articles
  return svc.fetchDigest(limit: 5);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDigest = ref.watch(digestProvider);
    final isLive = asyncDigest.value?.any((a) => a.isLive) ?? false;

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
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/logo/truthlenslogo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.digest,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Row(
                                children: [
                                  if (isLive) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      'Live from The Guardian',
                                      style: TextStyle(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      l10n.todayDigest,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref.refresh(digestProvider),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0B1220,
                              ).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    asyncDigest.when(
                      data: (articles) => _buildStatsRow(articles, isLive),
                      loading: () => _buildStatsRow([], false),
                      error: (_, __) => _buildStatsRow([], false),
                    ),
                  ],
                ),
              ),

              // ── Article List ─────────────────────────────────────
              Expanded(
                child: asyncDigest.when(
                  loading: () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.success),
                        const SizedBox(height: 16),
                        Text(
                          'Finding top verified articles…',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not load digest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make sure the ML service is running',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => ref.refresh(digestProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (articles) => articles.isEmpty
                      ? Center(
                          child: Text(
                            'No verified articles found',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: articles.length,
                          itemBuilder: (context, index) => _DigestCard(
                            article: articles[index],
                            rank: index + 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<Article> articles, bool isLive) {
    final count = articles.isEmpty ? '—' : '${articles.length}';
    final avgConf = articles.isEmpty
        ? 0
        : (articles.map((a) => a.confidence).reduce((a, b) => a + b) /
                  articles.length *
                  100)
              .toInt();
    final confText = articles.isEmpty ? '—' : '$avgConf%';

    return Row(
      children: [
        _statChip(Icons.article, count, 'Articles'),
        const SizedBox(width: 8),
        _statChip(Icons.verified_user, confText, 'Avg Conf'),
        const SizedBox(width: 8),
        _statChip(
          isLive ? Icons.cell_tower : Icons.psychology,
          isLive ? 'Live' : 'Dataset',
          'Source',
          accent: isLive ? Colors.redAccent : AppColors.secondary,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label, {Color? accent}) {
    final col = accent ?? AppColors.secondary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: col, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Digest Card ───────────────────────────────────────────────────────────────

class _DigestCard extends ConsumerWidget {
  final Article article;
  final int rank;
  const _DigestCard({required this.article, required this.rank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final confidencePct = (article.confidence * 100).toInt();
    final bookmarks = ref.watch(bookmarksProvider);
    final isSaved = bookmarks.any((a) => a.id == article.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailsScreen(article: article),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: article.isLive
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : AppColors.success.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: rank + badge + bookmark ────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rank circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success,
                                AppColors.success.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '#$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Live pill
                              if (article.isLive)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fiber_manual_record,
                                        color: Colors.redAccent,
                                        size: 8,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Verified badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified · $confidencePct%',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Source + date
                              Text(
                                article.source,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (article.published != null &&
                                  article.published!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDigestDate(article.published!),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Bookmark icon
                        GestureDetector(
                          onTap: () async {
                            if (isSaved) {
                              await ref
                                  .read(bookmarksProvider.notifier)
                                  .removeById(article.id);
                              if (context.mounted)
                                AppSnackbar.showSuccess(
                                  context,
                                  l10n.removedFromBookmarks,
                                );
                            } else {
                              try {
                                await ref
                                    .read(bookmarksProvider.notifier)
                                    .add(article);
                                if (context.mounted)
                                  AppSnackbar.showSuccess(
                                    context,
                                    l10n.savedToBookmarks,
                                  );
                              } catch (e) {
                                if (context.mounted)
                                  AppSnackbar.showError(
                                    context,
                                    e.toString().replaceAll('Exception: ', ''),
                                  );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_outline,
                              color: isSaved
                                  ? AppColors.accent
                                  : Colors.white.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Title ──────────────────────────────────────
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Summary ────────────────────────────────────
                    Text(
                      article.summary,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // ── Footer row ─────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Verified',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Read Article',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Format date for the digest card.
  static String _formatDigestDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    try {
      final dt = DateTime.parse(trimmed).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour < 12 ? 'AM' : 'PM';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $amPm';
    } catch (_) {
      return trimmed;
    }
  }
}
