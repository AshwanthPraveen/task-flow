// ============================================================================
// File: responsive_layout.dart
// Created Date: 27-Sep-2026
// Title: ResponsiveLayout
// Description:
//   Provides responsive layout widget that displays different content based on screen size.
//
// Class:
//   ResponsiveLayout
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import 'responsive.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.ultraHd,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget? ultraHd;

  @override
  Widget build(BuildContext context) {
    switch (Responsive.device(context)) {
      case ResponsiveDevice.mobile:
        return mobile;

      case ResponsiveDevice.tablet:
        return tablet;

      case ResponsiveDevice.desktop:
        return desktop;

      case ResponsiveDevice.ultraHd:
        return ultraHd ?? desktop;
    }
  }
}
