import 'notification_model.dart';
import 'pagination_model.dart';
import 'status_model.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  ApiResponse({required this.success, this.data, this.message, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'],
      message: json['message'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'],
    );
  }
}

class NotificationsResponse {
  final bool success;
  final List<NotificationModel> notifications;
  final PaginationModel pagination;
  final String? message;
  final ApiError? error;

  NotificationsResponse({
    required this.success,
    required this.notifications,
    required this.pagination,
    this.message,
    this.error,
  });
}

class SosResponse {
  final int id;
  final String title;
  final bool isSos;
  final bool isHighPriority;
  final StatusModel status;
  final DateTime createdAt;

  SosResponse({
    required this.id,
    required this.title,
    required this.isSos,
    required this.isHighPriority,
    required this.status,
    required this.createdAt,
  });

  factory SosResponse.fromJson(Map<String, dynamic> json) {
    return SosResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      isSos: json['is_sos'] as bool? ?? true,
      isHighPriority: json['is_high_priority'] as bool? ?? true,
      status: StatusModel(
        id: json['status_id'] as int? ?? 1,
        name: 'open',
        displayName: 'Açık',
        colorHex: '#F59E0B',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
