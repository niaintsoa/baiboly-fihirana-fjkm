import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color surfaceColor,
    required Color onSurfaceColor,
    required Color containerColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        primaryContainer: containerColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: onSurfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.inter(fontSize: 15.0, fontWeight: FontWeight.bold, color: onSurfaceColor),
        titleMedium: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w600, color: onSurfaceColor),
        bodyLarge: GoogleFonts.inter(fontSize: 13.0, height: 1.3, color: onSurfaceColor),
        bodyMedium: GoogleFonts.inter(fontSize: 11.0, color: onSurfaceColor.withOpacity(0.7)),
      ),
    );
  }

  static ThemeData getTheme(String mode, Color seedColor) {
    if (mode == 'dark') {
      return buildTheme(
        brightness: Brightness.dark,
        primaryColor: seedColor == const Color(0xFF8B2635) ? const Color(0xFFE5A93C) : seedColor,
        surfaceColor: const Color(0xFF141416),
        onSurfaceColor: const Color(0xFFE3E3E6),
        containerColor: const Color(0xFF222225),
      );
    } else if (mode == 'sepia') {
      return buildTheme(
        brightness: Brightness.light,
        primaryColor: seedColor == const Color(0xFF8B2635) ? const Color(0xFF7A431D) : seedColor,
        surfaceColor: const Color(0xFFF4ECD8),
        onSurfaceColor: const Color(0xFF3E2723),
        containerColor: const Color(0xFFE8DCBF),
      );
    } else {
      return buildTheme(
        brightness: Brightness.light,
        primaryColor: seedColor,
        surfaceColor: const Color(0xFFFDFBF7),
        onSurfaceColor: const Color(0xFF2C2520),
        containerColor: const Color(0xFFF1E9DB),
      );
    }
  }
}
