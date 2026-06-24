import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/notification/model/notification_model.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.dio.get(ApiEndpoints.notifications);

    return ApiHelper.dataList(response.data)
        .map(NotificationModel.fromJson)
        .where((item) => !item.isDeleted)
        .toList();
  }

  Future<void> markAsRead(String id) async {
    final response =
        await _client.dio.patch(ApiEndpoints.notificationRead(id));

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to mark notification as read',
      );
    }
  }
}
