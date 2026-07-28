import 'dart:io';

import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/utils.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:image_picker/image_picker.dart';

class UploadPictureAfterWork extends StatefulWidget {
  UploadPictureAfterWork({super.key});

  @override
  State<UploadPictureAfterWork> createState() =>
      _UploadPictureAfterWorkState();
}

class _UploadPictureAfterWorkState extends State<UploadPictureAfterWork> {
  List<File?> imageList = List<File?>.filled(8, null);

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.uploadPictureAfterWork,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            15.verticalSpace,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imageList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5 / 1.5,
              ),
              itemBuilder: (context, index) {
                return imageContainerWidget(
                  ontap: () {
                    Utils.openImagePicker(
                      action: false,
                      source: ImageSource.camera,
                      context: context,
                      setFile: (file) => _setFile(file, index),
                    );
                  },
                  imagePath: imageList[index],
                );
              },
            ),
            const SizedBox(height: 20),
            Obx(
              () => CustomButton(
                isLoading:
                    BookingsController.i.isUpdatingBookingStatus.value,
                text: "End Job",
                onclick: () async {
                  final bookingId =
                      BookingsController.i.bookingDetail.value?.id;
                  if (bookingId == null) {
                    AppDialogs.showToast(message: 'Booking not found');
                    return;
                  }

                  final images = imageList
                      .whereType<File>()
                      .toList(growable: false);

                  final success = await BookingsController.i
                      .submitAfterWorkAndEndJob(
                    bookingId: bookingId,
                    images: images,
                  );

                  if (!context.mounted || !success) return;

                  AppDialogs.showSuccessDialog(
                    context,
                    description: "Job ended successfully",
                    title: AppStrings.congratulation,
                    btnTxt1: AppStrings.ok,
                    onTap1: () {
                      AppNavigation.navigatorPopUntil(
                        context,
                        AppRoutes.bookingScreenRoute,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFile(File? file, int index) {
    setState(() {
      imageList[index] = file;
    });
  }

  CustomContainer imageContainerWidget({ontap, imagePath}) {
    return CustomContainer(
      onTap: ontap,
      isPadding: false,
      radius: 0,
      borderColor: AppColors.transparent,
      bgColor: AppColors.uploadColor,
      child: imagePath == null
          ? Center(
              child: CircleAvatar(
                radius: 15.r,
                backgroundColor: AppColors.orange,
                child: Icon(Icons.add, color: AppColors.white, size: 20.r),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.file(imagePath, fit: BoxFit.cover),
            ),
    );
  }
}
