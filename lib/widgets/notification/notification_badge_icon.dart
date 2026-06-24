import 'package:ezhandy_user/module/core/notification/controller/notification_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final double width;
  final double height;

  const NotificationBadgeIcon({
    super.key,
    this.width = 20,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.i;

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          AppRoutes.notificationScreenRoute,
        );
        controller.fetchUnreadCount();
      },
      child: Obx(() {
        final count = controller.unreadCount.value;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              AssetPath.bellIcon,
              width: width.w,
              height: height.h,
            ),
            if (count > 0)
              Positioned(
                right: -8.w,
                top: -6.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: count > 9 ? 4.w : 5.w,
                    vertical: 2.h,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.h,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
