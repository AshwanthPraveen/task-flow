// ============================================================================
// File: app_theme.dart
// Created Date: 27-Sep-2026
// Title: AppTheme
// Description:
//   Defines all text styles used throughout the application.
//
// Class:
//   AppTheme
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),

    dividerColor: AppColors.border,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
