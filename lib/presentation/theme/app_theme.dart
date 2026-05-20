import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Mode Clair (Papyrus) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8B2635),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B2635),
        secondary: Color(0xFF3F5E5A),
        surface: Color(0xFFFDFBF7),
        onSurface: Color(0xFF2C2520),
        primaryContainer: Color(0xFFF1E9DB),
        onPrimaryContainer: Color(0xFF5D1E27),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDFBF7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFDFBF7),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF2C2520),
        titleTextStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color(0xFF2C2520)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C2520),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C2520),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14.0,
          height: 1.3,
          color: const Color(0xFF2C2520),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF5A5048),
        ),
      ),
    );
  }

  // --- Mode Sépia (Vieux Papier) ---
  static ThemeData get sepiaTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF7A431D),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7A431D),
        secondary: Color(0xFF4A5842),
        surface: Color(0xFFF4ECD8),
        onSurface: Color(0xFF3E2723),
        primaryContainer: Color(0xFFE8DCBF),
        onPrimaryContainer: Color(0xFF5D3214),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4ECD8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4ECD8),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF3E2723),
        titleTextStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF3E2723),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3E2723),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14.0,
          height: 1.3,
          color: const Color(0xFF3E2723),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF6E5643),
        ),
      ),
    );
  }

  // --- Mode Sombre (Nuit Noire) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFE5A93C),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE5A93C),
        secondary: Color(0xFF6B9AC4),
        surface: Color(0xFF141416),
        onSurface: Color(0xFFE3E3E6),
        primaryContainer: Color(0xFF222225),
        onPrimaryContainer: Color(0xFFF8C46C),
      ),
      scaffoldBackgroundColor: const Color(0xFF141416),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141416),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFFE3E3E6),
        titleTextStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color(0xFFE3E3E6)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE3E3E6),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE3E3E6),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14.0,
          height: 1.3,
          color: const Color(0xFFE3E3E6),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFFA1A1A8),
        ),
      ),
    );
  }

  // Obtenir le ThemeData en fonction du mode enregistré
  static ThemeData getTheme(String mode) {
    switch (mode) {
      case 'sepia':
        return sepiaTheme;
      case 'dark':
        return darkTheme;
      case 'light':
      default:
        return lightTheme;
    }
  }
}
