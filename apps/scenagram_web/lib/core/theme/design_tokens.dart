import 'package:flutter/material.dart';

class SGColors {
  // Base Backgrounds
  static const Color backgroundPrimary = Color(0xFF0B0F1A);
  static const Color backgroundSecondary = Color(0xFF111827);
  static const Color cardGlass = Color(0xFF151C2E);

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF7A18);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B9C9);
  static const Color textMuted = Color(0xFF6B7280);

  // Heat Indicator
  static const Color heatLow = Color(0xFF3B82F6);
  static const Color heatMedium = Color(0xFFFF7A18);
  static const Color heatHigh = Color(0xFFEF4444);
}

class SGSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class SGRadius {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class SGGlow {
  static List<BoxShadow> glow(Color color, {double intensity = 0.6}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 20,
        spreadRadius: 1,
      ),
    ];
  }
}

class SGTextStyles {
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: SGColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: SGColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: SGColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: SGColors.textMuted,
  );
}