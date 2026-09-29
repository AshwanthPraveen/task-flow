// ============================================================================
// File: login_usecase.dart
// Created Date: 27-Sep-2026
// Title: LoginUseCase
// Description:
//   Use case that logs the user in with email and password through
//   AuthRepository.
//
// Class:
//   LoginUseCase
//   LoginParams
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/core/errors/failures.dart';
import 'package:task_flow/core/usecase/usecase.dart';
import 'package:task_flow/features/auth/domain/entities/auth_entity.dart';
import 'package:task_flow/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthEntity, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
