// ============================================================================
// File: auth_entity.dart
// Created Date: 27-Sep-2026
// Title: AuthEntity
// Description:
//   Domain entity representing a successful login result: access token,
//   token type, expiry and the user.
//
// Class:
//   AuthEntity
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

import 'package:task_flow/features/auth/domain/entities/user_entity.dart';

class AuthEntity extends Equatable {
  const AuthEntity({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserEntity user;

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, user];
}
