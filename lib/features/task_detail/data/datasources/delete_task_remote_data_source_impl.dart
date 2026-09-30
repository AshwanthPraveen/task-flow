// ============================================================================
// File: delete_task_remote_data_source_impl.dart
// Created Date: 30-Sep-2026
// Title: DeleteTaskRemoteDataSourceImpl
// Description:
//   Calls DELETE /tasks/{id} through ApiClient.
//
// Class:
//   DeleteTaskRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/task_detail/data/datasources/delete_task_remote_data_source.dart';

class DeleteTaskRemoteDataSourceImpl implements DeleteTaskRemoteDataSource {
  const DeleteTaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> deleteTask(int id) {
    return _apiClient.delete(ApiEndpoints.taskById(id));
  }
}
