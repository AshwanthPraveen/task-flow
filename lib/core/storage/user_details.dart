// ============================================================================
// File: user_details.dart
// Created Date: 27-Sep-2026
// Title: UserDetails
// Description:
//   Single place to save and read the logged in user's session details
//   (token, token type, id, name, email) using SharedPreferences.
//
// Class:
//   UserDetails
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

import 'package:task_flow/core/storage/storage_keys.dart';

class UserDetails {
  const UserDetails(this._prefs);

  final SharedPreferences _prefs;

  String? get accessToken => _prefs.getString(StorageKeys.accessToken);
  String? get tokenType => _prefs.getString(StorageKeys.tokenType);
  int? get userId => _prefs.getInt(StorageKeys.userId);
  String? get userName => _prefs.getString(StorageKeys.userName);
  String? get userEmail => _prefs.getString(StorageKeys.userEmail);

  bool get isLoggedIn {
    final String? token = accessToken;
    return token != null && token.isNotEmpty;
  }

  Future<void> saveSession({
    required String accessToken,
    required String tokenType,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    await _prefs.setString(StorageKeys.accessToken, accessToken);
    await _prefs.setString(StorageKeys.tokenType, tokenType);
    await _prefs.setInt(StorageKeys.userId, userId);
    await _prefs.setString(StorageKeys.userName, userName);
    await _prefs.setString(StorageKeys.userEmail, userEmail);
  }

  Future<void> clear() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.tokenType);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userName);
    await _prefs.remove(StorageKeys.userEmail);
  }
}
