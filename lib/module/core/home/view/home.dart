import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/module/core/main_menu/main_menu_provider.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_shadows.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/switch/animated_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/image_with_text_container.dart';
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isBecomeAPro = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    return Expanded(
      child: Column(
        children: [
          // 10.verticalSpace,
          appbarWidget(greeting, context),
          20.verticalSpace,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomContainer(
                      // boxShadow: AppShadows.shadow2,
                      child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text: "Become A Pro:"),
                      5.horizontalSpace,
                      CustomText(
                        text: isBecomeAPro ? "Active" : "In-Active",
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      Spacer(),
                      AnimatedSwitch(
                          isSwitched: isBecomeAPro,
                          onCallBack: (r) {
                            setState(() {
                              isBecomeAPro = r;
                            });
                            if (isBecomeAPro) {
                              AppDialogs.showSuccessDialog(
                                context,
                                description: AppStrings.nowYouArePro,
                                title: AppStrings.youreOfficiallyAPro,
                                btnTxt1: AppStrings.ok,
                                onTap1: () {
                                  AppNavigation.navigatorPopUntil(
                                      context, AppRoutes.mainMenuScreenRoute);
                                },
                              );
                            }
                          }),
                    ],
                  )),
                  20.verticalSpace,
                  Obx(() {
                    final isQuickProvider =
                        AuthController.i.user.value?.isQuickProvider ?? false;
                    return CustomContainer(
                      child: Row(
                        children: [
                          CustomText(text: "Urgent Services"),
                          Spacer(),
                          AnimatedSwitch(
                            key: ValueKey(isQuickProvider),
                            isSwitched: isQuickProvider,
                            onCallBack: (value) {
                              AuthController.i.updateIsQuickProvider(value);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  20.verticalSpace,
                  bookingContainerWidget(),
                  20.verticalSpace,
                  bookingContainerWidget(),
                  20.verticalSpace,
                  CustomButton(
                    text: AppStrings.viewAll,
                    onclick: () {
                      HomeController.i.selectedTab.value = 2;
                    },
                  ),
                  20.verticalSpace,
                  ourStoryWidget(),
                  20.verticalSpace,
                  earnWithUsWidget(),
                  25.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  CustomContainer bookingContainerWidget() {
    return CustomContainer(
        onTap: () {
          HomeController.i.jobStatus.value = AppStrings.approved;
          AppNavigation.navigateTo(context, AppRoutes.bookingScreenRoute,
              arguments: BookingRoutingArgument(
                Status: AppStrings.approved,
              ));
        },
        // boxShadow: AppShadows.shadow1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                    text: AppStrings.dummyDate,
                    color: AppColors.greyLight,
                    fontSize: 12.sp),
                CustomText(
                  text: "Status: ${AppStrings.approved}",
                  color: AppColors.greyLight,
                  fontSize: 12.sp,
                ),
              ],
            ),
            5.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Booking ID: #1234567",
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: "Visit Charges: \$10",
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ));
  }

  Row appbarWidget(String greeting, BuildContext context) {
    return Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              globalkey.currentState!.openDrawer();
            },
            child: Image.asset(
              AssetPath.menuIcon,
              alignment: Alignment.centerLeft,
              scale: 4.sp,
              color: AppColors.black,
            ),
          ),
          10.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "$greeting 🔥", fontSize: 14.sp),
              Obx(
                () => CustomText(
                  text: AuthController.i.userDisplayName,
                  fontFamily: AppStrings.montserrat,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Spacer(),
          const NotificationBadgeIcon(),
        ]);
  }

  Widget earnWithUsWidget() {
    return Container(
      color: AppColors.musturd,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 25.w),
              child: Column(children: [
                CustomText(
                  text: AppStrings.marketPlace,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: AppStrings.lorem5,
                  color: AppColors.grey,
                  maxLines: 4,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: AppPadding.padding18, top: AppPadding.padding10),
                  child: CustomButton(
                      onclick: () {
                        AppNavigation.navigateTo(
                            context, AppRoutes.marketPlaceScreenRoute);

                        ;
                      },
                      height: 40.h,
                      borderRadius: 35.r,
                      text: AppStrings.clickHere),
                )
              ]),
            ),
          ),
          Image.asset(AssetPath.tab3Icon, width: 0.45.sw
              // height: 200.h,
              )
        ],
      ),
    );
  }

  Widget ourStoryWidget() {
    return Container(
      color: AppColors.musturd,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 25.w),
              child: Column(children: [
                CustomText(
                  text: AppStrings.ourStory,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                    text: AppStrings.lorem5, color: AppColors.grey, maxLines: 6)
              ]),
            ),
          ),
          Image.asset(AssetPath.tab1Icon, width: 0.45.sw
              // height: 200.h,
              )
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 17) return "Good Afternoon";
    if (hour >= 17 && hour < 21) return "Good Evening";
    return "Good Night";
  }
}
