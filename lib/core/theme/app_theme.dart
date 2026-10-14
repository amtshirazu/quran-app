import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Light Theme Palette Constants
  static const lightScaffold = Color(0xFFF0F2F5);

  // Dark Theme Palette Constants (from design spec)
  static const darkScaffold = Color(0xFF141A17);
  static const darkSurface = Color(0xFF1C2420);
  static const darkBorder = Color(0xFF28332E);
  static const darkCategoryTitle = Color(0xFFE5A83B); // Muted Amber accent
  static const darkTextPrimary = Color(0xFFF3F4F6);
  static const darkTextSecondary = Color(0xFF90A19D);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScaffold,
    primaryColor: AppColors.emerald600,
    colorScheme: const ColorScheme.light(
      primary: AppColors.emerald600,
      surface: Colors.white,
      onSurface: AppColors.gray900,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.emerald600,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE5E7EB),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.gray900, fontSize: 16),
      bodySmall: TextStyle(color: AppColors.gray600, fontSize: 12),
      titleLarge: TextStyle(color: AppColors.gray900, fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.gray900, fontSize: 20),
      headlineLarge: TextStyle(color: AppColors.gray900, fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkScaffold,
    primaryColor: AppColors.emerald600,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.emerald600,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      secondary: darkCategoryTitle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkScaffold,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: darkSurface,
    dividerColor: darkBorder,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: darkTextPrimary, fontSize: 16),
      bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
      titleLarge: TextStyle(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkTextPrimary, fontSize: 20),
      headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
