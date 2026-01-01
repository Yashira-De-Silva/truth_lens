import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ArticleDetailsScreen extends StatefulWidget {
  const ArticleDetailsScreen({super.key});

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  bool showSummary = true;
  double fakeProbability = 0.18; // mock

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Sample headline', style: Theme.of(context).textTheme.headlineMedium)),
                AppTheme.statusBadge(fakeProbability < 0.3 ? 'Verified' : (fakeProbability < 0.7 ? 'Biased' : 'Possibly Fake'),
                    fakeProbability < 0.3 ? AppColors.success : (fakeProbability < 0.7 ? AppColors.accent : AppColors.error)),
              ],
            ),
            const SizedBox(height: 12),
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [showSummary, !showSummary],
              onPressed: (i) => setState(() => showSummary = i == 0),
              children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('AI Summary')), Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Full Article'))],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: 1 - fakeProbability, color: fakeProbability < 0.3 ? AppColors.success : (fakeProbability < 0.7 ? AppColors.accent : AppColors.error)),
            const SizedBox(height: 8),
            Text('Misinformation Confidence: ${(fakeProbability * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(showSummary ? 'AI generated 3-4 line summary...' : 'Full article content... (mock).', style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 8),
            Text('Related trusted sources', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              Chip(label: Text('Trusted Source A')),
              Chip(label: Text('Trusted Source B')),
              Chip(label: Text('Trusted Source C')),
            ])
          ],
        ),
      ),
    );
  }
}
