import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primarySoft = Color(0xFFEDEAFF);
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primarySoft,
      onSecondaryContainer: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primarySoft,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: _roundedBorder(),
        enabledBorder: _roundedBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySoft,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.primarySoft),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.white,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textSecondary,
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.primarySoft),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _roundedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
  }
}