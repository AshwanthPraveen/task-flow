// ============================================================================
// File: app_icon_button.dart
// Created Date: 27-Sep-2026
// Title: AppIconButton
// Description:
//   Provides a reusable icon button component with consistent sizing,
//   background, border, hover-friendly styling, and interaction behavior
//   throughout the application.
//
// Class:
//   AppIconButton
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.device,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.size,
    this.iconSize,
    this.borderRadius,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final ResponsiveDevice? device;
  final String? tooltip;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  final double? size;
  final double? iconSize;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    final buttonSize = size ?? _buttonSize(currentDevice);
    final currentIconSize = iconSize ?? _iconSize(currentDevice);
    final radius = borderRadius ?? _borderRadius(currentDevice);

    Widget button = Material(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? AppColors.border),
          ),
          child: Icon(
            icon,
            size: currentIconSize,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  double _buttonSize(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 40,
      ResponsiveDevice.tablet => 42,
      ResponsiveDevice.desktop => 44,
      ResponsiveDevice.ultraHd => 48,
    };
  }

  double _iconSize(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 18,
      ResponsiveDevice.tablet => 19,
      ResponsiveDevice.desktop => 20,
      ResponsiveDevice.ultraHd => 22,
    };
  }

  double _borderRadius(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 10,
      ResponsiveDevice.tablet => 10,
      ResponsiveDevice.desktop => 10,
      ResponsiveDevice.ultraHd => 12,
    };
  }
}
