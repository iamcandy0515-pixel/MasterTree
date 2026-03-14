import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF80F20D);
  static const Color backgroundDark = Color(0xFF141811);
  static const Color surfaceDark = Color(0xFF1E2210);
  static const Color backgroundLight = Color(0xFFF8F8F5);

  static const Color textDark = Color(0xFF020402);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
}

class AppRadius {
  static const double base = 12.0; // rounded-xl
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppDesign {
  static BoxShadow glowPrimary = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.4),
    blurRadius: 15,
    spreadRadius: 0,
  );

  static BoxShadow glowBar = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.6),
    blurRadius: 10,
    spreadRadius: 0,
  );

  static const double glassBlur = 12.0;

  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.03),
    borderRadius: BorderRadius.circular(24.0), // AppRadius.xl
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
  );
}

class AppTypography {
  static const TextStyle titleLarge = TextStyle(
    color: AppColors.textLight,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppColors.textLight,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleSmall = TextStyle(
    color: AppColors.textLight,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textLight,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
