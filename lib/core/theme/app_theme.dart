import 'package:flutter/material.dart';
import 'design_tokens.dart';

class SGTheme {
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
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SGRadius.lg),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFEFF2F9),
        labelStyle: TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SGRadius.md),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Color(0xFF111827),
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: Color(0xFF374151),
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: Color(0xFF6B7280),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SGColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEFF2F9),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        labelStyle: const TextStyle(color: Color(0xFF374151)),
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
      ),

      dividerColor: Colors.black12,
    );
  }
}
