import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () {}, child: const Text('Login')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: () {}, child: const Text('Sign in with Google')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () {}, child: const Text('Register')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
