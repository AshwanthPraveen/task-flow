// ============================================================================
// File: api_client.dart
// Created Date: 29-Sep-2026
// Title: ApiClient
// Description:
//   Thin Dio wrapper for all API calls. Provides GET and POST helpers,
//   attaches the Authorization header when an auth header provider is
//   given, and maps Dio errors into ApiException types.
//
// Class:
//   ApiClient
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:dio/dio.dart';
import 'package:task_flow/core/config/server_config.dart';
import 'package:task_flow/core/network/api_exception.dart';

/// Returns the full Authorization header value (e.g. `Bearer <token>`),
/// or null when the user is not logged in.
typedef AuthHeaderProvider = Future<String?> Function();

class ApiClient {
  ApiClient({Dio? dio, AuthHeaderProvider? authHeaderProvider})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ServerConfig.baseUrl,
              connectTimeout: ServerConfig.connectTimeout,
              receiveTimeout: ServerConfig.receiveTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                // Skips the ngrok browser warning page. Remove for production.
                'ngrok-skip-browser-warning': 'true',
              },
            ),
          ) {
    if (authHeaderProvider != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final String? authHeader = await authHeaderProvider();
            if (authHeader != null && authHeader.isNotEmpty) {
              options.headers['Authorization'] = authHeader;
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(path, queryParameters: queryParameters);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(path, data: data);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutApiException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return ApiException(
          _extractMessage(e.response?.data),
          statusCode: e.response?.statusCode,
        );
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final dynamic detail = data['detail'];

      // 422 validation error: detail is a list of {loc, msg, type}
      if (detail is List && detail.isNotEmpty) {
        final dynamic first = detail.first;
        if (first is Map<String, dynamic> && first['msg'] is String) {
          return first['msg'] as String;
        }
      }

      // Custom errors: detail is {error: {code, message}}
      if (detail is Map<String, dynamic>) {
        final dynamic error = detail['error'];
        if (error is Map<String, dynamic> && error['message'] is String) {
          return error['message'] as String;
        }
      }

      // Other errors: detail is a plain string
      if (detail is String) return detail;
    }
    return 'Something went wrong. Please try again.';
  }
}
