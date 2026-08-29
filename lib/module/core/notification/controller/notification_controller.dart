import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/module/core/notification/data/notification_repository.dart';
import 'package:ezhandy_user/module/core/notification/model/notification_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
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

  /// Marks read, then navigates by notification [type].
  Future<void> onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    await markAsRead(notification);

    if (!context.mounted) return;

    final typeRaw = notification.type?.toString().trim() ?? '';
    final type = typeRaw.toUpperCase();

    if (type.contains('BOOKING')) {
      final bookingId = _bookingIdFromNotification(notification);
      if (bookingId == null || bookingId <= 0) return;

      AppNavigation.navigateTo(
        context,
        AppRoutes.bookingScreenRoute,
        arguments: BookingRoutingArgument(
          Status: '',
          bookingId: bookingId,
        ),
      );
      return;
    }

    // Exact ask-pro new request → requests list.
    if (typeRaw.toLowerCase() == 'ask_pro_new_request') {
      AppNavigation.navigateTo(context, AppRoutes.proRequestScreenRoute);
      return;
    }

    if (type.contains('CHAT')) {
      final chatId = _chatIdFromNotification(notification);
      if (chatId == null || chatId.isEmpty) return;

      AppNavigation.navigateTo(
        context,
        AppRoutes.chatScreenRoute,
        arguments: ChatRoutingArgument(
          isBooking: false,
          chatId: chatId,
        ),
      );
      return;
    }

    if (type.contains('COMMUNITY')) {
      // Provider has Community as main-menu tab (index 3), not a My Posts screen.
      if (Get.isRegistered<HomeController>()) {
        HomeController.i.selectedTab.value = 3;
      }
      AppNavigation.navigatorPop(context);
    }
  }

  int? _bookingIdFromNotification(NotificationModel notification) {
    final data = notification.data;
    final raw = data?['bookingId'];
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  String? _chatIdFromNotification(NotificationModel notification) {
    final raw = notification.data?['chatId'];
    final id = raw?.toString().trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }
}
