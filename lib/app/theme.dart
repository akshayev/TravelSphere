import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color backgroundDark = Color(0xFF1A1A2E); // Deep Navy
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.white70;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)], // Cyan-Blue
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green-Teal
  );

  // Shapes & Effects
  static final BorderRadius cardRadius = BorderRadius.circular(24);
  static final BorderRadius buttonRadius = BorderRadius.circular(30);

  static const Color primaryBlue = Color(0xFF4facfe);
  static const Color darkGray = Color(0xFF1A1A2E);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundDark,
      // ... (rest of lightTheme)
    );
  }

  static ThemeData get darkTheme => lightTheme; // Use same glass theme for both temporarily
}
