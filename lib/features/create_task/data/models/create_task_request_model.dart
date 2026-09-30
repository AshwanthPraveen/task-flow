// ============================================================================
// File: create_task_request_model.dart
// Created Date: 30-Sep-2026
// Title: CreateTaskRequestModel
// Description:
//   Request body model for POST /tasks. Only title is required by the API;
//   optional fields are left out of the JSON when null.
//
// Class:
//   CreateTaskRequestModel
//
// Author: Ashwanth V Praveen
// ============================================================================

class CreateTaskRequestModel {
  const CreateTaskRequestModel({
    required this.title,
    this.description,
    this.status,
    this.clientId,
    this.localId,
  });

  final String title;
  final String? description;
  final String? status;
  final String? clientId;
  final String? localId;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (clientId != null) 'client_id': clientId,
      if (localId != null) 'local_id': localId,
    };
  }
}
