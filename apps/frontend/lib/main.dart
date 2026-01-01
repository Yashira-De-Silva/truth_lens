import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: TruthLensApp()));
}

class TruthLensApp extends ConsumerStatefulWidget {
  const TruthLensApp({super.key});

  @override
  ConsumerState<TruthLensApp> createState() => _TruthLensAppState();
}

class _TruthLensAppState extends ConsumerState<TruthLensApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruthLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
