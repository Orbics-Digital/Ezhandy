import 'dart:io';

import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
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

class UploadPictureBeforeWork extends StatefulWidget {
  UploadPictureBeforeWork({super.key});

  @override
  State<UploadPictureBeforeWork> createState() =>
      _UploadPictureBeforeWorkState();
}

class _UploadPictureBeforeWorkState extends State<UploadPictureBeforeWork> {
  List<File?> imageList = List<File?>.filled(8, null);

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.uploadPictureBeforeWork,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            15.verticalSpace,

            // ✅ GRIDVIEW WITH 8 ITEMS
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: imageList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5 / 1.5, // square cells
              ),
              itemBuilder: (context, index) {
                return imageContainerWidget(
                    ontap: () {
                      // if (imageList[index] == null)
                      Utils.openImagePicker(
                        action: false,
                        source: ImageSource.camera,
                        context: context,
                        setFile: (file) => _setFile(file, index), // ✅ CORRECT
                      );
                    },
                    imagePath: imageList[index]);
              },
            ),

            const SizedBox(height: 20),

            // ✅ YOUR BUTTON
            CustomButton(
              text: "Start Job",
              onclick: () {
                HomeController.i.jobStatus.value = AppStrings.started;
                AppNavigation.navigatorPopUntil(
                    context, AppRoutes.bookingScreenRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  _setFile(File? file, index) {
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
        // DON'T do height: 10.h, width: 10.w here
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
              ));
  }
}
