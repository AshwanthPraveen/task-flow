// ============================================================================
// File: task_remote_data_source_impl.dart
// Created Date: 29-Sep-2026
// Title: TaskRemoteDataSourceImpl
// Description:
//   Implements TaskRemoteDataSource using ApiClient to call the tasks endpoint
//   with page and limit query parameters and parse the response into
//   TaskListModel.
//
// Class:
//   TaskRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/tasks_home/data/models/task_list_model.dart';
import 'package:task_flow/features/tasks_home/data/datasources/task_remote_data_source.dart';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TaskListModel> getTasks({
    required int page,
    required int limit,
  }) async {
    final Map<String, dynamic> response = await _apiClient.get(
      ApiEndpoints.tasks,
      queryParameters: {'page': page, 'limit': limit},
    );
    return TaskListModel.fromJson(response);
  }
}
