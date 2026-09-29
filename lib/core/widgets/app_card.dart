// ============================================================================
// File: app_card.dart
// Created Date: 27-Sep-2026
// Title: AppCard
// Description:
//   Provides a reusable card component with consistent application-wide
//   styling. Supports responsive padding, customizable borders, radius,
//   shadows, background colors, and optional tap interactions.
//
// Class:
//   AppCard
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.device,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.elevation = 0,
    this.shadowColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final ResponsiveDevice? device;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final double? width;
  final double? height;

  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  final double elevation;
  final Color? shadowColor;

  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    final cardPadding = padding ?? _defaultPadding(currentDevice);

    final radius = borderRadius ?? _defaultRadius(currentDevice);

    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth,
      ),
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: (shadowColor ?? Colors.black).withValues(alpha: 0.20),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation),
              ),
            ]
          : null,
    );

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: cardPadding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: clipBehavior,
      child: card,
    );
  }

  // --------------------------------------------------------------------------
  // Responsive Values
  // --------------------------------------------------------------------------

  EdgeInsets _defaultPadding(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => const EdgeInsets.all(AppSpacing.md),
      ResponsiveDevice.tablet => const EdgeInsets.all(AppSpacing.lg),
      ResponsiveDevice.desktop => const EdgeInsets.all(AppSpacing.lg),
      ResponsiveDevice.ultraHd => const EdgeInsets.all(AppSpacing.xl),
    };
  }

  double _defaultRadius(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 12,
      ResponsiveDevice.tablet => 14,
      ResponsiveDevice.desktop => 16,
      ResponsiveDevice.ultraHd => 18,
    };
  }
}
