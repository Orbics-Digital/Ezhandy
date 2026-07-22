import 'package:ezhandy_user/module/core/all_services/controller/provider_services_controller.dart';
import 'package:ezhandy_user/module/core/all_services/model/past_work_booking_model.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class PastWork extends StatefulWidget {
  final String? serviceId;

  PastWork({this.serviceId, super.key});

  @override
  State<PastWork> createState() => _PastWorkState();
}

class _PastWorkState extends State<PastWork> {
  final ProviderServicesController _controller = ProviderServicesController.i;

  String? get _serviceId => widget.serviceId?.trim();

  @override
  void initState() {
    super.initState();
    final serviceId = _serviceId;
    if (serviceId != null && serviceId.isNotEmpty) {
      _controller.fetchPastWorkByService(serviceId);
    }
  }

  @override
  void dispose() {
    _controller.clearPastWorkBookings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: Get.back,
      title: AppStrings.pastWork,
      // actionWidget: actionWidget(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.padding12,
        ),
        child: Obx(() {
          final serviceId = _serviceId;
          if (serviceId == null || serviceId.isEmpty) {
            return const Center(
              child: EmptyMessage(message: AppStrings.noServicesFound),
            );
          }

          if (_controller.isPastWorkLoading.value &&
              _controller.pastWorkBookings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          final bookings = _controller.pastWorkBookings;

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => _controller.refreshPastWorkByService(serviceId),
            child: bookings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 0.4.sh),
                      const Center(
                        child: EmptyMessage(
                          message: AppStrings.noPastWorkFound,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10.h, bottom: 25.h),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return singleQuestionWidget(booking: bookings[index]);
                    },
                    separatorBuilder: (context, index) => 10.verticalSpace,
                  ),
          );
        }),
      ),
    );
  }

  // GestureDetector actionWidget() {
  //   return GestureDetector(
  //     onTap: () {
  //       AppNavigation.navigateTo(
  //         context,
  //         AppRoutes.addEditPastWorkScreenRoute,
  //         arguments: PastWorkRoutingArgument(type: AddEditType.add.name),
  //       );
  //     },
  //     child: Container(
  //       height: 40.h,
  //       width: 40.w,
  //       margin: EdgeInsets.all(10.sp),
  //       decoration: const BoxDecoration(
  //         color: AppColors.orange,
  //         shape: BoxShape.circle,
  //       ),
  //       child: const Icon(Icons.add, color: AppColors.white),
  //     ),
  //   );
  // }

  Widget singleQuestionWidget({required PastWorkBookingModel booking}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        10.verticalSpace,
        CustomText(
          text: booking.displayTitle,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        5.verticalSpace,
        CustomText(
          text: booking.displayBookingDate,
          fontSize: 12.sp,
          color: AppColors.greyLight,
        ),
        10.verticalSpace,
        CustomText(text: booking.displayDetail),
        ...workDocumentsSection(booking),
      ],
    );
  }

  List<Widget> workDocumentsSection(PastWorkBookingModel booking) {
    final beforeImages = booking.workDocuments.before
        .where((item) => item.hasImage)
        .toList();
    final afterImages = booking.workDocuments.after
        .where((item) => item.hasImage)
        .toList();

    if (beforeImages.isEmpty && afterImages.isEmpty) {
      return const [];
    }

    return [
      10.verticalSpace,
      if (beforeImages.isNotEmpty) ...[
        CustomText(
          text: AppStrings.beforeWork,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        8.verticalSpace,
        imageListWidget(beforeImages),
      ],
      if (afterImages.isNotEmpty) ...[
        if (beforeImages.isNotEmpty) 12.verticalSpace,
        CustomText(
          text: AppStrings.afterWork,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        8.verticalSpace,
        imageListWidget(afterImages),
      ],
    ];
  }

  Widget imageListWidget(List<WorkDocumentItemModel> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5 / 1.5,
      ),
      itemBuilder: (context, index) {
        final imagePath = images[index].displayImagePath;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.network(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.greyBorder,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.greyLight,
              ),
            ),
          ),
        );
      },
    );
  }
}
