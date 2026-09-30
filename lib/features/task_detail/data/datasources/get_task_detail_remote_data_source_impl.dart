// ============================================================================
// File: get_task_detail_remote_data_source_impl.dart
// Created Date: 30-Sep-2026
// Title: GetTaskDetailRemoteDataSourceImpl
// Description:
//   Implements GetTaskDetailRemoteDataSource using ApiClient to call the
//   task by id endpoint and parse the response into TaskModel.
//
// Class:
//   GetTaskDetailRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/task_detail/data/datasources/get_task_detail_remote_data_source.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

class GetTaskDetailRemoteDataSourceImpl
    implements GetTaskDetailRemoteDataSource {
  const GetTaskDetailRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TaskModel> getTaskDetail(int id) async {
    final Map<String, dynamic> response = await _apiClient.get(
      ApiEndpoints.taskById(id),
    );
    return TaskModel.fromJson(response);
  }
}
