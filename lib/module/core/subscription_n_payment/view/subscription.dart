import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({
    super.key,
  });

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedIndex = 0;
  final List<String> _packages = [
    "Monthly",
    "Yearly",
    "Weekly",
  ];
  final List<int> _prices = [25, 30, 35];
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      // is_registration: widget.isRegistration,
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.subscriptionPlan,

      child: Column(
        children: [
          // 10.verticalSpace,
          // listOfSubscriptionProgrameTextWidget(),
          10.verticalSpace,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.padding12,
            ),
            child: CustomText(text: AppStrings.lorem5),
          ),
          30.verticalSpace,
          subscriptionSlider(),
          // 20.verticalSpace,
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.padding12),
            child: btn_widget(context),
          ),
          25.verticalSpace
        ],
      ),
    );
  }

  Widget listOfSubscriptionProgrameTextWidget() {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppPadding.padding12, right: AppPadding.padding18),
      child: CustomText(
        text: AppStrings.listOfSubscriptionPrograme,
        // is_alignLeft: false,
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.blueDark,
      ),
    );
  }

  Widget btn_widget(BuildContext context) {
    return CustomButton(
      onclick: () {
        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.paymentSuccessfullyMade,
          title: AppStrings.paymentDone,
          btnTxt1: AppStrings.backToLogin,
          onTap1: () {
            AppNavigation.navigatorPopUntil(
                context, AppRoutes.loginScreenRoute);
          },
        );

        // if (widget.isFromAuth) {
        //   AppNavigation.navigateToRemovingAll(context, AppRoutes.commonSuccessScreenRoute,
        //       arguments: CommonSuccessScreenRoutingArgument(
        //           buttonText: AppStrings.home,
        //           mainText: AppStrings.subscribedSuccessful,
        //           onclick: () {
        //             HomeController.i.selectedTab.value = 0;
        //             AppNavigation.navigateToRemovingAll(Constants.navigatorKey.currentContext!, AppRoutes.sellerMainMenuScreenRoute);
        //           }));
        // } else {
        //   AppNavigation.navigateReplacementNamed(context, AppRoutes.commonSuccessScreenRoute,
        //       arguments: CommonSuccessScreenRoutingArgument(
        //           buttonText: AppStrings.home,
        //           mainText: AppStrings.subscribedSuccessful,
        //           onclick: () {
        //             if (AuthController.i.role.value == RoleType.committed.name) {
        //               HomeController.i.selectedTab.value = 1;
        //             } else {
        //               HomeController.i.selectedTab.value = 0;
        //             }
        //             if (AuthController.i.role.value == RoleType.single.name || AuthController.i.role.value == RoleType.committed.name) {
        //               AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
        //               // AppNavigation.navigatorPopUntil(Constants.navigatorKey.currentContext!, AppRoutes.userMainMenuScreenRoute);
        //             } else {
        //               AppNavigation.navigatorPopUntil(Constants.navigatorKey.currentContext!, AppRoutes.sellerMainMenuScreenRoute);
        //             }
        //           }));
        // }
      },
      // isAuth: false,
      text: AppStrings.buyNow,
    );
  }

  Widget subscriptionSlider() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _packages.length,
          options: CarouselOptions(
            height: 400.h,
            enlargeCenterPage: false, // 👈 disables the scaling
            autoPlay: false,
            enableInfiniteScroll: true,
            viewportFraction: 0.85, // optional: adjust spacing between cards
            onPageChanged: (index, reason) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              width: 343.w,
              decoration: BoxDecoration(
                color: _selectedIndex == index
                    ? AppColors.orange
                    : AppColors.black, // deep blue-purple
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _packages[index],
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                  10.verticalSpace,
                  Expanded(
                    child: SingleChildScrollView(
                      child: CustomText(
                        text:
                            "Lorem Ipsum is simply dummy text the printing and typesetting industry. "
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum is simply dummy text the printing and typesetting industry. "
                            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.\n\n"
                            "Lorem Ipsum is simply dummy text the printing and typesetting industry.",
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  CustomText(
                    text: "Price:  \$${_prices[index]}.00",
                    color: AppColors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            );
          },
        ),
        12.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _packages.asMap().entries.map((entry) {
            bool isActive = _selectedIndex == entry.key;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: isActive ? 24.w : 8.w,
              decoration: BoxDecoration(
                color: isActive ? AppColors.orange : AppColors.grey,
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
