// ============================================================================
// File: failures.dart
// Created Date: 27-Sep-2026
// Title: Failures
// Description:
//   Failure types returned by repositories so the bloc layer never deals
//   with raw exceptions.
//
// Class:
//   Failure
//   ServerFailure
//   NetworkFailure
//   TimeoutFailure
//   UnknownFailure
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'Request timed out. Please try again.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
