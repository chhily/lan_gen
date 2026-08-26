import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Palette
  static const Color primary = Color(0xFF0A84FF); // System Blue - accent
  static const Color secondary = Color(0xFF2C2C2E); // Elevated grey
  static const Color tertiary = Color(0xFF3A3A3C); // Border grey

  // Background & Surface
  static const Color background = Color(0xFF000000); // App Background (true black)
  static const Color surface = Color(0xFF1C1C1E); // Cards / Panels
  static const Color surfaceAlt = Color(0xFF2C2C2E); // Alternative surface

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Main text
  static const Color textSecondary = Color(0xFF8E8E93); // Secondary text

  // Status Colors (Apple system colors)
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  // Neutral / Utility Colors
  static const Color grey = Color(0xFF8E8E93); // Matches secondary text
  static const Color greyLight = Color(0xFFAEAEB2);
  static const Color greyDark = Color(0xFF48484A);

  // Border Colors
  static const Color border = Color(0xFF3A3A3C);
  static const Color borderDark = Color(0xFF2C2C2E);
}

final appColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.textPrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.textPrimary,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.textPrimary,
  error: AppColors.error,
  onError: AppColors.textPrimary,
  seedColor: AppColors.background,
  surface: AppColors.surface,
  onSurface: AppColors.textPrimary,
  onSurfaceVariant: AppColors.textSecondary,
);