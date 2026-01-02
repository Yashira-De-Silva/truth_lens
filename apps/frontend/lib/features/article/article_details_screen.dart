import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/back_button_widget.dart';
import '../news/article_model.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final Article? article;
  const ArticleDetailsScreen({this.article, super.key});

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  bool showSummary = true;
  double fakeProbability = 0.18; // mock

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BackButtonWidget(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.article?.title ?? 'Sample headline',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, height: 1.05),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: fakeProbability < 0.3 ? AppColors.success : (fakeProbability < 0.7 ? AppColors.accent : AppColors.error), borderRadius: BorderRadius.circular(12)),
                        child: Text(fakeProbability < 0.3 ? 'Verified' : (fakeProbability < 0.7 ? 'Biased' : 'Possibly Fake'), style: const TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    isSelected: [showSummary, !showSummary],
                    onPressed: (i) => setState(() => showSummary = i == 0),
                    selectedColor: Colors.white,
                    fillColor: Colors.white12,
                    color: Colors.white70,
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    constraints: const BoxConstraints(minHeight: 42, minWidth: 120),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('AI Summary')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Full Article')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: 1 - fakeProbability, color: fakeProbability < 0.3 ? AppColors.success : (fakeProbability < 0.7 ? AppColors.accent : AppColors.error)),
                  const SizedBox(height: 8),
                  Text('Misinformation Confidence: ${(fakeProbability * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.4)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(showSummary ? 'AI generated 3-4 line summary...' : 'Full article content... (mock).', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.6)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Related trusted sources', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: const [
                    Chip(label: Text('Trusted Source A')),
                    Chip(label: Text('Trusted Source B')),
                    Chip(label: Text('Trusted Source C')),
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
