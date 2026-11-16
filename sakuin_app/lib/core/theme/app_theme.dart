import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const indigo = Color(0xFF4F46E5);
  static const lightIndigo = Color(0xFFEEF2FF);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const crimson = Color(0xFFEF4444);
  static const background = Color(0xFFF8FAFC);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      primary: AppColors.indigo,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );
}
