import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../news/bookmarks_provider.dart';

// ...existing code...

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Consumer(builder: (context, ref, _) {
              final list = ref.watch(bookmarksProvider);
              if (list.isEmpty) return const Center(child: Text('No bookmarks', style: TextStyle(color: Colors.white70)));
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => GlassCard(
                  child: ListTile(
                    title: Text(list[i].title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(list[i].summary, style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.white70), onPressed: () async {
                      await ref.read(bookmarksProvider.notifier).removeById(list[i].id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed')));
                    }),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
