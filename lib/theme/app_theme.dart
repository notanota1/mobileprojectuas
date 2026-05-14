import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Cinema Dark Luxury Palette
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceVariant = Color(0xFF1C1C28);
  static const Color card = Color(0xFF16161F);

  // Gold Accent
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C46A);
  static const Color goldDark = Color(0xFFB8892F);

  // Red Cinema
  static const Color cinemaRed = Color(0xFFBE1E2D);
  static const Color cinemaRedLight = Color(0xFFE53935);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF5A5A6A);

  // Others
  static const Color divider = Color(0xFF2A2A38);
  static const Color shimmerBase = Color(0xFF1A1A24);
  static const Color shimmerHighlight = Color(0xFF252535);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.cinemaRed,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.cinzelTextTheme().copyWith(
        displayLarge: GoogleFonts.cinzel(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        headlineLarge: GoogleFonts.cinzel(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        headlineMedium: GoogleFonts.raleway(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.raleway(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.raleway(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.raleway(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}