// ============================================================================
// File: connectivity_service.dart
// Created Date: 01-Oct-2026
// Title: ConnectivityService
// Description:
//   Tells the app whether the device has a network connection. Wraps
//   connectivity_plus so the rest of the code only sees a bool. A connection
//   does not guarantee the server is reachable; requests still handle their
//   own network errors.
//
// Class:
//   ConnectivityService
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Current state of the device connection.
  Future<bool> get isOnline async {
    return _hasConnection(await _connectivity.checkConnectivity());
  }

  /// Emits true/false each time the device goes online or offline.
  Stream<bool> get onChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
