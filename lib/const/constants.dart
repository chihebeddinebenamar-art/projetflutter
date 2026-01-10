import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // New Brand Identity: Cyber/Glass
  static const Color primary = Color(0xFF00F2FF); // Neon Cyan
  static const Color primaryVariant = Color(0xFF00BBF9);
  
  static const Color secondary = Color(0xFFD900FF); // Neon Magenta
  static const Color secondaryVariant = Color(0xFFB100CD);

  // Backgrounds - Deep Dark Theme
  static const Color backgroundDark = Color(0xFF050511); // Almost Black
  static const Color backgroundLight = Color(0xFF121223); // Deep Navy

  // Surface & Glass
  static const Color surface = Color(0xFF1E1E30);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% White
  static const Color glassBlack = Color(0x80000000); // 50% Black

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color textHighlight = Color(0xFF00F2FF);

  // Status
  static const Color success = Color(0xFF00FF94);
  static const Color error = Color(0xFFFF2E93);
  static const Color warning = Color(0xFFFFD600);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F2FF), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD900FF), Color(0xFF6F00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF121223), Color(0xFF050511)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Aliases for compatibility
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const LinearGradient secondaryGradient = accentGradient;
}

class AppTextStyles {
  // Using "Orbitron" for headers (Tech/Sci-Fi feel) and "Rajdhani" or "Outfit" for body
  
  static TextStyle get displayLarge => GoogleFonts.orbitron(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.orbitron(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get button => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
  );
}

class AppDimensions {
  static const double paddingS = 10.0;
  static const double paddingM = 20.0;
  static const double paddingL = 30.0;
  static const double paddingXL = 40.0;

  static const double radiusS = 16.0;
  static const double radiusM = 24.0;
  static const double radiusL = 40.0;
}

// Glassmorphism Decorator Helper
class AppDecorations {
  static BoxDecoration glassBox({
    Color tint = AppColors.glassWhite, 
    double radius = AppDimensions.radiusM,
    bool border = true,
  }) {
    return BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(radius),
      border: border 
          ? Border.all(color: Colors.white.withOpacity(0.1), width: 1) 
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
