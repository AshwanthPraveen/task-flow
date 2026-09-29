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

  // --------------------------------------------------------------------------
  // Navigation
  // --------------------------------------------------------------------------

  static const String back = 'Back';
  static const String logout = 'Logout';

  // --------------------------------------------------------------------------
  // Tasks
  // --------------------------------------------------------------------------

  static const String tasksHome = 'Tasks Home';
  static const String noTasksYet = 'No tasks yet';
  static const String tasksWillAppearHere =
      'Tasks you create will show up here.';
  static const String refresh = 'Refresh';
  static const String tryAgain = 'Try again';

  // --------------------------------------------------------------------------
  // Task Loading
  // --------------------------------------------------------------------------

  static const String loadingTasks = 'Loading tasks…';
  static const String loadingMoreTasks = 'Loading more tasks…';
  static const String allTasksLoaded = 'You\'re all caught up';

  // --------------------------------------------------------------------------
  // Task Errors
  // --------------------------------------------------------------------------

  static const String refreshFailed = 'Refresh failed';
  static const String couldNotLoadMoreTasks = 'Could not load more tasks';

  // --------------------------------------------------------------------------
  // Task Status
  // --------------------------------------------------------------------------

  static const String completed = 'Completed';
  static const String done = 'Done';
  static const String inProgress = 'In progress';
  static const String pending = 'Pending';
  static const String todo = 'Todo';
  static const String cancelled = 'Cancelled';
  static const String unknown = 'Unknown';

  // --------------------------------------------------------------------------
  // Relative Time
  // --------------------------------------------------------------------------

  static const String justNow = 'Just now';
  static const String minutesAgo = 'm ago';
  static const String hoursAgo = 'h ago';
  static const String daysAgo = 'd ago';

  // --------------------------------------------------------------------------
  // Months
  // --------------------------------------------------------------------------

  static const String january = 'Jan';
  static const String february = 'Feb';
  static const String march = 'Mar';
  static const String april = 'Apr';
  static const String may = 'May';
  static const String june = 'Jun';
  static const String july = 'Jul';
  static const String august = 'Aug';
  static const String september = 'Sep';
  static const String october = 'Oct';
  static const String november = 'Nov';
  static const String december = 'Dec';
}
