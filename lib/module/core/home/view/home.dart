import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/module/core/main_menu/main_menu_provider.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
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
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController _controller = HomeController.i;

  @override
  void initState() {
    super.initState();
    _controller.fetchAskProStatus();
    BookingsController.i.fetchProviderBookings();
  }

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
                  Obx(() {
                    final askProActive = _controller.askProActive.value;
                    final isLoading = _controller.isAskProStatusLoading.value ||
                        _controller.isAskProToggleLoading.value;

                    return CustomContainer(
                      child: Row(
                        children: [
                          CustomText(text: "Become A Pro:"),
                          5.horizontalSpace,
                          CustomText(
                            text: askProActive ? "Active" : "In-Active",
                            color:
                                askProActive ? AppColors.green : AppColors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          const Spacer(),
                          IgnorePointer(
                            ignoring: isLoading,
                            child: AnimatedSwitch(
                              key: ValueKey(askProActive),
                              isSwitched: askProActive,
                              onCallBack: (value) async {
                                final wasActive = _controller.askProActive.value;
                                final success =
                                    await _controller.toggleAskProActive(value);
                                if (!success || !context.mounted) return;

                                if (!wasActive &&
                                    _controller.askProActive.value) {
                                  AppDialogs.showSuccessDialog(
                                    context,
                                    description: AppStrings.nowYouArePro,
                                    title: AppStrings.youreOfficiallyAPro,
                                    btnTxt1: AppStrings.ok,
                                    onTap1: () {
                                      AppNavigation.navigatorPopUntil(
                                        context,
                                        AppRoutes.mainMenuScreenRoute,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  20.verticalSpace,
                  Obx(() {
                    final isQuickProvider =
                        AuthController.i.user.value?.isQuickProvider ?? false;
                    final isLoading =
                        AuthController.i.isQuickProviderLoading.value;
                    return CustomContainer(
                      child: Row(
                        children: [
                          CustomText(text: "Urgent Services"),
                          Spacer(),
                          IgnorePointer(
                            ignoring: isLoading,
                            child: AnimatedSwitch(
                              key: ValueKey(isQuickProvider),
                              isSwitched: isQuickProvider,
                              onCallBack: (value) {
                                AuthController.i.updateIsQuickProvider(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  20.verticalSpace,
                  _pendingBookingsSection(),
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

  Widget _pendingBookingsSection() {
    return Obx(() {
      final controller = BookingsController.i;
      final bookings = controller.pendingHomeBookings;
      final isLoading = controller.isProviderBookingsLoading.value;

      if (isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          ),
        );
      }

      if (bookings.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          for (var i = 0; i < bookings.length; i++) ...[
            if (i > 0) 20.verticalSpace,
            bookingContainerWidget(booking: bookings[i]),
          ],
          20.verticalSpace,
          CustomButton(
            text: AppStrings.viewAll,
            onclick: () {
              HomeController.i.selectedTab.value = 2;
            },
          ),
        ],
      );
    });
  }

  CustomContainer bookingContainerWidget({required ProviderBookingModel booking}) {
    final statusLabel = BookingStatusEnum.label(booking.status);
    final bookingId = booking.bookingId?.toString() ?? '-';
    final date = booking.bookingDate ?? AppStrings.dummyDate;
    final amount = booking.amount ?? '0';

    return CustomContainer(
        onTap: () {
          HomeController.i.jobStatus.value = statusLabel;
          AppNavigation.navigateTo(
            context,
            AppRoutes.bookingScreenRoute,
            arguments: BookingRoutingArgument(
              Status: statusLabel,
              bookingId: booking.bookingId,
            ),
          );
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                    text: date,
                    color: AppColors.greyLight,
                    fontSize: 12.sp),
                CustomText(
                  text: "${AppStrings.status}: $statusLabel",
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
                  text: "${AppStrings.bookingId}: #$bookingId",
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: "\$ $amount",
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
              padding: EdgeInsets.only(left: 25.w, right: 25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppStrings.marketPlace,
                    fontWeight: FontWeight.bold,
                  ),
                  8.verticalSpace,
                  CustomText(
                    text: AppStrings.homeMarketPlaceDescription,
                    color: AppColors.grey,
                    fontSize: 12.sp,
                    maxLines: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppPadding.padding10,
                    ),
                    child: CustomButton(
                      onclick: () {
                        AppNavigation.navigateTo(
                          context,
                          AppRoutes.marketPlaceScreenRoute,
                        );
                      },
                      height: 40.h,
                      borderRadius: 35.r,
                      text: AppStrings.clickHere,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Image.asset(AssetPath.tab3Icon, width: 0.45.sw),
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
              padding: EdgeInsets.only(left: 25.w, right: 25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppStrings.ourStory,
                    fontWeight: FontWeight.bold,
                  ),
                  8.verticalSpace,
                  CustomText(
                    text: AppStrings.homeOurStoryDescription,
                    color: AppColors.grey,
                    fontSize: 12.sp,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
          Image.asset(AssetPath.tab1Icon, width: 0.45.sw),
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
