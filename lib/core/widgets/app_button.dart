// ============================================================================
// File: app_button.dart
// Created Date: 27-Sep-2026
// Title: AppButton
// Description:
//   Provides a reusable and customizable button component used throughout
//   the application. Supports primary, outlined, and text button variants,
//   optional icons, loading states, responsive sizing, and consistent
//   application-wide styling.
//
// Class:
//   AppButton
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonType { primary, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.iconPosition = AppButtonIconPosition.left,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.device,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final ResponsiveDevice? device;

  bool get _isDisabled => isDisabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    final buttonHeight = height ?? _height(currentDevice);
    final horizontalPadding = _horizontalPadding(currentDevice);
    final textStyle = _textStyle(currentDevice);

    final Widget content = _buildContent(textStyle, currentDevice);

    final Widget button = switch (type) {
      AppButtonType.primary => ElevatedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _primaryStyle(
          buttonHeight: buttonHeight,
          horizontalPadding: horizontalPadding,
        ),
        child: content,
      ),
      AppButtonType.outlined => OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _outlinedStyle(
          buttonHeight: buttonHeight,
          horizontalPadding: horizontalPadding,
        ),
        child: content,
      ),
      AppButtonType.text => TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _textButtonStyle(
          buttonHeight: buttonHeight,
          horizontalPadding: horizontalPadding,
        ),
        child: content,
      ),
    };

    if (width != null) {
      return SizedBox(width: width, height: buttonHeight, child: button);
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: button,
      );
    }

    return SizedBox(height: buttonHeight, child: button);
  }

  // --------------------------------------------------------------------------
  // Content
  // --------------------------------------------------------------------------

  Widget _buildContent(TextStyle textStyle, ResponsiveDevice device) {
    final textWidget = Text(label, style: textStyle);

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _loadingIndicator(device),
          const SizedBox(width: AppSpacing.xs),
          textWidget,
        ],
      );
    }

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(icon, size: 18);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconPosition == AppButtonIconPosition.left
          ? [iconWidget, const SizedBox(width: AppSpacing.xs), textWidget]
          : [textWidget, const SizedBox(width: AppSpacing.xs), iconWidget],
    );
  }

  Widget _loadingIndicator(ResponsiveDevice device) {
    return SizedBox(
      width: _loadingSize(device),
      height: _loadingSize(device),
      child: CircularProgressIndicator(strokeWidth: 2, color: _loadingColor()),
    );
  }

  // --------------------------------------------------------------------------
  // Styles
  // --------------------------------------------------------------------------

  ButtonStyle _primaryStyle({
    required double buttonHeight,
    required double horizontalPadding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      disabledBackgroundColor: AppColors.surfaceElevated,
      disabledForegroundColor: AppColors.textMuted,
      elevation: 0,
      minimumSize: Size(0, buttonHeight),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _outlinedStyle({
    required double buttonHeight,
    required double horizontalPadding,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      disabledForegroundColor: AppColors.textMuted,
      minimumSize: Size(0, buttonHeight),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ).copyWith(
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? AppColors.border
              : AppColors.primary,
          width: 1,
        ),
      ),
    );
  }

  ButtonStyle _textButtonStyle({
    required double buttonHeight,
    required double horizontalPadding,
  }) {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      disabledForegroundColor: AppColors.textMuted,
      minimumSize: Size(0, buttonHeight),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // --------------------------------------------------------------------------
  // Responsive Values
  // --------------------------------------------------------------------------

  double _height(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 44,
      ResponsiveDevice.tablet => 46,
      ResponsiveDevice.desktop => 48,
      ResponsiveDevice.ultraHd => 52,
    };
  }

  double _horizontalPadding(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 16,
      ResponsiveDevice.tablet => 18,
      ResponsiveDevice.desktop => 22,
      ResponsiveDevice.ultraHd => 26,
    };
  }

  double _loadingSize(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 16,
      ResponsiveDevice.tablet => 17,
      ResponsiveDevice.desktop => 18,
      ResponsiveDevice.ultraHd => 20,
    };
  }

  TextStyle _textStyle(ResponsiveDevice device) {
    final fontSize = switch (device) {
      ResponsiveDevice.mobile => 14.0,
      ResponsiveDevice.tablet => 14.0,
      ResponsiveDevice.desktop => 15.0,
      ResponsiveDevice.ultraHd => 16.0,
    };

    return AppTextStyles.body.copyWith(
      fontSize: fontSize,
      color: _isDisabled ? AppColors.textMuted : AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
  }

  Color _loadingColor() {
    return AppColors.textMuted;
  }
}

enum AppButtonIconPosition { left, right }
