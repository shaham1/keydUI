import 'package:flutter/material.dart';

/// Centralized modern design palette for keydUI (Modern Obsidian & Electric Indigo aesthetic).
class Palette {
  // Primary Modern Accents (Electric Indigo & Cyber Cyan)
  static const Color accentPrimary = Color(0xFF6366F1); // Modern Electric Indigo
  static const Color accentBright = Color(0xFF818CF8);  // Bright Indigo / Lavender
  static const Color accentCyan = Color(0xFF38BDF8);    // Vivid Cyber Sky/Cyan
  static const Color accentTeal = Color(0xFF2DD4BF);    // Modern Teal
  static const Color accentEmerald = Color(0xFF10B981); // Crisp Success Green
  static const Color accentAmber = Color(0xFFF59E0B);   // Warning / Alert Amber
  static const Color accentRose = Color(0xFFF43F5E);    // Modern Vibrant Rose/Red

  // Backward-compatible alias tokens
  static const Color wootingYellow = accentPrimary;
  static const Color wootingYellowBright = accentBright;
  static const Color wootingAmber = accentAmber;
  static const Color wootingCyan = accentCyan;
  static const Color wootingRed = accentRose;
  static const Color wootingGreen = accentEmerald;

  // Modern Obsidian Surface Hierarchy
  static const Color backgroundColor = Color(0xFF090A0F); // Deep space obsidian
  static const Color surfaceDim = Color(0xFF0F1017);       // Base tray / keyboard bed
  static const Color cardColor = Color(0xFF151722);         // Elevated card / deck
  static const Color surfaceColor = Color(0xFF1B1E2E);      // Active interactive surfaces
  static const Color surfaceContainerHigh = Color(0xFF23273A);
  static const Color surfaceContainerHighest = Color(0xFF2C3149);

  // Keycap Surfaces & Illumination
  static const Color keycapColor = Color(0xFF1C1F2E);
  static const Color keycapHoverColor = Color(0xFF272B40);
  static const Color keycapSelectedColor = Color(0xFF2B284A);
  static const Color keycapSelectedBorder = accentBright;
  static const Color keycapRemappedBadge = Color(0xFF262A4A);
  static const Color keycapRemappedText = Color(0xFFA5B4FC);

  // High WCAG Contrast Typography Tokens
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0F172A);

  // Legacy Aliases
  static const Color whiteColor = textPrimary;
  static const Color greyColor = textSecondary;
  static const Color subtitleText = textSecondary;
  static const Color inactiveBottomBarItemColor = textMuted;
  static const Color inactiveSeekColor = Colors.white24;
  static const Color greenColor = accentEmerald;
  static const Color errorColor = accentRose;
  static const Color transparentColor = Colors.transparent;
  static const Color gradient1 = Color(0xFF6366F1);
  static const Color gradient2 = Color(0xFF8B5CF6);
  static const Color gradient3 = Color(0xFFEC4899);

  // Crisp Modern Borders
  static const Color borderMuted = Color(0xFF25293C);
  static const Color borderColor = Color(0xFF323750);
  static const Color activeBorderColor = accentBright;
  static Color borderCrisp = Colors.white.withValues(alpha: 0.08);

  // Metrics & Spacing Tokens
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double minTouchTarget = 48.0;
}
