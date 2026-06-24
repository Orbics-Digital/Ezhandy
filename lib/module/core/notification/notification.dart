import 'package:ezhandy_user/module/core/notification/controller/notification_controller.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Slideable/slideable.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    _controller.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        title: AppStrings.notifications,
        appBarheight: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
          child: Column(
            children: [
              // CustomText(
              //     text: AppStrings.notifications,
              //     fontFamily: AppStrings.montserrat,
              //     color: AppColors.blueDark,
              //     fontSize: 20.sp,
              //     fontWeight: FontWeight.bold),
              // 20.verticalSpace,
              filterRowWidget(),
              Expanded(
                child: Obx(
                  () {
                    final items = _controller.filteredNotifications;
                    if (!_controller.isLoading.value && items.isEmpty) {
                      return const EmptyMessage(
                        message: AppStrings.noNotificationsFound,
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return SlidableWidget(
                          child: GestureDetector(
                            onTap: () => _controller.markAsRead(item),
                            child: notificationWidget(
                              image: AssetPath.infoIcon,
                              title: item.title ?? '',
                              description: item.description ?? '',
                              date: item.createdAt ?? DateTime.now(),
                              isRead: item.isRead,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return 20.verticalSpace;
                      },
                    );
                  },
                ),
              ),
              20.verticalSpace,
            ],
          ),
        ));
  }

  Widget notificationWidget({
    image,
    title,
    description,
    date,
    bool isRead = true,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white, // 👈 Make the card white
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orange,
            ),
            child: Image.asset(
              image,
              width: 14.w,
              height: 14.h,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontWeight: FontWeight.w600,
                ),
                4.verticalSpace,
                CustomText(
                  text: description,
                ),
                4.verticalSpace,
                Text(
                  DateFormat("dd MMM yyyy - HH:mm a").format(date),
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          if (!isRead) ...[
            SizedBox(width: 8.w),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Row filterRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CustomText(text: AppStrings.showing), filterDropDown()],
    );
  }

  Widget filterDropDown() {
    return Obx(
      () => CustomDropDown2(
        width: 110.w,
        dropDownWidth: 150.w,
        dropDownData: NotificationController.filterOptions,
        borderColor: AppColors.transparent,
        hintText: AppStrings.all,
        dropdownValue: _controller.selectedFilter.value,
        dropdownListColor: AppColors.white,
        hintTextColor: AppColors.black,
        onChanged: (value) {
          _controller.setFilter(value.toString());
        },
      ),
    );
  }
}
