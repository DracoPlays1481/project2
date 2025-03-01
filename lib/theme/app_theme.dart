import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // iOS-inspired Color Palette
  static const Color primaryColor = Color(0xFF007AFF); // iOS blue
  static const Color secondaryColor = Color(0xFF5AC8FA); // iOS light blue
  static const Color backgroundColor = Color(0xFFF2F2F7); // iOS light gray background
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFFF3B30); // iOS red
  static const Color successColor = Color(0xFF34C759); // iOS green
  static const Color textPrimaryColor = Color(0xFF000000);
  static const Color textSecondaryColor = Color(0xFF8E8E93); // iOS gray
  static const Color dividerColor = Color(0xFFD1D1D6); // iOS light gray divider

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

      // Typography - iOS uses SF Pro
      fontFamily: '.SF Pro Text',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
          color: textPrimaryColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5,
          color: textSecondaryColor,
        ),
      ),

      // Card Theme - iOS cards have subtle shadows and rounded corners
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_md),
        ),
        margin: const EdgeInsets.all(spacing_sm),
      ),

      // AppBar Theme - iOS-style navigation bar
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: primaryColor),
        actionsIconTheme: IconThemeData(color: primaryColor),
      ),

      // Button Theme - iOS-style buttons
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

      // Text Button Theme - iOS-style text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing_md,
            vertical: spacing_sm,
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // Input Decoration Theme - iOS-style text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing_md,
          vertical: spacing_md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius_lg),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: TextStyle(
          color: textSecondaryColor.withOpacity(0.7),
          fontSize: 17,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontSize: 15,
        ),
      ),

      // List Tile Theme - iOS-style list items
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing_md,
          vertical: spacing_sm,
        ),
        minLeadingWidth: 0,
        minVerticalPadding: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius_sm)),
        ),
      ),

      // Dialog Theme - iOS-style alerts
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_lg),
        ),
        elevation: 0,
        backgroundColor: surfaceColor,
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          color: textPrimaryColor,
        ),
      ),

      // Snackbar Theme - iOS-style notifications
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.8),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius_lg),
        ),
      ),

      // Bottom Sheet Theme - iOS-style action sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius_lg)),
        ),
      ),

      // Switch Theme - iOS-style switches
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey[300]!;
        }),
      ),

      // Slider Theme - iOS-style sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: Colors.white,
        overlayColor: primaryColor.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
      ),

      // Progress Indicator Theme - iOS-style activity indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}