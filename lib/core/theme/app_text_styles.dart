// ============================================================================
// File: app_text_styles.dart
// Created Date: 27-Sep-2026
// Title: AppTextStyles
// Description:
//   Defines all text styles used throughout the application.
//
// Class:
//   AppTextStyles
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_font_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  // --------------------------------------------------------------------------
  // Display
  // --------------------------------------------------------------------------

  static final display = GoogleFonts.sora(
    fontSize: AppFontSizes.display,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -1.8,
  );

  // --------------------------------------------------------------------------
  // Headings
  // --------------------------------------------------------------------------

  static final heading1 = GoogleFonts.sora(
    fontSize: AppFontSizes.heading1,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -1.2,
  );

  static final heading2 = GoogleFonts.sora(
    fontSize: AppFontSizes.heading2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static final heading3 = GoogleFonts.sora(
    fontSize: AppFontSizes.heading3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.4,
  );

  // --------------------------------------------------------------------------
  // Subtitle
  // --------------------------------------------------------------------------

  static final subtitle = GoogleFonts.sora(
    fontSize: AppFontSizes.subtitle,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // --------------------------------------------------------------------------
  // Body
  // --------------------------------------------------------------------------

  static final bodyLarge = GoogleFonts.inter(
    fontSize: AppFontSizes.bodyLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final body = GoogleFonts.inter(
    fontSize: AppFontSizes.body,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final bodySmall = GoogleFonts.inter(
    fontSize: AppFontSizes.bodySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --------------------------------------------------------------------------
  // Labels
  // --------------------------------------------------------------------------

  static final label = GoogleFonts.inter(
    fontSize: AppFontSizes.label,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // --------------------------------------------------------------------------
  // Caption
  // --------------------------------------------------------------------------

  static final caption = GoogleFonts.inter(
    fontSize: AppFontSizes.caption,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );
}
