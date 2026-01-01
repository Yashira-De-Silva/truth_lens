import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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
      appBar: AppBar(title: const Text('Profile & Settings'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('User Name'), subtitle: const Text('user@example.com')),
            const SizedBox(height: 12),
            SwitchListTile(title: const Text('Dark Theme'), value: dark, onChanged: (v) => setState(() => dark = v)),
            SwitchListTile(title: const Text('Notifications'), value: notifications, onChanged: (v) => setState(() => notifications = v)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Manage Preferred Categories'))
          ],
        ),
      ),
    );
  }
}
