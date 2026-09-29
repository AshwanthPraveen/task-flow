// ============================================================================
// File: auth_remote_data_source.dart
// Created Date: 27-Sep-2026
// Title: AuthRemoteDataSource
// Description:
//   Abstract contract for auth related remote API calls.
//
// Class:
//   AuthRemoteDataSource
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/features/auth/data/models/auth_model.dart';
import 'package:task_flow/features/auth/data/models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(LoginRequestModel request);
}
