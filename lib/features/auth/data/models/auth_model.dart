// ============================================================================
// File: auth_model.dart
// Created Date: 27-Sep-2026
// Title: AuthModel
// Description:
//   Data model for the login API response. Parses access_token,
//   token_type, expires_in and user from JSON and converts to AuthEntity.
//
// Class:
//   AuthModel
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/auth/data/models/user_model.dart';
import 'package:task_flow/features/auth/domain/entities/auth_entity.dart';

class AuthModel {
  const AuthModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      user: user.toEntity(),
    );
  }
}
