import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Palette
  static const Color primary = Color(0xFF243347); // Primary
  static const Color secondary = Color(0xFF1A2633); // Secondary
  static const Color tertiary = Color(0xFFE5E8EB); // Tertiary

  // Background & Surface
  static const Color background = Color(0xFF121A21); // App Background
  static const Color surface = Color(0xFF1A2633); // Cards / Panels
  static const Color surfaceAlt = Color(0xFF243347); // Alternative surface

  // Text Colors
  static const Color textPrimary = Color(0xFFFAFAFA); // Main text
  static const Color textSecondary = Color(0xFF94ABC7); // Secondary text

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFF93261E);
  static const Color info = Color(0xFF2196F3);

  // Neutral / Utility Colors
  static const Color grey = Color(0xFF94ABC7); // Matches secondary text
  static const Color greyLight = Color(0xFFE5E8EB);
  static const Color greyDark = Color(0xFF243347);

  // Border Colors
  static const Color border = Color(0xFFE5E8EB);
  static const Color borderDark = Color(0xFF243347);
}

final appColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.textPrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.textPrimary,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.background,
  error: AppColors.error,
  onError: AppColors.textPrimary,
  seedColor: AppColors.background,
  surface: AppColors.surface,
  onSurface: AppColors.textPrimary,
  onSurfaceVariant: AppColors.secondary,
);
