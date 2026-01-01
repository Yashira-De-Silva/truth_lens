import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_providers.dart';
// uses theme via surrounding app

class NewsListWidget extends ConsumerWidget {
  const NewsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNews = ref.watch(latestNewsProvider);
    return asyncNews.when(
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(items[i]['title']),
            subtitle: Text(items[i]['source'] ?? 'Source'),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
