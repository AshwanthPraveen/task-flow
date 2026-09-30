// ============================================================================
// File: sync_remote_data_source_impl.dart
// Created Date: 01-Oct-2026
// Title: SyncRemoteDataSourceImpl
// Description:
//   Calls POST /sync through the shared ApiClient.
//
// Class:
//   SyncRemoteDataSourceImpl
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/core/sync/sync_models.dart';
import 'package:task_flow/core/sync/sync_remote_data_source.dart';

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  const SyncRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SyncResultModel>> sync(List<SyncOperationModel> changes) async {
    final Map<String, dynamic> response = await _apiClient.post(
      ApiEndpoints.sync,
      data: {'changes': changes.map((c) => c.toJson()).toList()},
    );

    final List<dynamic> results =
        (response['results'] as List<dynamic>?) ?? const <dynamic>[];

    return results
        .map((e) => SyncResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
