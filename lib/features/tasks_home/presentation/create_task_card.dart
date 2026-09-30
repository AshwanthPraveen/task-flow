// ============================================================================
// File: create_task_card.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskCard
// Description:
//   Card used to create a new task. Displays an add icon and action label
//   with device-based responsive sizing.
//
// Class:
//   CreateTaskCard
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import 'package:task_flow/core/constants/app_strings.dart';
import 'package:task_flow/core/responsive/responsive.dart';
import 'package:task_flow/core/theme/app_colors.dart';
import 'package:task_flow/core/theme/app_font_sizes.dart';
import 'package:task_flow/core/theme/app_spacing.dart';
import 'package:task_flow/core/theme/app_text_styles.dart';

class CreateTaskCard extends StatelessWidget {
  const CreateTaskCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double iconSize;
    final double titleSize;

    switch (Responsive.device(context)) {
      case ResponsiveDevice.mobile:
        iconSize = 32;
        titleSize = AppFontSizes.subtitleMobile;
        break;

      case ResponsiveDevice.tablet:
        iconSize = 36;
        titleSize = AppFontSizes.subtitleTablet;
        break;

      case ResponsiveDevice.desktop:
        iconSize = 40;
        titleSize = AppFontSizes.subtitle;
        break;

      case ResponsiveDevice.ultraHd:
        iconSize = 48;
        titleSize = AppFontSizes.subtitleUltraHd;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: iconSize, color: AppColors.accent),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.createTask,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: titleSize,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
