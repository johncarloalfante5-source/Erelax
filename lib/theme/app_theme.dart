// THEME LOCK: dark — source: domain signal (wellness premium) + reference image
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';

import '../core/app_fonts.dart';

export '../core/app_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFFF5C518);
  static const Color primaryContainer = Color(0xFF3D3000);
  static const Color secondary = Color(0xFF2C2C2E);
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color errorColor = Color(0xFFFF453A);

  // Dark surfaces
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2E);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color mutedText = Color(0xFF8A8A8E);
  static const Color onSurfaceDark = Color(0xFFE8E8E8);

  // Light surfaces (required by system)
  static const Color surfaceLight = Color(0xFFF8F5F0);
  static const Color backgroundLight = Color(0xFFF2EDE8);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.black,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surfaceLight,
      onSurface: const Color(0xFF1A1A1A),
      error: errorColor,
      onError: Colors.white,
      outline: const Color(0xFFCCCCCC),
      outlineVariant: const Color(0xFFEEEEEE),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarThemeData(
      backgroundColor: surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      foregroundColor: Color(0xFF1A1A1A),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.black,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      error: errorColor,
      onError: Colors.white,
      outline: Color(0xFF48484A),
      outlineVariant: Color(0xFF3A3A3C),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.dmSansTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: onSurfaceDark, displayColor: onSurfaceDark),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: onSurfaceDark,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF48484A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF48484A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: mutedText),
      hintStyle: const TextStyle(color: mutedText),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
