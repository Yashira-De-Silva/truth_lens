import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dark = false;
  bool notifications = true;

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
                GlassCard(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('User Name', style: TextStyle(color: Colors.white)), subtitle: const Text('user@example.com', style: TextStyle(color: Colors.white70)))),
                const SizedBox(height: 12),
                GlassCard(child: SwitchListTile(title: const Text('Dark Theme', style: TextStyle(color: Colors.white)), value: dark, onChanged: (v) => setState(() => dark = v))),
                const SizedBox(height: 8),
                GlassCard(child: SwitchListTile(title: const Text('Notifications', style: TextStyle(color: Colors.white)), value: notifications, onChanged: (v) => setState(() => notifications = v))),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () {}, child: const Text('Manage Preferred Categories'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
