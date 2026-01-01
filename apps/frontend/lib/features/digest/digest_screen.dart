import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class DigestScreen extends StatelessWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text('Top 3 Trusted News Today', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, i) => GlassCard(
                      child: ListTile(
                        title: Text('Trusted headline #${i + 1}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Short description...', style: const TextStyle(color: Colors.white70)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Verified', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
