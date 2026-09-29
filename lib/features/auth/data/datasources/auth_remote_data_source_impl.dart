// ============================================================================
// File: auth_remote_data_source_impl.dart
// Created Date: 27-Sep-2026
// Title: AuthRemoteDataSourceImpl
// Description:
//   Implements AuthRemoteDataSource using ApiClient to call the login
//   endpoint and parse the response into AuthModel.
//
// Class:
//   AuthRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_flow/features/auth/data/models/auth_model.dart';
import 'package:task_flow/features/auth/data/models/login_request_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthModel> login(LoginRequestModel request) async {
    final Map<String, dynamic> response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthModel.fromJson(response);
  }
}
