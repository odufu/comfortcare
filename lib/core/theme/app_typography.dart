import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme createTextTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 44 / 36,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 18 / 14,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 12 / 10,
        color: onSurfaceVariant,
      ),
    );
  }
}
