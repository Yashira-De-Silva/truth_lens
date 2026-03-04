import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../news/article_model.dart';
import '../article/article_details_screen.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final _digestServiceProvider = Provider<NewsApiService>(
  (ref) => NewsApiService(),
);

final digestProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final svc = ref.watch(_digestServiceProvider);
  return svc.fetchDigest(limit: 3);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDigest = ref.watch(digestProvider);

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
                padding: const EdgeInsets.all(16.0),
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
                              Text(
                                l10n.todayDigest,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Refresh button
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
                    const SizedBox(height: 16),
                    asyncDigest.when(
                      data: (articles) => _buildStatsRow(articles.length),
                      loading: () => _buildStatsRow(0),
                      error: (_, __) => _buildStatsRow(0),
                    ),
                  ],
                ),
              ),

              // ── Articles ─────────────────────────────────────────
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
                        Text(
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
                          itemBuilder: (context, index) {
                            return _buildDigestCard(
                              context,
                              articles[index],
                              index + 1,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int articleCount) {
    final count = articleCount == 0 ? '—' : '$articleCount';
    return Row(
      children: [
        _buildStatChip(Icons.article, count, 'Articles'),
        const SizedBox(width: 8),
        _buildStatChip(Icons.verified_user, '100%', 'Verified'),
        const SizedBox(width: 8),
        _buildStatChip(Icons.trending_up, 'ML', 'Accuracy'),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
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
            Icon(icon, color: AppColors.secondary, size: 20),
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

  Widget _buildDigestCard(BuildContext context, Article article, int rank) {
    final confidencePct = (article.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailsScreen(article: article),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Rank Badge
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
                                fontSize: 16,
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
                                      'Verified • $confidencePct%',
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
                              Text(
                                article.source,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.bookmark_outline,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    Text(
                      article.summary,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
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
}
