import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0D0D12);
  static const Color surface = Color(0xFF16161E);
  static const Color surfaceLight = Color(0xFF1E1E2A);
  static const Color surfaceElevated = Color(0xFF252535);

  // Accents
  static const Color accent = Color(0xFF00E5CC);
  static const Color accentDim = Color(0xFF008F7F);
  static const Color accentWarm = Color(0xFFFF6B35);

  // Status
  static const Color online = Color(0xFF00E676);
  static const Color offline = Color(0xFFFF5252);
  static const Color waking = Color(0xFFFFAB40);

  // Text
  static const Color textPrimary = Color(0xFFEAEAF0);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textDim = Color(0xFF45455A);

  // Neumorphic Shadows
  static const Color neuShadowDark = Color(0xFF08080D);
  static const Color neuShadowLight = Color(0xFF1F1F2B);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A26),
      Color(0xFF14141E),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E5CC),
      Color(0xFF00B4A0),
    ],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF4500),
    ],
  );
}

class NeuDecoration {
  NeuDecoration._();

  static BoxDecoration floating({
    double borderRadius = 20,
    Gradient? gradient,
    Color? color,
    double elevation = 1.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: gradient ?? AppColors.cardGradient,
      color: gradient == null ? color : null,
      boxShadow: [
        // Dark shadow (bottom-right) – depth
        BoxShadow(
          color: AppColors.neuShadowDark.withValues(alpha: 0.7 * elevation),
          offset: Offset(6 * elevation, 6 * elevation),
          blurRadius: 16 * elevation,
          spreadRadius: 1,
        ),
        // Light highlight (top-left) – anti-gravity lift
        BoxShadow(
          color: AppColors.neuShadowLight.withValues(alpha: 0.4 * elevation),
          offset: Offset(-4 * elevation, -4 * elevation),
          blurRadius: 12 * elevation,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration inset({
    double borderRadius = 16,
    Color? color,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: color ?? AppColors.background,
      boxShadow: [
        const BoxShadow(
          color: AppColors.neuShadowDark,
          offset: Offset(2, 2),
          blurRadius: 6,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.neuShadowLight.withValues(alpha: 0.3),
          offset: const Offset(-2, -2),
          blurRadius: 6,
          spreadRadius: -2,
        ),
      ],
    );
  }

  static List<BoxShadow> glowShadow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 4 * intensity,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.1 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 8 * intensity,
      ),
    ];
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.accentWarm,
        error: AppColors.offline,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textDim,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 0.6,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.offline, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: AppColors.textDim, fontSize: 15),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
