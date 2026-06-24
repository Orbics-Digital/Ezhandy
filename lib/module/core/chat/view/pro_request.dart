import 'dart:developer';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ProRequest extends StatefulWidget {
  ProRequest({super.key});

  @override
  State<ProRequest> createState() => _ProRequestState();
}

class _ProRequestState extends State<ProRequest> {
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      // appBarheight: 50.h,
      title: AppStrings.proRequest,
      child: Column(
        children: [
          // 10.verticalSpace,
          // 10.verticalSpace,
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.padding14,
                  vertical: AppPadding.padding20),
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                // final item = notifications[index];
                return singleWidget(
                    ontap1: () {
                      // AppNavigation.navigatorPop(context);
                      AppDialogs.showSuccessDialog(
                        context,
                        description:
                            AppStrings.requestHasBeenAcceptedSuccessfully,
                        title: AppStrings.congratulation,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPop(context);

                          // AppNavigation.navigateToRemovingAll(
                          //     context, AppRoutes.userProfileScreenRoute);
                          AppNavigation.navigateTo(
                              context, AppRoutes.chatScreenRoute,
                              arguments: ChatRoutingArgument(isBooking: false));
                        },
                      );
                    },
                    ontap2: () {
                      AppDialogs.showSuccessDialog(
                        context,
                        description:
                            AppStrings.requestHasBeenRejectedSuccessfully,
                        title: AppStrings.congratulation,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPop(context);

                          AppNavigation.navigatorPopUntil(
                              context, AppRoutes.proRequestScreenRoute);
                        },
                      );
                    },
                    des: AppStrings.lorem1,
                    title: "You Have A New Job Request");
              },
              separatorBuilder: (context, index) {
                return 10.verticalSpace;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget singleWidget({ontap1, ontap2, title, des}) {
    return CustomContainer(
      child: Column(
        children: [
          CustomText(text: title, fontWeight: FontWeight.bold),
          CustomText(text: des),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                  child: CustomButton(
                text: AppStrings.accept,
                height: 40.h,
                onclick: ontap1,
              )),
              10.horizontalSpace,
              Expanded(
                  child: CustomButton(
                text: AppStrings.reject,
                height: 40.h,
                color: AppColors.black,
                onclick: ontap2,
              )),
            ],
          )
        ],
      ),
    );
  }
}
