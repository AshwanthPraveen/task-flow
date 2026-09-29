// ============================================================================
// File: app_loading.dart
// Created Date: 27-Sep-2026
// Title: AppLoading
// Description:
//   Provides a reusable loading indicator component with consistent sizing
//   and styling for loading states throughout the application.
//
// Class:
//   AppLoading
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.device,
    this.size,
    this.strokeWidth = 2,
    this.color,
    this.center = true,
  });

  final ResponsiveDevice? device;
  final double? size;
  final double strokeWidth;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final currentDevice = device ?? Responsive.device(context);

    final loadingSize = size ?? _size(currentDevice);

    final loader = SizedBox(
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primaryLight,
      ),
    );

    if (!center) {
      return loader;
    }

    return Center(child: loader);
  }

  double _size(ResponsiveDevice device) {
    return switch (device) {
      ResponsiveDevice.mobile => 24,
      ResponsiveDevice.tablet => 26,
      ResponsiveDevice.desktop => 28,
      ResponsiveDevice.ultraHd => 32,
    };
  }
}
