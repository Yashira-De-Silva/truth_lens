import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'article_model.dart';
import 'bookmarks_provider.dart';
import '../article/article_details_screen.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  // Get translated mock news articles
  List<Article> _getTranslatedArticles(AppLocalizations l10n) {
    return [
      Article(
        id: 1,
        title: l10n.article1Title,
        summary: l10n.article1Summary,
        source: l10n.article1Source,
      ),
      Article(
        id: 2,
        title: l10n.article2Title,
        summary: l10n.article2Summary,
        source: l10n.article2Source,
      ),
      Article(
        id: 3,
        title: l10n.article3Title,
        summary: l10n.article3Summary,
        source: l10n.article3Source,
      ),
      Article(
        id: 4,
        title: l10n.article4Title,
        summary: l10n.article4Summary,
        source: l10n.article4Source,
      ),
      Article(
        id: 5,
        title: l10n.article5Title,
        summary: l10n.article5Summary,
        source: l10n.article5Source,
      ),
      Article(
        id: 6,
        title: l10n.article6Title,
        summary: l10n.article6Summary,
        source: l10n.article6Source,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.newsFeed,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Stay informed with verified news',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
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
                  itemCount: _getTranslatedArticles(l10n).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final articles = _getTranslatedArticles(l10n);
                    final article = articles[index];
                    final status = index % 3; // 0 verified, 1 biased, 2 fake
                    final statusColor = status == 0
                        ? AppColors.success
                        : (status == 1 ? AppColors.accent : AppColors.error);
                    final statusText = status == 0
                        ? l10n.verified
                        : (status == 1 ? l10n.biased : l10n.possiblyFake);
                    final confidence = status == 0
                        ? 0.98
                        : (status == 1 ? 0.66 : 0.2);

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            l10n.aiSummary,
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
                                                color: Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
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
                                    PopupMenuButton<String>(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.more_horiz,
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          size: 18,
                                        ),
                                      ),
                                      color: const Color(0xFF0B1220),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                      offset: const Offset(-10, 40),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.share,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                l10n.shareArticle,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'report',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.flag_outlined,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                l10n.reportArticle,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'notInterested',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.block,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                l10n.notInterested,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'share':
                                            AppSnackbar.showSuccess(
                                              context,
                                              l10n.shareFeatureComingSoon,
                                            );
                                            break;
                                          case 'report':
                                            AppSnackbar.showSuccess(
                                              context,
                                              l10n.reportSubmitted,
                                            );
                                            break;
                                          case 'notInterested':
                                            AppSnackbar.showSuccess(
                                              context,
                                              l10n.articleHidden,
                                            );
                                            break;
                                        }
                                      },
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
                                Consumer(
                                  builder: (context, ref, _) {
                                    final bookmarks = ref.watch(
                                      bookmarksProvider,
                                    );
                                    final isSaved = bookmarks.any(
                                      (a) => a.id == article.id,
                                    );

                                    return Flexible(
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (isSaved) {
                                            await ref
                                                .read(
                                                  bookmarksProvider.notifier,
                                                )
                                                .removeById(article.id);
                                            if (context.mounted) {
                                              AppSnackbar.showSuccess(
                                                context,
                                                l10n.removedFromBookmarks,
                                              );
                                            }
                                          } else {
                                            await ref
                                                .read(
                                                  bookmarksProvider.notifier,
                                                )
                                                .add(article);
                                            if (context.mounted) {
                                              AppSnackbar.showSuccess(
                                                context,
                                                l10n.savedToBookmarks,
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSaved
                                                ? AppColors.accent.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : Colors.white.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSaved
                                                  ? AppColors.accent.withValues(
                                                      alpha: 0.5,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: 0.2,
                                                    ),
                                              width: isSaved ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isSaved
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_outline,
                                                  color: isSaved
                                                      ? AppColors.accent
                                                      : Colors.white.withValues(
                                                          alpha: 0.9,
                                                        ),
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    isSaved
                                                        ? l10n.unsave
                                                        : l10n.save,
                                                    style: TextStyle(
                                                      color: isSaved
                                                          ? AppColors.accent
                                                          : Colors.white
                                                                .withValues(
                                                                  alpha: 0.9,
                                                                ),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ArticleDetailsScreen(
                                            article: article,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondary.withValues(
                                              alpha: 0.8,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          l10n.read,
                                          style: const TextStyle(
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
                            ),
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
  const _ConfidenceBadge({
    required this.text,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
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
