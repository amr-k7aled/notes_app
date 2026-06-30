import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color background = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceCard = Color(0xFF22222F);
  static const Color accent = Color(0xFF7C6FFF);
  static const Color accentLight = Color(0xFFB8B0FF);
  static const Color textPrimary = Color(0xFFF0EFF8);
  static const Color textSecondary = Color(0xFF8887A0);
  static const Color divider = Color(0xFF2E2E40);
  static const Color success = Color(0xFF4ECBA3);
  static const Color danger = Color(0xFFFF6B6B);

  // Note card palette
  static const List<Color> noteColors = [
    Color(0xFF22222F), // default dark
    Color(0xFF1E2A3A), // deep blue
    Color(0xFF2A1E3A), // deep purple
    Color(0xFF1E3A2A), // deep green
    Color(0xFF3A2A1E), // deep amber
    Color(0xFF3A1E2A), // deep rose
  ];

  static const List<Color> noteAccents = [
    Color(0xFF7C6FFF),
    Color(0xFF5B9EFF),
    Color(0xFFB06FFF),
    Color(0xFF4ECBA3),
    Color(0xFFFFB06F),
    Color(0xFFFF6FB0),
  ];
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
