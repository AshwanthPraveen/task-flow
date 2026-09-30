// ============================================================================
// File: task_card.dart
// Created Date: 29-Sep-2026
// Title: TaskCard
// Description:
//   Card that shows a single task: status stripe, title, optional description,
//   status chip and relative updated time. Uses AppColors, AppTextStyles,
//   AppSpacing and device-based font sizes only.
//
// Class:
//   TaskCard
//   _StatusChip
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
import 'package:task_flow/features/tasks_home/domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final TaskEntity task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = _statusColor(task.status);

    final String? description = task.description?.trim();

    final bool hasDescription = description != null && description.isNotEmpty;

    final double titleSize;
    final double bodySize;
    final double labelSize;
    final double captionSize;

    switch (Responsive.device(context)) {
      case ResponsiveDevice.mobile:
        titleSize = AppFontSizes.subtitleMobile;
        bodySize = AppFontSizes.bodyMobile;
        labelSize = AppFontSizes.labelMobile;
        captionSize = AppFontSizes.captionMobile;
        break;

      case ResponsiveDevice.tablet:
        titleSize = AppFontSizes.subtitleTablet;
        bodySize = AppFontSizes.bodyTablet;
        labelSize = AppFontSizes.labelTablet;
        captionSize = AppFontSizes.captionTablet;
        break;

      case ResponsiveDevice.desktop:
        titleSize = AppFontSizes.subtitle;
        bodySize = AppFontSizes.body;
        labelSize = AppFontSizes.label;
        captionSize = AppFontSizes.caption;
        break;

      case ResponsiveDevice.ultraHd:
        titleSize = AppFontSizes.subtitleUltraHd;
        bodySize = AppFontSizes.bodyUltraHd;
        labelSize = AppFontSizes.labelUltraHd;
        captionSize = AppFontSizes.captionUltraHd;
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
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accent, width: AppSpacing.xxs),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subtitle.copyWith(fontSize: titleSize),
              ),

              if (hasDescription) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(fontSize: bodySize),
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  _StatusChip(
                    label: _statusLabel(task.status),
                    color: accent,
                    fontSize: labelSize,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: bodySize,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    _relativeTime(task.updatedAt),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: captionSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.success;

      case 'in_progress':
      case 'in progress':
        return AppColors.accent;

      case 'pending':
      case 'todo':
        return AppColors.warning;

      case 'cancelled':
        return AppColors.error;

      default:
        return AppColors.textMuted;
    }
  }

  static String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppStrings.completed;

      case 'done':
        return AppStrings.done;

      case 'in_progress':
      case 'in progress':
        return AppStrings.inProgress;

      case 'pending':
        return AppStrings.pending;

      case 'todo':
        return AppStrings.todo;

      case 'cancelled':
        return AppStrings.cancelled;

      default:
        return AppStrings.unknown;
    }
  }

  static String _relativeTime(DateTime time) {
    final DateTime t = time.toLocal();
    final Duration diff = DateTime.now().difference(t);

    if (diff.inMinutes < 1) {
      return AppStrings.justNow;
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${AppStrings.minutesAgo}';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}${AppStrings.hoursAgo}';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}${AppStrings.daysAgo}';
    }

    const List<String> months = [
      AppStrings.january,
      AppStrings.february,
      AppStrings.march,
      AppStrings.april,
      AppStrings.may,
      AppStrings.june,
      AppStrings.july,
      AppStrings.august,
      AppStrings.september,
      AppStrings.october,
      AppStrings.november,
      AppStrings.december,
    ];

    return '${t.day} ${months[t.month - 1]} ${t.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.fontSize,
  });

  final String label;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color, fontSize: fontSize),
      ),
    );
  }
}
