import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
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

class WorkDocuments extends StatefulWidget {
  final String? serviceName;

  WorkDocuments({
    this.serviceName,
    super.key,
  });

  @override
  State<WorkDocuments> createState() => _WorkDocumentsState();
}

class _WorkDocumentsState extends State<WorkDocuments> {
  BookingWorkDocumentsModel get _workDocuments =>
      BookingsController.i.bookingDetail.value?.workDocuments ??
      const BookingWorkDocumentsModel();

  String get _serviceName {
    final passedName = widget.serviceName?.trim();
    if (passedName != null && passedName.isNotEmpty) return passedName;

    return BookingsController.i.bookingDetail.value?.service?.displayTitle ??
        '-';
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.workDocuments,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.padding12,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppStrings.serviceName,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              8.verticalSpace,
              CustomText(
                text: _serviceName,
                fontSize: 16.sp,
              ),
              20.verticalSpace,
              CustomText(
                text: AppStrings.beforeImage,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              5.verticalSpace,
              imageListWidget(_workDocuments.before),
              10.verticalSpace,
              CustomText(
                text: AppStrings.afterImage,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              5.verticalSpace,
              imageListWidget(_workDocuments.after),
              25.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget imageListWidget(List<WorkDocumentItemModel> documents) {
    if (documents.isEmpty) {
      return const EmptyMessage(
        message: AppStrings.noResultsFound,
      );
    }

    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];

          return ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              document.displayImagePath,
              width: .45.sw,
              height: 120.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: .45.sw,
                  height: 120.h,
                  color: AppColors.grey.withValues(alpha: 0.2),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.grey,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  width: .45.sw,
                  height: 120.h,
                  color: AppColors.grey.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.orange,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return 10.horizontalSpace;
        },
      ),
    );
  }
}
