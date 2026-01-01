import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: const [
            Card(child: ListTile(title: Text('Saved article 1'), subtitle: Text('AI summary...'))),
            Card(child: ListTile(title: Text('Saved article 2'), subtitle: Text('AI summary...'))),
          ],
        ),
      ),
    );
  }
}
