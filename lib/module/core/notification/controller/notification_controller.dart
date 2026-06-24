import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/notification/data/notification_repository.dart';
import 'package:ezhandy_user/module/core/notification/model/notification_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  static NotificationController get i => Get.find<NotificationController>();

  final NotificationRepository _repository = NotificationRepository();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxString selectedFilter = AppStrings.all.obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  static const filterOptions = [
    AppStrings.all,
    AppStrings.read,
    AppStrings.unread,
  ];

  List<NotificationModel> get filteredNotifications {
    switch (selectedFilter.value) {
      case AppStrings.read:
        return notifications.where((item) => item.isRead).toList();
      case AppStrings.unread:
        return notifications.where((item) => !item.isRead).toList();
      default:
        return notifications.toList();
    }
  }

  void setFilter(String value) => selectedFilter.value = value;

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount.value = await _repository.getUnreadCount();
    } on DioException catch (_) {
      unreadCount.value = 0;
    } catch (_) {
      unreadCount.value = 0;
    }
  }

  void clearUnreadCount() => unreadCount.value = 0;

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead || notification.id == null) return;

    final index =
        notifications.indexWhere((item) => item.id == notification.id);
    if (index == -1) return;

    try {
      await _repository.markAsRead(notification.id!);
      notifications[index] = notification.copyWith(isRead: true);
      await fetchUnreadCount();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchNotifications() async {
    if (isLoading.value) return;

    isLoading.value = true;
    AppLoader.show();
    try {
      notifications.assignAll(await _repository.getNotifications());
      await fetchUnreadCount();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isLoading.value = false;
      AppLoader.hide();
    }
  }
}
