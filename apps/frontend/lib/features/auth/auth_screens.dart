import 'package:flutter/material.dart';
import '../../core/widgets/glass_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)]),
        ),
        child: SafeArea(
          child: Center(
            child: GlassCard(
              padding: const EdgeInsets.all(18),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF07243A), Color(0xFF0B4F6A)]),
        ),
        child: SafeArea(
          child: Center(
            child: GlassCard(
              padding: const EdgeInsets.all(18),
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
