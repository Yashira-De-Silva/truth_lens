import 'package:flutter/material.dart';

// Centralized theme for TruthLens
class AppColors {
  static const primary = Color(0xFF0A2540); // Deep Trust Blue
  static const secondary = Color(0xFF38BDF8); // AI Cyan
  static const accent = Color(0xFFF59E0B); // Warning Amber
  static const success = Color(0xFF22C55E); // Verified News
  static const error = Color(0xFFEF4444); // Fake News Alert
  static const lightBg = Color(0xFFF8FAFC);
  static const darkBg = Color(0xFF020617);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      background: AppColors.lightBg,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      shadow: Colors.black54,
      outline: Colors.grey,
      inverseSurface: AppColors.primary,
      inversePrimary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
  cardTheme: const CardThemeData(), // detailed card styling applied via Card widgets
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.secondary,
      secondarySelectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      background: AppColors.darkBg,
      onBackground: Colors.white,
      surface: Color(0xFF0B1220),
      onSurface: Colors.white,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      shadow: Colors.black87,
      outline: Colors.grey,
      inverseSurface: AppColors.primary,
      inversePrimary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
  cardTheme: const CardThemeData(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF0B1220),
      selectedColor: AppColors.secondary,
      secondarySelectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Small helper for badges
  static Widget statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
