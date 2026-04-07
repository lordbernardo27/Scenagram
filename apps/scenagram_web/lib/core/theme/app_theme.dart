import 'package:flutter/material.dart';
import 'design_tokens.dart';

class SGTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.transparent,

      // Core colors
      colorScheme: const ColorScheme.dark(
        primary: SGColors.accentBlue,
        secondary: SGColors.accentPurple,
        surface: SGColors.cardGlass,
        error: SGColors.accentRed,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SGColors.textPrimary,
        elevation: 0,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black54,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: SGColors.cardGlass.withOpacity(0.8),
        labelStyle: const TextStyle(color: SGColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
        ),
      ),

      // Text
      textTheme: const TextTheme(
        headlineLarge: SGTextStyles.headingLarge,
        headlineMedium: SGTextStyles.headingMedium,
        bodyMedium: SGTextStyles.body,
        bodySmall: SGTextStyles.caption,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SGColors.accentBlue,
          foregroundColor: SGColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SGRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SGSpacing.lg,
            vertical: SGSpacing.md,
          ),
        ),
      ),

      // Text buttons (top nav etc.)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SGColors.textSecondary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SGColors.cardGlass.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: const BorderSide(
            color: SGColors.accentBlue,
            width: 1.2,
          ),
        ),
        hintStyle: const TextStyle(color: SGColors.textMuted),
        labelStyle: const TextStyle(color: SGColors.textSecondary),
      ),

      dividerColor: Colors.white12,
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),

      colorScheme: const ColorScheme.light(
        primary: SGColors.accentBlue,
        secondary: SGColors.accentPurple,
        surface: Colors.white,
        error: SGColors.accentRed,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black12,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF2F9),
        labelStyle: const TextStyle(color: Color(0xFF111827)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF374151),
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SGColors.accentBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SGRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SGSpacing.lg,
            vertical: SGSpacing.md,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEFF2F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
          borderSide: const BorderSide(
            color: SGColors.accentBlue,
            width: 1.2,
          ),
        ),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        labelStyle: const TextStyle(color: Color(0xFF374151)),
      ),

      dividerColor: Colors.black12,
    );
  }
}