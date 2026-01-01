import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Minimal mock UI for news feed
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthLens'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        itemBuilder: (context, index) {
          final statusColor = index % 3 == 0 ? AppColors.success : (index % 3 == 1 ? AppColors.accent : AppColors.error);
          final statusText = index % 3 == 0 ? 'Verified' : (index % 3 == 1 ? 'Biased' : 'Possibly Fake');

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Sample headline #$index', style: Theme.of(context).textTheme.titleLarge)),
                      AppTheme.statusBadge(statusText, statusColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Source · 2h ago', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('AI Summary: This article discusses important events and provides context in a concise manner. The summary aims to help users quickly grasp the main point.', style: Theme.of(context).textTheme.bodyLarge, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Read')),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: const Text('Save')),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
