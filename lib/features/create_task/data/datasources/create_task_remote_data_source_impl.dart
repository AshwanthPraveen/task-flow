// ============================================================================
// File: create_task_remote_data_source_impl.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRemoteDataSourceImpl
// Description:
//   Implements CreateTaskRemoteDataSource using ApiClient to call the
//   create task endpoint and parse the response into TaskModel.
//
// Class:
//   CreateTaskRemoteDataSourceImpl
//
// Author: Ashwanth V Praveen
// ============================================================================

import 'package:task_flow/core/network/api_client.dart';
import 'package:task_flow/core/network/api_endpoints.dart';
import 'package:task_flow/features/create_task/data/datasources/create_task_remote_data_source.dart';
import 'package:task_flow/features/create_task/data/models/create_task_request_model.dart';
import 'package:task_flow/features/tasks_home/data/models/task_model.dart';

class CreateTaskRemoteDataSourceImpl implements CreateTaskRemoteDataSource {
  const CreateTaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TaskModel> createTask(CreateTaskRequestModel request) async {
    final Map<String, dynamic> response = await _apiClient.post(
      ApiEndpoints.tasks,
      data: request.toJson(),
    );
    return TaskModel.fromJson(response);
  }
}
