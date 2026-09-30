// ============================================================================
// File: api_endpoints.dart
// Created Date: 27-Sep-2026
// Title: ApiEndpoints
// Description:
//   Central list of all API endpoint paths used across the app.
//
// Class:
//   ApiEndpoints
//
// Author: Ashwanth V Praveen
// ============================================================================

class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String tasks = '/tasks';
  static const String sync = '/sync';
  static String taskById(int id) => '/tasks/$id';
}
