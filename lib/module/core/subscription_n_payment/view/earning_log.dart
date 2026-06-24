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
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class EarningsLog extends StatefulWidget {
  EarningsLog({super.key});

  @override
  _EarningsLogState createState() => _EarningsLogState();
}

class _EarningsLogState extends State<EarningsLog> {
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      // is_registration: widget.isRegistration,
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.earningLog,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            CustomContainer(
              bgColor: AppColors.orange,
              borderColor: AppColors.transparent,
              radius: 5.r,
              child: CustomText(
                  text: "${AppStrings.totalEarnings} \$100",
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 16.sp),
            ),
            10.verticalSpace,

            Expanded(
              child: ListView.separated(
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 15,
                padding: EdgeInsets.only(bottom: AppPadding.padding18),
                itemBuilder: (BuildContext ctxt, int index) {
                  return pastSubscriptionWidget();
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.verticalSpace;
                },
              ),
            ),
            // 25.verticalSpace
          ],
        ),
      ),
    );
  }

  Widget pastSubscriptionWidget() {
    return CustomContainer(
      child: Column(
        children: [
          10.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.username}:", secondText: "ABC User"),
          10.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.date}:",
              secondText: AppStrings.dummyDate),
          10.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.amount}:",
              secondText: AppStrings.dummyAmount),
          10.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.earningType}:", secondText: "Chat"),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget cancelBtnWidget(BuildContext context) {
    return CustomButton(
      onclick: () {
        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.cancelSubscriptionText,
          title: AppStrings.cancelSubscription,
          image: AssetPath.alertIcon,
          isDoneShow: false,
          btnTxt1: AppStrings.no,
          onTap1: () {
            AppNavigation.navigatorPop(context);
          },
          btnTxt2: AppStrings.yes,
          onTap2: () {
            AppNavigation.navigatorPopUntil(
                context, AppRoutes.mainMenuScreenRoute);
          },
        );
      },
      text: AppStrings.cancelSubscription,
    );
  }

  Widget logsBtnWidget(BuildContext context) {
    return CustomButton(
      onclick: () {
        // AppDialogs.showSuccessDialog(
        //   context,
        //   description: AppStrings.paymentSuccessful,
        //   title: AppStrings.thankYou,
        //   btnTxt1: AppStrings.done,
        //   onTap1: () {
        //     AppNavigation.navigatorPopUntil(
        //         context, AppRoutes.mainMenuScreenRoute);
        //   },
        // );
      },
      color: AppColors.blueDark,
      text: AppStrings.subscriptionLogs,
    );
  }

  Widget upgradeBtnWidget(BuildContext context) {
    return CustomButton(
      onclick: () {
        AppNavigation.navigateTo(context, AppRoutes.subscriptionScreenRoute);
        // AppDialogs.showSuccessDialog(
        //   context,
        //   description: AppStrings.paymentSuccessful,
        //   title: AppStrings.thankYou,
        //   btnTxt1: AppStrings.done,
        //   onTap1: () {
        //     AppNavigation.navigatorPopUntil(
        //         context, AppRoutes.mainMenuScreenRoute);
        //   },
        // );
      },
      text: AppStrings.upgradeYourPlan,
    );
  }
}
