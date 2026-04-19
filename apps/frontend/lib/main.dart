import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/profile/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-warm SharedPreferences so the first disk read is cached.
  await SharedPreferences.getInstance();
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
    final languageCode = ref.watch(settingsProvider).language;
    
    return MaterialApp(
      title: 'TruthLens', 
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, 
      themeMode: _themeMode,
      locale: Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
