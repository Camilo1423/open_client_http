import 'package:flutter/material.dart';

enum ThemeModePreference { light, dark, system }

// ===================
// APP COLOR PALETTE
// ===================

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF7C3AED); // Violet 600
  static const Color primaryLight = Color(0xFF8B5CF6); // Violet 500
  static const Color primaryDark = Color(0xFF6D28D9); // Violet 700

  // Secondary Colors
  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color accent = Color(0xFF10B981); // Emerald 500

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF8B5CF6); // Violet 500

  // Neutral Colors (for both themes)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF334155); // Slate 700
  static const Color textDisabled = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Color(0xFFFFFFFF); // White
  static const Color textBlack = Color(0xFF000000); // Black
  static const Color textTransparent = Colors.transparent; // Transparent
}

// ===================
// LIGHT THEME COLORS
// ===================

class AppLightColors {
  // Surfaces
  static const Color background = Color(0xFFFAFAFA); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100

  // Text
  static const Color onBackground = Color(0xFF0F172A); // Slate 900
  static const Color onSurface = Color(0xFF334155); // Slate 700
  static const Color onSurfaceVariant = Color(0xFF64748B); // Slate 500
  static const Color disabled = Color(0xFF94A3B8); // Slate 400

  // Borders & Dividers
  static const Color outline = Color(0xFFE2E8F0); // Slate 200
  static const Color outlineVariant = Color(0xFFF1F5F9); // Slate 100

  // Input Fields
  static const Color inputFill = Color(0xFFFFFFFF); // White
  static const Color inputBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color inputFocused = AppColors.primary;
}

// ===================
// DARK THEME COLORS
// ===================

class AppDarkColors {
  // Surfaces
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceVariant = Color(0xFF334155); // Slate 700

  // Text
  static const Color onBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color onSurface = Color(0xFFE2E8F0); // Slate 200
  static const Color onSurfaceVariant = Color(0xFF94A3B8); // Slate 400
  static const Color disabled = Color(0xFF64748B); // Slate 500

  // Borders & Dividers
  static const Color outline = Color(0xFF475569); // Slate 600
  static const Color outlineVariant = Color(0xFF334155); // Slate 700

  // Input Fields
  static const Color inputFill = Color(0xFF1E293B); // Slate 700
  static const Color inputBorder = Color(0xFF475569); // Slate 600
  static const Color inputFocused = AppColors.primaryLight;
}

// ===================
// THEME CONFIGURATIONS
// ===================

class AppTheme {
  final bool isDarkMode;
  static const String fontFamily = 'Inter';

  AppTheme({required this.isDarkMode});

  ThemeData get theme => isDarkMode ? darkTheme : lightTheme;

  // Light Theme
  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      tertiary: AppColors.accent,
      onTertiary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppLightColors.surface,
      onSurface: AppLightColors.onSurface,
      background: AppLightColors.background,
      onBackground: AppLightColors.onBackground,
      outline: AppLightColors.outline,
      outlineVariant: AppLightColors.outlineVariant,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppLightColors.surface,
      foregroundColor: AppLightColors.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppLightColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppLightColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppLightColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppLightColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppLightColors.inputFocused,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppLightColors.surface,
      elevation: 1,
      shadowColor: AppColors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.textWhite,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );

  // Dark Theme
  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.black,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      tertiary: AppColors.accent,
      onTertiary: AppColors.black,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppDarkColors.surface,
      onSurface: AppDarkColors.onSurface,
      background: AppDarkColors.background,
      onBackground: AppDarkColors.onBackground,
      outline: AppDarkColors.outline,
      outlineVariant: AppDarkColors.outlineVariant,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.surface,
      foregroundColor: AppDarkColors.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppDarkColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDarkColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppDarkColors.inputFocused,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppDarkColors.surface,
      elevation: 1,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.textWhite,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
