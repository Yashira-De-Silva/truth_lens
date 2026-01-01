import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DigestScreen extends StatelessWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily AI Digest'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('Top 3 Trusted News Today', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    title: Text('Trusted headline #${i + 1}'),
                    subtitle: Text('Short description...'),
                    trailing: AppTheme.statusBadge('Verified', AppColors.success),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
