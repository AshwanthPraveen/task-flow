// ============================================================================
// File: api_exception.dart
// Created Date: 27-Sep-2026
// Title: ApiException
// Description:
//   Custom exception types thrown by the API client so the bloc layer
//   receives clean messages instead of raw Dio errors.
//
// Class:
//   ApiException
//   NetworkException
//   TimeoutApiException
//
// Author: Ashwanth V Praveen
// ============================================================================

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection.']);
}

class TimeoutApiException extends ApiException {
  const TimeoutApiException([
    super.message = 'Request timed out. Please try again.',
  ]);
}
