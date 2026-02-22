import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ThemeConfig {
  // Color Palette - Fresh Teal & White Theme
  static const Color primaryTeal = Color(0xFF1ABC9C); // Teal from image
  static const Color darkTeal = Color(0xFF16A085);
  static const Color lightTeal = Color(0xFF66D2CE);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color lightPurple = Color(0xFFB19CD9);
  
  // Neutral Colors
  static const Color lightBackground = Color(0xFFF8F9FA); // Slightly off-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color darkText = Color(0xFF2D3436);
  static const Color lightText = Color(0xFFFFFFFF); // Keep for buttons/dark areas
  static const Color mutedText = Color(0xFF636E72);
  
  // Status Colors
  static const Color successGreen = Color(0xFF00B894);
  static const Color warningOrange = Color(0xFFFDCB6E);
  static const Color errorRed = Color(0xFFFF7675);
  static const Color infoBlue = Color(0xFF0984E3);
  
  // Legacy/Compatibility Colors (Mapped to new theme to prevent breakages)
  static const Color primaryBlue = primaryTeal;
  static const Color lightBlue = lightTeal;
  static const Color secondaryGreen = darkTeal;
  static const Color darkGreen = darkTeal;
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121218);
  static const Color darkSurface = Color(0xFF1E1E2C);
  static const Color darkCard = Color(0xFF252536);
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFF9A9AB0);
  static const Color darkBorder = Color(0xFF2E2E42);

  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  
  // Glassmorphism
  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.15;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: darkTeal,
      tertiary: accentPurple,
      surface: lightSurface,
      error: errorRed,
    ),
    textTheme: GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 26, // Reduced from 32
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 24, // Reduced from 28
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 20, // Reduced from 24
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 18, // Reduced from 22
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 16, // Reduced from 20
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 15, // Reduced from 18
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 14, // Reduced from 16
        fontWeight: FontWeight.normal,
        color: darkText,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 13, // Reduced from 14
        fontWeight: FontWeight.normal,
        color: darkText,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 11, // Reduced from 12
        fontWeight: FontWeight.normal,
        color: mutedText,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18, // Reduced from 20
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      iconTheme: const IconThemeData(color: darkText),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      color: lightSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryTeal,
        foregroundColor: lightText,
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 14, // Reduced from 16
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    ),
  );
  
  // Dark Theme - Premium dark UI
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryTeal,
      secondary: darkTeal,
      tertiary: accentPurple,
      surface: darkSurface,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: darkTextPrimary,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: darkTextSecondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      color: darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      hintStyle: GoogleFonts.montserrat(color: darkTextSecondary),
      labelStyle: GoogleFonts.montserrat(color: darkTextSecondary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryTeal,
      unselectedItemColor: darkTextSecondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryTeal;
        return darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryTeal.withOpacity(0.4);
        return darkBorder;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCard,
      contentTextStyle: GoogleFonts.montserrat(color: darkTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
      behavior: SnackBarBehavior.floating,
    ),
  );
  
  // Gradient Backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryTeal, lightTeal],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTeal, primaryTeal],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, lightPurple],
  );
  
  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF81ECEC), Color(0xFF74B9FF)], // Lighter calm colors
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7675), Color(0xFFFFEAA7)],
  );
}
