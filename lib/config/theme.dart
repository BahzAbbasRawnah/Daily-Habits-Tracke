import 'package:flutter/material.dart';

/// Theme configuration for the Daily Habit Tracker application
class AppTheme {
  // Primary color: Habit Tracker theme
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLightColor = Color(0xFFA5B4FC); // Light indigo
  static const Color primaryDarkColor = Color(0xFF4338CA); // Dark indigo

    // Secondary Colors
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color secondaryGrey = Color(0xFF4A4A4A);
  static const Color secondaryLightGrey = Color(0xFFE0E0E0);

  // Accent color: Deep red (#B22222) - For important actions and alerts
  static const Color accentColor = Color(0xFFB22222); // Firebrick red
  static const Color accentLightColor = Color(0xFFE57373); // Light red
  static const Color accentDarkColor = Color(0xFF800000); // Maroon

  // Neutral colors
  static const Color textDarkColor = Color(0xFF212121);
  static const Color textLightColor = Color(0xFFF5F5F5);
  static const Color backgroundLightColor = Color(0xFFF9F9F9);
  static const Color backgroundDarkColor = Color(0xFF121212);
  static const Color surfaceLightColor = Color(0xFFFFFFFF);
  static const Color surfaceDarkColor = Color(0xFF1E1E1E);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Habit tracker specific colors
  static const Color habitCompletedColor = Color(0xFF10B981); // Green for completed
  static const Color habitMissedColor = Color(0xFFEF4444); // Red for missed
  static const Color habitPartialColor = Color(0xFFF59E0B); // Amber for partial
  static const Color streakColor = Color(0xFF8B5CF6); // Purple for streaks

  // Card gradients
  static const LinearGradient primaryGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6366F1), // Indigo
          Color(0xFF8B5CF6), // Purple
        ],
      );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald
      Color(0xFF059669), // Dark emerald
    ],
  );

  static const LinearGradient streakGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6), // Purple
      Color(0xFF7C3AED), // Dark purple
    ],
  );

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryBlack,
      surface: surfaceLightColor,
      surfaceContainer: backgroundLightColor,
      error: errorColor,
      onPrimary: textDarkColor,
      onSecondary: textLightColor,
      onSurface: textDarkColor,
      onError: textLightColor,
    ),
    scaffoldBackgroundColor: backgroundLightColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textDarkColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceLightColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLightColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLightColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryLightGrey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: secondaryLightGrey,
            width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    fontFamily: 'Cairo',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: textDarkColor),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: textDarkColor),
      displaySmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: textDarkColor),
      headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: textDarkColor),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDarkColor),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDarkColor),
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textDarkColor),
      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textDarkColor),
      titleSmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: textDarkColor),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: textDarkColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: textDarkColor),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: textDarkColor),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceDarkColor,
      surfaceContainer: backgroundDarkColor,
      error: errorColor,
      onPrimary: textDarkColor,
      onSecondary: textLightColor,
      onSurface: textLightColor,
      onError: textLightColor,
    ),
    scaffoldBackgroundColor: backgroundDarkColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDarkColor,
      foregroundColor: textLightColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceDarkColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDarkColor,
        foregroundColor: textDarkColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDarkColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: primaryColor.withAlpha(128), // 0.5 opacity (128/255)
            width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    fontFamily: 'Cairo',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: textLightColor),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: textLightColor),
      displaySmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: textLightColor),
      headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: textLightColor),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: textLightColor),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textLightColor),
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textLightColor),
      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textLightColor),
      titleSmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: textLightColor),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: textLightColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: textLightColor),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: textLightColor),
    ),
  );
}
