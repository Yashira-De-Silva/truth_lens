import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';

class ReadingHistoryScreen extends ConsumerStatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  ConsumerState<ReadingHistoryScreen> createState() =>
      _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends ConsumerState<ReadingHistoryScreen> {
  // Mock reading history data - now as instance variable
  List<_HistoryItem> historyItems = [
    _HistoryItem(
      title: 'AI Revolutionizes News Verification',
      source: 'Tech News',
      readTime: '2h ago',
      category: 'Technology',
    ),
    _HistoryItem(
      title: 'Political Summit Addresses Climate Change',
      source: 'World Politics',
      readTime: '5h ago',
      category: 'Politics',
    ),
    _HistoryItem(
      title: 'Stock Market Reaches New Heights',
      source: 'Business Today',
      readTime: '1d ago',
      category: 'Business',
    ),
    _HistoryItem(
      title: 'Medical Breakthrough in Cancer Treatment',
      source: 'Health News',
      readTime: '2d ago',
      category: 'Health',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.readingHistory,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showClearDataDialog(context, l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.clearData,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  l10n.manageHistory,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // History List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: historyItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return _buildHistoryCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearDataDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: Text(
          l10n.clearData,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.removeCachedData,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_articles');
      await prefs.remove('reading_history');
      
      // Clear the history items from the UI
      setState(() {
        historyItems.clear();
      });
      
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Data cleared successfully');
      }
    }
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.readTime,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.source,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String title;
  final String source;
  final String readTime;
  final String category;

  _HistoryItem({
    required this.title,
    required this.source,
    required this.readTime,
    required this.category,
  });
}
