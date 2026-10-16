import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF4A3BC0);
  static const primaryDark = Color(0xFF3B2DA3);
  static const card = Color(0xFF5250D6);
  static const accent = Color(0xFF1EC0F5);
  static const navy = Color(0xFF0F1E5C);
  static const bg = Color(0xFFDCE8F5);
  static const bgLight = Color(0xFFEAF1FA);
  static const grey = Color(0xFFB8C4D6);
  static const white = Colors.white;
}

class AppTheme {
  static ThemeData get light {
    final base = GoogleFonts.urbanistTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      textTheme: base.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}