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

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => i);

    return Scaffold(
      // gradient background to match design
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07243A), Color(0xFF0B4F6A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('News', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final status = index % 3; // 0 verified, 1 biased, 2 fake
                    final statusColor = status == 0 ? AppColors.success : (status == 1 ? AppColors.accent : AppColors.error);
                    final statusText = status == 0 ? 'Verified' : (status == 1 ? 'Biased' : 'Possibly Fake');
                    final confidence = status == 0 ? 0.98 : (status == 1 ? 0.66 : 0.2);

                    return _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // thumbnail
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/placeholder.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Sample headline #$index', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                                      const SizedBox(height: 6),
                                      Text('AI Summary · BBC News - 1hr ago', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _ConfidenceBadge(text: statusText, color: statusColor, percent: (confidence * 100).toInt()),
                                    const SizedBox(height: 8),
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.white70)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('This article analyzes the main points and presents an AI-generated summary to help you decide quickly whether to read the full piece or save it for later.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70), maxLines: 3, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Consumer(builder: (context, ref, _) {
                                  return TextButton(onPressed: () async {
                                    final article = Article(id: index, title: 'Sample headline #$index', summary: 'This article analyzes the main points...', source: 'BBC News');
                                    await ref.read(bookmarksProvider.notifier).add(article);
                                    // Use AppSnackbar for consistent glass-style toasts
                                    AppSnackbar.showSuccess(context, 'Saved');
                                  }, style: TextButton.styleFrom(foregroundColor: Colors.white70), child: const Text('Save'));
                                }),
                                const SizedBox(width: 8),
                                ElevatedButton(onPressed: () {
                                  // navigate to article
                                  final article = Article(id: index, title: 'Sample headline #$index', summary: 'This article analyzes the main points...', source: 'BBC News');
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)));
                                }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white), child: const Text('Read')),
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
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 6))],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Text('$percent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
          )
        ],
      ),
    );
  }
}
