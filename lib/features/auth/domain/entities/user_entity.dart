// ============================================================================
// File: user_entity.dart
// Created Date: 27-Sep-2026
// Title: UserEntity
// Description:
//   Domain entity representing the logged in user (id, name, email).
//
// Class:
//   UserEntity
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}
