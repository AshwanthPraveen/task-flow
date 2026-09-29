// ============================================================================
// File: user_model.dart
// Created Date: 27-Sep-2026
// Title: UserModel
// Description:
//   Data model for the user object in the login response. Handles JSON
//   parsing and converts to UserEntity.
//
// Class:
//   UserModel
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/auth/domain/entities/user_entity.dart';

class UserModel {
  const UserModel({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email);
  }
}
