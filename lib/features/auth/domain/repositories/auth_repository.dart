// ============================================================================
// File: auth_repository.dart
// Created Date: 27-Sep-2026
// Title: AuthRepository
// Description:
//   Abstract contract for auth operations exposed to the domain layer.
//
// Class:
//   AuthRepository
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:task_flow/core/errors/failures.dart';

import 'package:task_flow/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });
}
