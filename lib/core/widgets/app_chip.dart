// ============================================================================
// File: app_chip.dart
// Created Date: 27-Sep-2026
// Title: AppChip
// Description:
//   Provides a reusable chip component for displaying technologies, skills,
//   categories, tags, and other compact information throughout the application.
//
// Class:
//   AppChip
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.device,
    this.icon,
    this.onTap,
  });

  final String label;
  final ResponsiveDevice? device;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding(currentDevice),
        vertical: _verticalPadding(currentDevice),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.primaryLight),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryLight,
              fontSize: _fontSize(currentDevice),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return GestureDetector(onTap: onTap, child: chip);
  }

  double _horizontalPadding(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 10,
      ResponsiveDevice.tablet => 11,
      ResponsiveDevice.desktop => 12,
      ResponsiveDevice.ultraHd => 14,
    };
  }

  double _verticalPadding(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 6,
      ResponsiveDevice.tablet => 7,
      ResponsiveDevice.desktop => 7,
      ResponsiveDevice.ultraHd => 8,
    };
  }

  double _fontSize(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 12,
      ResponsiveDevice.tablet => 12,
      ResponsiveDevice.desktop => 13,
      ResponsiveDevice.ultraHd => 14,
    };
  }
}
