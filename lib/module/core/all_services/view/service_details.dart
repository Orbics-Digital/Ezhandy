import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/profile_widget/profile_picture_widget.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ServiceDetails extends StatefulWidget {
  String? type;
  ServiceDetails({this.type, super.key});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  bool isFav = false;
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: AppStrings.serviceDetails,
      appBarheight: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // profileRowWidget(),
                    // 15.verticalSpace,
                    singleContainer(),
                    // 10.verticalSpace,
                    CustomText(
                      text: AppStrings.dummylorem,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                    CustomText(
                      text: AppStrings.lorem5 + AppStrings.lorem5,
                    ),
                    15.verticalSpace,

                    CustomContainer(
                        isPadding: false, child: chargesDetailsWidget()),
                    15.verticalSpace,
                    if (widget.type == ServiceType.instant.name) ...[
                      CustomContainer(
                          isPadding: false,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppPadding.padding12),
                                child: CustomText(
                                    text: "Quick Service",
                                    // color: AppColors.blueDark,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Divider(color: AppColors.blueDark),
                              quickChargesDetailsWidget(),
                              // reScheduleWidget(),
                            ],
                          )),
                      15.verticalSpace,
                    ],

                    10.verticalSpace,
                  ],
                ),
              ),
            ),
            CustomButton(
              text: AppStrings.pastWork,
              onclick: () {
                AppNavigation.navigateTo(context, AppRoutes.pastworkScreenRoute);
            
              },
            ),
            10.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    color: AppColors.black,
                    text: AppStrings.remove,
                    onclick: () {
                      AppDialogs.showSuccessDialog(context,
                          description:
                              AppStrings.areYouSureYouWantToDeleteThisService,
                          // title: AppStrings.deleteAccount,
                          image: AssetPath.deleteWithCircleIcon,
                          isDoneShow: false,
                          btnTxt1: AppStrings.yes,
                          onTap1: () {
                            AppNavigation.navigatorPop(context);
                            AppDialogs.showSuccessDialog(
                              context,
                              description: AppStrings.serviceDeleteSuccessfully,
                              title: AppStrings.congratulation,
                              btnTxt1: AppStrings.ok,
                              onTap1: () {
                                AppNavigation.navigatorPopUntil(context,
                                    AppRoutes.listOfServicesScreenRoute);
                              },
                            );
                          },
                          btnTxt2: AppStrings.no,
                          onTap2: () {
                            AppNavigation.navigatorPop(context);
                          });
                    },
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: CustomButton(
                    text: AppStrings.edit,
                    onclick: () {
                      AppNavigation.navigateReplacementNamed(
                          context, AppRoutes.addEditServiceScreenRoute,
                          arguments: ServiceRoutingArgument(
                              serviceName: "Edit",
                              type: AddEditType.edit.name));
                    },
                  ),
                )
              ],
            ),
            25.verticalSpace,
          ],
        ),
      ),
    );
  }

  Padding chargesDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.visitCharges}:", secondText: "\$10"),
          TwoTextRow(
              firstText: "${AppStrings.visitChargesCommission}:",
              secondText: "\$10"),
          TwoTextRow(
              firstText: "${AppStrings.hourlyRate}:", secondText: "\$10"),
          TwoTextRow(
              firstText: "${AppStrings.hourlyRateCommission}:",
              secondText: "\$10"),
          10.verticalSpace,
        ],
      ),
    );
  }

  Padding quickChargesDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(firstText: "Visiting Amount:", secondText: "\$10"),
          TwoTextRow(firstText: "Per Hour Amount:", secondText: "\$10"),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget singleContainer() {
    return Container(
      height: 250.h,
      width: 1.sw, // fixed width for horizontal scrolling
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          image: const DecorationImage(
              fit: BoxFit.cover, image: AssetImage(AssetPath.tempCleaningImage)

              // NetworkImage(
              //     "https://www.pristinehome.com.au/wp-content/uploads/2018/07/How-to-Choose-the-Best-House-Cleaning-Service.jpg")
              )),
    );
  }
}
