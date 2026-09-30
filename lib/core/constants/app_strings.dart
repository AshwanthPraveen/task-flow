// ============================================================================
//
// File: app_strings.dart
// Created Date: 27-Sep-2026
// Title: AppStrings
// Description:
//
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
  static const String logoutMessage = 'Are you sure you want to log out?';

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
  // Task Status Values
  // --------------------------------------------------------------------------

  static const String statusTodo = 'Todo';
  static const String statusInProgress = 'In progress';
  static const String statusCompleted = 'Completed';

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

  // --------------------------------------------------------------------------
  // Create Task
  // --------------------------------------------------------------------------

  static const String createTask = 'Create Task';
  static const String taskTitle = 'Task title';
  static const String taskDescription = 'Task description';
  static const String create = 'Create';
  static const String close = 'Close';
  static const String taskCreated = 'Task created';
  static const String taskCreatedMessage = 'Your task was added successfully.';

  // --------------------------------------------------------------------------
  // Task Detail
  // --------------------------------------------------------------------------

  static const String taskDetail = 'Task Detail';
  static const String taskKeyPrefix = 'TASK-';
  static const String addDescription = 'Add a description...';

  // --------------------------------------------------------------------------
  // Task Details
  // --------------------------------------------------------------------------

  static const String details = 'Details';
  static const String status = 'Status';
  static const String createdBy = 'Created by';
  static const String created = 'Created';
  static const String lastUpdated = 'Last updated';
  static const String task = 'Task';

  // --------------------------------------------------------------------------
  // Task Activity
  // --------------------------------------------------------------------------

  static const String activity = 'Activity';

  // --------------------------------------------------------------------------
  // Task Editing
  // --------------------------------------------------------------------------

  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String you = 'You';
  static const String userPrefix = 'User ';

  // --------------------------------------------------------------------------
  // Task Update
  // --------------------------------------------------------------------------

  static const String taskUpdated = 'Task updated';
  static const String taskUpdatedMessage =
      'Your task was updated successfully.';
  static const String updateFailed = 'Update failed';

  // --------------------------------------------------------------------------
  // Task Delete
  // --------------------------------------------------------------------------

  static const String deleteTask = 'Delete task';
  static const String deleteTaskMessage =
      'Are you sure you want to delete this task? This action cannot be undone.';
  static const String delete = 'Delete';
  static const String taskDeleted = 'Task deleted';
  static const String taskDeletedMessage =
      'Your task was deleted successfully.';
}
