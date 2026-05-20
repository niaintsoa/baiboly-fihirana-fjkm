import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Mode Clair (Papyrus) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8B2635), // Rouge Bourgogne profond
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B2635),
        secondary: Color(0xFF3F5E5A), // Vert sauge/forêt doux
        surface: Color(0xFFFDFBF7), // Crème très doux
        onSurface: Color(0xFF2C2520), // Brun très foncé pour lecture
        primaryContainer: Color(0xFFF1E9DB), // Couleur de bouton/carte claire
        onPrimaryContainer: Color(0xFF5D1E27),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDFBF7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFDFBF7),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF2C2520),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C2520),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C2520),
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 18.0,
          height: 1.6,
          color: const Color(0xFF2C2520),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
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
      primaryColor: const Color(0xFF7A431D), // Brun argile
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7A431D),
        secondary: Color(0xFF4A5842),
        surface: Color(0xFFF4ECD8), // Jaune papier antique
        onSurface: Color(0xFF3E2723), // Brun de terre
        primaryContainer: Color(0xFFE8DCBF),
        onPrimaryContainer: Color(0xFF5D3214),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4ECD8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4ECD8),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF3E2723),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF3E2723),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3E2723),
        ),
        bodyLarge: GoogleFonts.lora(
          fontSize: 18.0,
          height: 1.6,
          color: const Color(0xFF3E2723),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
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
      primaryColor: const Color(0xFFE5A93C), // Or doux
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE5A93C),
        secondary: Color(0xFF6B9AC4),
        surface: Color(0xFF141416), // Gris sombre doux
        onSurface: Color(0xFFE3E3E6), // Blanc cassé
        primaryContainer: Color(0xFF222225),
        onPrimaryContainer: Color(0xFFF8C46C),
      ),
      scaffoldBackgroundColor: const Color(0xFF141416),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141416),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFFE3E3E6),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE3E3E6),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE3E3E6),
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 18.0,
          height: 1.6,
          color: const Color(0xFFE3E3E6),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
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
