import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Minimalist Color Palette
  static const Color primaryColor = Color(0xFF2D3436);
  static const Color secondaryColor = Color(0xFF636E72);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD63031);
  static const Color successColor = Color(0xFF00B894);
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Spacing
  static const double spacing_xs = 4.0;
  static const double spacing_sm = 8.0;
  static const double spacing_md = 16.0;
  static const double spacing_lg = 24.0;
  static const double spacing_xl = 32.0;

  // Border Radius
  static const double radius_sm = 8.0;
  static const double radius_md = 12.0;
  static const double radius_lg = 16.0;
  static const double radius_xl = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,

      // Typography using Google Fonts
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5,
          color: textSecondaryColor,
        ),
      ),

      // Card Theme - Minimalist style
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
          side: BorderSide(color: dividerColor, width: 1),
        ),
        margin: const EdgeInsets.all(spacing_sm),
      ),

      // AppBar Theme - Minimalist style
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),

      // Button Theme - Minimalist style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing_lg,
            vertical: spacing_md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius_lg),
          ),
          minimumSize: const Size(44, 44),
        ),
      ),

      // Input Decoration Theme - Minimalist style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing_md,
          vertical: spacing_md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.inter(
          color: textSecondaryColor.withOpacity(0.7),
          fontSize: 17,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondaryColor,
          fontSize: 15,
        ),
      ),
    );
  }
}