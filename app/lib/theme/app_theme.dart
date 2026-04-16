import 'package:flutter/material.dart';

class AppTheme {
  // --- PALETA KOLORÓW (MineStation Palette) ---
  static const Color background = Color(0xFF0D0216); // Głębsza czerń
  static const Color surface = Color(0xFF19082B);    // Kolor kart
  static const Color primary = Color(0xFFBE18FF);    // Neonowa zieleń (Matrix/MC)
  static const Color accent = Color(0xFF00F5FF);     // Cyjan dla technicznych danych
  static const Color textMain = Color(0xFFF1E9F6);
  static const Color textMuted = Color(0xFF9A8BAA);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      fontFamily: 'Inter',

      textTheme: const TextTheme(
        // NAGŁÓWKI: Rajdhani
        displayLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textMain,
          letterSpacing: 3.5, // "Kosmiczny" odstęp
        ),
        titleLarge: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 1.5,
        ),

        // TREŚĆ: Inter
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: textMain,
        ),

        // DANE / LOGI: JetBrains Mono
        labelSmall: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          color: accent,
        ),
      ),

      // Stylizacja Kart (Cards)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: textMuted.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}