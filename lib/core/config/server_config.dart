// ============================================================================
// File: server_config.dart
// Created Date: 27-Sep-2026
// Title: ServerConfig
// Description:
//   Holds the server base URL and network timeout values used by the
//   API client.
//
// Class:
//   ServerConfig
//
// Author: Ashwanth V Praveen
// ============================================================================

class ServerConfig {
  const ServerConfig._();

  static const String baseUrl = 'https://ff64-122-167-97-59.ngrok-free.app';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
