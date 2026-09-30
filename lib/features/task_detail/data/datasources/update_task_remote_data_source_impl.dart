// ============================================================================
// File: update_task_remote_data_source_impl.dart
// Created Date: 30-Sep-2026
// Title: UpdateTaskRemoteDataSourceImpl
// Description:
//   Calls PUT /tasks/{id} through ApiClient and parses the response.
//
// Class:
//   UpdateTaskRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/task_detail/data/datasources/update_task_remote_data_source.dart';
import 'package:task_flow/features/task_detail/data/models/update_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

class UpdateTaskRemoteDataSourceImpl implements UpdateTaskRemoteDataSource {
  const UpdateTaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TaskModel> updateTask(int id, UpdateTaskRequestModel request) async {
    final Map<String, dynamic> response = await _apiClient.put(
      ApiEndpoints.taskById(id),
      data: request.toJson(),
    );
    return TaskModel.fromJson(response);
  }
}
