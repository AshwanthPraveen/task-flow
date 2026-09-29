// ============================================================================
// File: app_strings.dart
// Created Date: 27-Sep-2026
// Title: AppStrings
// Description:
//   Defines all static strings used throughout the application.
//
// Class:
//   AppStrings
//
// Author: Ashwanth V Praveen
// ============================================================================

class AppStrings {
  AppStrings._();

  // --------------------------------------------------------------------------
  // App
  // --------------------------------------------------------------------------

  static const String appName = 'Task Flow';
  static const String appTagline = 'Stay focused. Get things done.';

  // --------------------------------------------------------------------------
  // Authentication
  // --------------------------------------------------------------------------

  static const String welcomeBack = 'Welcome back';
  static const String loginSubtitle =
      'Sign in to continue managing your tasks.';

  static const String email = 'Email address';
  static const String password = 'Password';
  static const String login = 'Login';

  static const String secureTaskManagement = 'Secure task management';

  // --------------------------------------------------------------------------
  // Authentication Errors
  // --------------------------------------------------------------------------

  static const String loginFailed = 'Login failed';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
}
