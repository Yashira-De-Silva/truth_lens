import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';
import 'article_model.dart';
import 'bookmarks_provider.dart';
import '../article/article_details_screen.dart';

// ── State notifier for paginated + live news ──────────────────────────────────

enum NewsFeedMode { dataset, live }

class NewsFeedState {
  final List<Article> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int total;
  final NewsFeedMode mode;
  final String? error;

  const NewsFeedState({
    this.articles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.total = 0,
    this.mode = NewsFeedMode.dataset,
    this.error,
  });

  NewsFeedState copyWith({
    List<Article>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? total,
    NewsFeedMode? mode,
    String? error,
    bool clearError = false,
  }) => NewsFeedState(
    articles: articles ?? this.articles,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    total: total ?? this.total,
    mode: mode ?? this.mode,
    error: clearError ? null : (error ?? this.error),
  );
}

class NewsFeedNotifier extends StateNotifier<NewsFeedState> {
  final NewsApiService _svc;
  static const int _pageSize = 20;

  NewsFeedNotifier(this._svc) : super(const NewsFeedState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      articles: [],
      hasMore: true,
      clearError: true,
    );
    try {
      final response = await _svc.fetchNews(limit: _pageSize, offset: 0);
      state = state.copyWith(
        articles: response.articles,
        total: response.total,
        isLoading: false,
        hasMore: response.articles.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.mode == NewsFeedMode.live)
      return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final offset = state.articles.length;
      final response = await _svc.fetchNews(limit: _pageSize, offset: offset);
      state = state.copyWith(
        articles: [...state.articles, ...response.articles],
        total: response.total,
        isLoadingMore: false,
        hasMore: response.articles.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> switchMode(NewsFeedMode mode) async {
    if (state.mode == mode && !state.isLoading) return;
    state = state.copyWith(
      mode: mode,
      isLoading: true,
      articles: [],
      hasMore: true,
      clearError: true,
    );
    try {
      final List<Article> articles;
      int total = 0;
      if (mode == NewsFeedMode.live) {
        articles = await _svc.fetchLiveNews(limit: _pageSize);
      } else {
        final res = await _svc.fetchNews(limit: _pageSize, offset: 0);
        articles = res.articles;
        total = res.total;
      }
      state = state.copyWith(
        articles: articles,
        total: total,
        isLoading: false,
        hasMore: mode == NewsFeedMode.dataset && articles.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }


  Future<void> refresh() async {
    await switchMode(state.mode);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _newsSvcProvider = Provider<NewsApiService>((ref) => NewsApiService());

final newsFeedProvider = StateNotifierProvider<NewsFeedNotifier, NewsFeedState>(
  (ref) => NewsFeedNotifier(ref.watch(_newsSvcProvider)),
);

// ── Screen ────────────────────────────────────────────────────────────────────

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(newsFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feed = ref.watch(newsFeedProvider);
    final isLive = feed.mode == NewsFeedMode.live;

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
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
                            l10n.newsFeed,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            isLive
                                ? '🔴 Live from The Guardian'
                                : '${feed.articles.length} of ${feed.total} articles',
                            style: TextStyle(
                              color: isLive
                                  ? Colors.redAccent
                                  : Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: isLive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          ref.read(newsFeedProvider.notifier).refresh(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Mode Toggle ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _ModeToggle(
                  isLive: isLive,
                  onTap: (live) => ref
                      .read(newsFeedProvider.notifier)
                      .switchMode(
                        live ? NewsFeedMode.live : NewsFeedMode.dataset,
                      ),
                ),
              ),

              // ── Content ─────────────────────────────────────────
              Expanded(child: _buildBody(feed, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NewsFeedState feed, AppLocalizations l10n) {
    if (feed.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              feed.mode == NewsFeedMode.live
                  ? 'Loading live news…'
                  : 'Loading articles…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    if (feed.error != null && feed.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load news',
              style: const TextStyle(
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
              onTap: () => ref.read(newsFeedProvider.notifier).refresh(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.8),
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
      );
    }

    if (feed.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.newspaper,
              size: 56,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              feed.mode == NewsFeedMode.live
                  ? 'No live articles.\nAdd a Guardian API key in app.py'
                  : 'No articles found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount:
          feed.articles.length + (feed.hasMore && !feed.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feed.articles.length) {
          return feed.isLoadingMore
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ArticleCard(article: feed.articles[index]),
        );
      },
    );
  }
}

// ── Mode Toggle Widget ────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final bool isLive;
  final ValueChanged<bool> onTap;
  const _ModeToggle({required this.isLive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Dataset',
            selected: !isLive,
            onTap: () => onTap(false),
          ),
          _Tab(
            label: 'Live News',
            selected: isLive,
            onTap: () => onTap(true),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Article Card ─────────────────────────────────────────────────────────────

class _ArticleCard extends ConsumerWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final isReal = article.label == 'REAL';
    final highConf = article.confidence >= 0.75;

    Color statusColor;
    String statusText;
    if (isReal && highConf) {
      statusColor = AppColors.success;
      statusText = l10n.verified;
    } else if (!isReal && highConf) {
      statusColor = AppColors.error;
      statusText = l10n.possiblyFake;
    } else {
      statusColor = AppColors.accent;
      statusText = l10n.biased;
    }

    final confidencePct = (article.confidence * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: article.isLive
              ? Colors.redAccent.withValues(alpha: 0.4)
              : statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.isLive) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
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
                          ],
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                l10n.aiSummary,
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  ' · ${article.source}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (article.published != null &&
                              article.published!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(article.published!),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ConfidenceBadge(
                            text: statusText,
                            color: statusColor,
                            percent: confidencePct,
                          ),
                          const SizedBox(height: 8),
                          _MoreMenu(article: article),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Summary ─────────────────────────────────────
                Text(
                  article.summary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // ── Action buttons ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final bookmarks = ref.watch(bookmarksProvider);
                        final isSaved = bookmarks.any(
                          (a) => a.id == article.id,
                        );
                        return Flexible(
                          child: GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSaved
                                    ? AppColors.accent.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSaved
                                      ? AppColors.accent.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                    color: isSaved
                                        ? AppColors.accent
                                        : Colors.white.withValues(alpha: 0.8),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isSaved ? l10n.unsave : l10n.save,
                                    style: TextStyle(
                                      color: isSaved
                                          ? AppColors.accent
                                          : Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArticleDetailsScreen(article: article),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
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
                                color: AppColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            l10n.read,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
  }
}
String _formatDate(String raw) {
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
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$month ${dt.day}, ${dt.year} · $hour:$minute $amPm';
  } catch (_) {
    return trimmed;
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _MoreMenu extends StatelessWidget {
  final Article article;
  const _MoreMenu({required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white.withValues(alpha: 0.5),
          size: 16,
        ),
      ),
      color: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      offset: const Offset(-10, 40),
      itemBuilder: (context) => [
        _menuItem(Icons.share, l10n.shareArticle),
        _menuItem(Icons.flag_outlined, l10n.reportArticle),
        _menuItem(Icons.block, l10n.notInterested),
      ],
      onSelected: (v) {
        switch (v) {
          case 'share':
            AppSnackbar.showSuccess(context, l10n.shareFeatureComingSoon);
            break;
          case 'report':
            AppSnackbar.showSuccess(context, l10n.reportSubmitted);
            break;
          case 'block':
            AppSnackbar.showSuccess(context, l10n.articleHidden);
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String text) => PopupMenuItem(
    value: text,
    child: Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
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
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
