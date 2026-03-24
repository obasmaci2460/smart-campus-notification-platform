import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../models/pagination_model.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://3080-194-27-48-68.ngrok-free.app/api/v1';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final retryResponse = await _retry(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.data['success'] == true) {
        final tokens = response.data['data'];
        await StorageService.saveTokens(
          tokens['access_token'],
          tokens['refresh_token'],
        );
        return true;
      }
      return false;
    } catch (e) {
      await StorageService.clearAll();
      return false;
    }
  }

  static Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await StorageService.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
    String platform = 'android',
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'platform': platform,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        data:
            response.data['data'] != null
                ? LoginResponse.fromJson(response.data['data'])
                : null,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<LoginResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int departmentId,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'department_id': departmentId,
          if (phone != null) 'phone': phone,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        data:
            response.data['data'] != null
                ? LoginResponse.fromJson(response.data['data'])
                : null,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse> getNotificationPreferences() async {
    try {
      final response = await _dio.get('/users/me/notification-preferences');
      return ApiResponse(
        success: response.data['success'] ?? false,
        data: response.data['data'],
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse> updateNotificationPreferences({
    required Map<String, bool> preferences,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/me/notification-preferences',
        data: preferences,
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        data: response.data['data'],
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse> getFollowingUpdatesCount() async {
    try {
      final response = await _dio.get(
        '/notifications/me/following/updates-count',
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        data: response.data['data'],
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>>
  getDepartments() async {
    try {
      final response = await _dio.get('/departments');

      return ApiResponse(
        success: response.data['success'] ?? false,
        data:
            response.data['data'] != null
                ? List<Map<String, dynamic>>.from(response.data['data'])
                : null,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<NotificationsResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    int? statusId,
    String? timeFilter,
    String? search,
    String sort = 'newest',
    bool? isSos,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort': sort,
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (statusId != null) queryParams['status_id'] = statusId;
      if (timeFilter != null && timeFilter != 'all') {
        queryParams['time_filter'] = timeFilter;
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isSos != null) queryParams['is_sos'] = isSos;

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final dataObj = response.data['data'] as Map<String, dynamic>;
        final dataList = dataObj['notifications'] as List<dynamic>;
        final notifications =
            dataList
                .map(
                  (json) => NotificationModel.fromApiJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();

        final paginationJson =
            response.data['pagination'] as Map<String, dynamic>?;
        final pagination =
            paginationJson != null
                ? PaginationModel.fromJson(paginationJson)
                : PaginationModel(
                  currentPage: page,
                  perPage: perPage,
                  totalPages: 1,
                  totalItems: notifications.length,
                );

        return NotificationsResponse(
          success: true,
          notifications: notifications,
          pagination: pagination,
          message: response.data['message'] as String?,
        );
      }

      return NotificationsResponse(
        success: false,
        notifications: [],
        pagination: PaginationModel(
          currentPage: 1,
          perPage: perPage,
          totalPages: 0,
          totalItems: 0,
        ),
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      final errorResponse = _handleError<void>(e);
      return NotificationsResponse(
        success: false,
        notifications: [],
        pagination: PaginationModel(
          currentPage: 1,
          perPage: perPage,
          totalPages: 0,
          totalItems: 0,
        ),
        error: errorResponse.error,
        message: errorResponse.message,
      );
    }
  }

  static Future<ApiResponse<List<NotificationModel>>> getNearbyNotifications({
    required double latitude,
    required double longitude,
    int radius = 1000,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final list = data['notifications'] as List;
        final notifications =
            list.map((json) {
              return NotificationModel.fromNearbyJson(
                json as Map<String, dynamic>,
              );
            }).toList();

        return ApiResponse(
          success: true,
          data: notifications,
          message: response.data['message'],
        );
      }
      return ApiResponse(success: false, message: response.data['message']);
    } on DioException catch (e) {
      final errorResponse = _handleError<List<NotificationModel>>(e);
      return ApiResponse(
        success: false,
        data: [],
        error: errorResponse.error,
        message: errorResponse.message,
      );
    }
  }

  static Future<ApiResponse<SosResponse>> createSOS({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final response = await _dio.post(
        '/notifications/sos',
        data: {
          'title': 'ACİL DURUM / SOS',
          'description':
              'Kullanıcı acil durum butonunu kullanarak yardım çağrısında bulundu.',
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        data:
            response.data['data'] != null
                ? SosResponse.fromJson(response.data['data'])
                : null,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> markFollowingAsViewed() async {
    try {
      final response = await _dio.post(
        '/notifications/me/following/mark-viewed',
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      if (e.response!.statusCode == 422 &&
          data is Map &&
          data['detail'] != null) {
        final detail = data['detail'];
        String message = 'Veri doğrulama hatası';
        if (detail is List) {
          message = detail
              .map(
                (d) =>
                    "${d['loc'] is List ? d['loc'].last : 'alan'}: ${d['msg']}",
              )
              .join('\n');
        } else {
          message = detail.toString();
        }
        return ApiResponse(
          success: false,
          error: ApiError(code: 'VALIDATION_ERROR', message: message),
          message: message,
        );
      }

      if (e.response!.statusCode == 429) {
        String message = 'Günlük işlem limitine ulaşıldı.';

        if (data is Map) {
          if (data['message'] != null) {
            message = data['message'];
          } else if (data['detail'] is Map &&
              data['detail']['message'] != null) {
            message = data['detail']['message'];
          }
        }

        return ApiResponse(
          success: false,
          error: ApiError(code: 'RATE_LIMIT', message: message),
          message: message,
        );
      }

      if (data is Map) {
        return ApiResponse(
          success: false,
          error:
              data['error'] != null ? ApiError.fromJson(data['error']) : null,
          message: data['message'] as String?,
        );
      } else {
        return ApiResponse(success: false, message: data.toString());
      }
    }

    return ApiResponse(
      success: false,
      error: ApiError(
        code: 'NETWORK_ERROR',
        message: 'Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.',
      ),
    );
  }

  static Future<ApiResponse<NotificationModel>> getNotificationDetail(
    int id,
  ) async {
    try {
      final response = await _dio.get('/notifications/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        final notification = NotificationModel.fromApiJson(
          response.data['data'] as Map<String, dynamic>,
        );
        return ApiResponse(
          success: true,
          data: notification,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(success: false, message: response.data['message']);
      }
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> followNotification(int id) async {
    try {
      final response = await _dio.post('/notifications/$id/follow');
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> unfollowNotification(int id) async {
    try {
      final response = await _dio.delete('/notifications/$id/follow');
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> createNotification({
    required int categoryId,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    List<String> imagePaths = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'category_id': categoryId,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });

      for (var path in imagePaths) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(path)),
        );
      }

      final response = await _dio.post('/notifications', data: formData);
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> updateNotification(
    int notificationId, {
    String? title,
    String? description,
  }) async {
    try {
      final response = await _dio.patch(
        '/notifications/$notificationId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
        },
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> updateNotificationStatus(
    int notificationId,
    int statusId,
  ) async {
    try {
      final response = await _dio.patch(
        '/notifications/$notificationId/status',
        data: {'status_id': statusId},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> addAdminNote(
    int notificationId,
    String noteContent,
  ) async {
    try {
      final response = await _dio.post(
        '/notifications/$notificationId/notes',
        data: {'note_content': noteContent},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
        data: response.data['data'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;

      final response = await _dio.patch('/users/profile', data: data);
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
        data: response.data['data'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<List<NotificationModel>>>
  getFollowedNotifications() async {
    try {
      final response = await _dio.get('/notifications/me/following');

      if (response.data['success'] == true) {
        final List<dynamic> notificationsJson = response.data['data'] ?? [];
        final notifications =
            notificationsJson
                .map((json) => NotificationModel.fromApiJson(json))
                .toList();

        return ApiResponse(
          success: true,
          message: response.data['message'],
          data: notifications,
        );
      }

      return ApiResponse(
        success: false,
        message:
            response.data['message'] ?? 'Failed to load followed notifications',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  static Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
