import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

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
            child: ListView(
              children: const [
                GlassCard(child: ListTile(title: Text('Saved article 1', style: TextStyle(color: Colors.white)), subtitle: Text('AI summary...', style: TextStyle(color: Colors.white70)))),
                SizedBox(height: 12),
                GlassCard(child: ListTile(title: Text('Saved article 2', style: TextStyle(color: Colors.white)), subtitle: Text('AI summary...', style: TextStyle(color: Colors.white70)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
