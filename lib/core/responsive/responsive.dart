// ============================================================================
// File: responsive.dart
// Created Date: 27-Sep-2026
// Title: Responsive
// Description:
//   Provides responsive device detection and utility functions.
//
// Class:
//   Responsive
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

enum ResponsiveDevice { mobile, tablet, desktop, ultraHd }

class Responsive {
  Responsive._();

  /// Returns the current device category based on screen width.
  static ResponsiveDevice device(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < AppBreakpoints.mobile) {
      return ResponsiveDevice.mobile;
    }

    if (width < AppBreakpoints.tablet) {
      return ResponsiveDevice.tablet;
    }

    if (width < AppBreakpoints.ultraHd) {
      return ResponsiveDevice.desktop;
    }

    return ResponsiveDevice.ultraHd;
  }

  static bool isMobile(BuildContext context) {
    return device(context) == ResponsiveDevice.mobile;
  }

  static bool isTablet(BuildContext context) {
    return device(context) == ResponsiveDevice.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return device(context) == ResponsiveDevice.desktop;
  }

  static bool isUltraHd(BuildContext context) {
    return device(context) == ResponsiveDevice.ultraHd;
  }
}
