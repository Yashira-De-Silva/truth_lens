import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'article_model.dart';
import 'bookmarks_provider.dart';
import '../article/article_details_screen.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  // Mock news articles with realistic data
  static final List<Article> _mockArticles = [
    Article(
      id: 1,
      title: 'Breaking: AI Revolutionizes News Verification',
      summary: 'New AI technology can detect fake news with 98% accuracy using advanced machine learning algorithms.',
      source: 'Tech News',
    ),
    Article(
      id: 2,
      title: 'Political Summit Addresses Climate Change',
      summary: 'World leaders gather to discuss climate action and sustainable development goals for 2026.',
      source: 'World Politics',
    ),
    Article(
      id: 3,
      title: 'Stock Market Reaches New Heights',
      summary: 'Technology stocks lead market gains as investors show confidence in AI sector growth.',
      source: 'Business Today',
    ),
    Article(
      id: 4,
      title: 'Medical Breakthrough in Cancer Treatment',
      summary: 'Scientists develop new immunotherapy that shows promising results in clinical trials.',
      source: 'Health News',
    ),
    Article(
      id: 5,
      title: 'SpaceX Announces Mars Mission Timeline',
      summary: 'Elon Musk reveals updated plans for the first crewed mission to Mars in 2028.',
      source: 'Space Journal',
    ),
    Article(
      id: 6,
      title: 'Olympics 2026 Preparations Underway',
      summary: 'Host city unveils state-of-the-art facilities for upcoming Olympic Games.',
      source: 'Sports World',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // gradient background to match design
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'News',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stay informed with verified news',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _mockArticles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final article = _mockArticles[index];
                    final status = index % 3; // 0 verified, 1 biased, 2 fake
                    final statusColor = status == 0 ? AppColors.success : (status == 1 ? AppColors.accent : AppColors.error);
                    final statusText = status == 0 ? 'Verified' : (status == 1 ? 'Biased' : 'Possibly Fake');
                    final confidence = status == 0 ? 0.98 : (status == 1 ? 0.66 : 0.2);

                    return _GlassCard(
                      statusColor: statusColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'AI Summary',
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              ' · ${article.source} - 2h ago',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _ConfidenceBadge(
                                      text: statusText,
                                      color: statusColor,
                                      percent: (confidence * 100).toInt(),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.more_horiz,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Consumer(builder: (context, ref, _) {
                                  final bookmarks = ref.watch(bookmarksProvider);
                                  final isSaved = bookmarks.any((a) => a.id == article.id);
                                  
                                  return Flexible(
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (isSaved) {
                                          await ref.read(bookmarksProvider.notifier).removeById(article.id);
                                          if (context.mounted) {
                                            AppSnackbar.showSuccess(context, 'Removed from bookmarks');
                                          }
                                        } else {
                                          await ref.read(bookmarksProvider.notifier).add(article);
                                          if (context.mounted) {
                                            AppSnackbar.showSuccess(context, 'Saved to bookmarks');
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSaved
                                              ? AppColors.accent.withValues(alpha: 0.2)
                                              : Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSaved
                                                ? AppColors.accent.withValues(alpha: 0.5)
                                                : Colors.white.withValues(alpha: 0.2),
                                            width: isSaved ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                                color: isSaved
                                                    ? AppColors.accent
                                                    : Colors.white.withValues(alpha: 0.9),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isSaved ? 'Saved' : 'Save',
                                                style: TextStyle(
                                                  color: isSaved
                                                      ? AppColors.accent
                                                      : Colors.white.withValues(alpha: 0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ArticleDetailsScreen(article: article),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondary.withValues(alpha: 0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Read',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color statusColor;
  const _GlassCard({required this.child, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String text;
  final Color color;
  final int percent;
  const _ConfidenceBadge({required this.text, required this.color, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
