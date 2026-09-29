// ============================================================================
// File: app_divider.dart
// Created Date: 27-Sep-2026
// Title: AppDivider
// Description:
//   Provides a reusable divider component with consistent color, thickness,
//   indentation, and spacing throughout the application.
//
// Class:
//   AppDivider
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.height = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.border,
    );
  }
}
