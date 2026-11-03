import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color, [double width = 1.0]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
        borderRadius: BorderRadius.circular(Palette.radiusMedium),
      );

  static final ThemeData darkThemeMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.backgroundColor,
    cardColor: Palette.cardColor,
    colorScheme: const ColorScheme.dark(
      primary: Palette.accentPrimary,
      onPrimary: Colors.white,
      secondary: Palette.accentCyan,
      onSecondary: Colors.black,
      surface: Palette.cardColor,
      onSurface: Palette.textPrimary,
      error: Palette.accentRose,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Palette.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Palette.radiusLarge),
        side: const BorderSide(color: Palette.borderColor, width: 1.0),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Palette.textPrimary,
        letterSpacing: -0.6,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Palette.textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Palette.textPrimary,
        height: 1.35,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Palette.textPrimary,
        letterSpacing: 0.15,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Palette.textPrimary,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Palette.textSecondary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: Palette.textPrimary,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Palette.textSecondary,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Palette.textMuted,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Palette.textPrimary,
        letterSpacing: 0.4,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Palette.textSecondary,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Palette.textMuted,
        letterSpacing: 0.6,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: _border(Palette.borderColor),
      focusedBorder: _border(Palette.accentBright, 1.5),
      errorBorder: _border(Palette.accentRose),
      focusedErrorBorder: _border(Palette.accentRose, 1.5),
      hintStyle: const TextStyle(
        color: Palette.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Palette.textSecondary,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Palette.accentPrimary.withValues(alpha: 0.4),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Palette.radiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(88, Palette.minTouchTarget),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.textSecondary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        minimumSize: const Size(48, Palette.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Palette.radiusSmall),
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Palette.accentBright,
      unselectedLabelColor: Palette.textSecondary,
      indicatorColor: Palette.accentBright,
      labelStyle: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      dividerColor: Palette.borderMuted,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Palette.cardColor,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Palette.radiusLarge),
        side: const BorderSide(color: Palette.borderColor, width: 1.0),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Palette.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14.5,
        color: Palette.textSecondary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.cardColor,
      contentTextStyle: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: Palette.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Palette.radiusMedium),
        side: const BorderSide(color: Palette.borderColor, width: 1.0),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),
  );
}
