// ============================================================================
// File: login_request_model.dart
// Created Date: 27-Sep-2026
// Title: LoginRequestModel
// Description:
//   Request body model for the login API (email and password).
//
// Class:
//   LoginRequestModel
//
// Author: Ashwanth V Praveen
// ============================================================================

class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
