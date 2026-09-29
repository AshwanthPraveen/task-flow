// ============================================================================
// File: app_router.dart
// Created Date: 27-Sep-2026
// Title: AppRouter
// Description:
//   Defines application routes and navigation configuration.
//
// Class:
//   AppRouter
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:go_router/go_router.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/storage/user_details.dart';
import 'package:task_flow/features/auth/presentation/pages/login_page.dart';
import 'package:task_flow/features/tasks_home/presentation/pages/tasks_home_page.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/';
  static const String tasks = '/tasks';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final bool isLoggedIn = getIt<UserDetails>().isLoggedIn;
      final bool isLoginRoute = state.matchedLocation == login;

      if (!isLoggedIn && !isLoginRoute) return login;
      if (isLoggedIn && isLoginRoute) return tasks;
      return null;
    },
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(path: tasks, builder: (context, state) => const TasksHomePage()),
    ],
  );
}
