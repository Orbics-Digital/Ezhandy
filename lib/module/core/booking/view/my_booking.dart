import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/module/core/main_menu/main_menu_provider.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Slideable/slideable.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  // String? filterStartValue;
  var statusList = [
    AppStrings.pending,
    AppStrings.approved,
    AppStrings.rejected,
    // AppStrings.accepted,
    AppStrings.cancelled,
    AppStrings.inRoute,
    AppStrings.started,
    AppStrings.completedUnPaid,
    AppStrings.completedPaid,
    // AppStrings.assigned,
  ];
  String? statusValue;
  var statusValueList = [
    "All",
    AppStrings.pending,
    AppStrings.approved,
    AppStrings.rejected,
    // AppStrings.accepted,
    AppStrings.cancelled,
    AppStrings.inRoute,
    AppStrings.started,
    AppStrings.completedUnPaid,
    AppStrings.completedPaid,
  ];
  String? typeValue;
  var typeValueList = ["All", "Urgent", "Scheduled"];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BookingsController.i.fetchProviderBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          10.verticalSpace,
          appbarWidget(),
          20.verticalSpace,
          searchTextField(),
          10.verticalSpace,
          Expanded(
            child: Obx(() {
              final controller = BookingsController.i;
              final bookings = controller.filteredProviderBookings;
              final isLoading = controller.isProviderBookingsLoading.value;
              final hasBookings = controller.providerBookings.isNotEmpty;

              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: controller.refreshProviderBookings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      statusFilterDropDown(),
                      10.verticalSpace,
                      typeFilterDropDown(),
                      if (isLoading && bookings.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      else if (bookings.isEmpty)
                        SizedBox(height: hasBookings ? 200.h : 400.h)
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: AppPadding.padding10,
                            bottom: AppPadding.padding25,
                          ),
                          shrinkWrap: true,
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return singleWidget(
                              ontap: () {
                                HomeController.i.jobStatus.value =
                                    booking.status?.toString() ?? '';
                                AppNavigation.navigateTo(
                                  context,
                                  AppRoutes.bookingScreenRoute,
                                  arguments: BookingRoutingArgument(
                                    Status:
                                        booking.status?.toString() ?? '',
                                  ),
                                );
                              },
                              date: booking.bookingDate ??
                                  AppStrings.dummyDate,
                              status: booking.status?.toString() ?? '-',
                              bookingId:
                                  booking.bookingId?.toString() ?? '-',
                              total: booking.amount ?? '0',
                            );
                          },
                          separatorBuilder: (context, index) {
                            return 10.verticalSpace;
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget statusFilterDropDown() {
    return CustomDropDown2(
      dropDownHeight: 220.h,
      // width: 95.w, // 👈 Controls button width
      dropDownWidth: .94.sw, // 👈 Controls dropdown menu width
      dropDownData: statusValueList,
      borderRadius: 10.r,
      // isPrefix: true,
      hintText: "Status: ",
      dropdownValue: statusValue,
      dropdownListColor: AppColors.white,
      // borderColor: AppColors.greyBorder,
      hintTextColor: AppColors.black,
      onChanged: (value) {
        setState(() {
          statusValue = value.toString();
        });
      },
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return AppStrings.selectGender;
      //   }
      //   return null;
      // },
    );
  }

  Widget typeFilterDropDown() {
    return CustomDropDown2(
      dropDownHeight: 220.h,
      // width: 95.w, // 👈 Controls button width
      dropDownWidth: .94.sw, // 👈 Controls dropdown menu width
      dropDownData: typeValueList,
      borderRadius: 10.r,
      // isPrefix: true,
      hintText: "Type: ",
      dropdownValue: typeValue,
      dropdownListColor: AppColors.white,
      // borderColor: AppColors.greyBorder,
      hintTextColor: AppColors.black,
      onChanged: (value) {
        setState(() {
          typeValue = value.toString();
        });
      },
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return AppStrings.selectGender;
      //   }
      //   return null;
      // },
    );
  }

  Widget searchTextField() {
    return CustomTextField(
      label: false,
      prefxicon: AssetPath.searchIcon,
      hint: AppStrings.searchByBookingId,
      controller: _searchController,
      inputFormatters: [
        LengthLimitingTextInputFormatter(35),
        FilteringTextInputFormatter.digitsOnly,
      ],
      onchange: BookingsController.i.setSearchQuery,
    );
  }

  Row appbarWidget() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [   GestureDetector(
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
      
        CustomText(
          text: AppStrings.jobs,
          // fontFamily: AppStrings.montserrat,
          // color: AppColors.blueDark,
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
        ),
        Spacer(),
        const NotificationBadgeIcon(),
      ],
    );
  }

  Widget singleWidget({date, bookingId, status, total, ontap}) {
    return CustomContainer(
      onTap: ontap,
      child: Column(
        children: [
          5.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: date,
                color: AppColors.greyLight,
                fontSize: 10.sp,
              ),
              CustomText(
                text: "${AppStrings.status}: $status",
                color: AppColors.greyLight,
                fontSize: 10.sp,
              )
            ],
          ),
          10.verticalSpace,
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "${AppStrings.bookingId}: #$bookingId",
                  fontWeight: FontWeight.bold,
                  // color: AppColors.greyLight,
                  // fontSize: 14.sp,
                ),
                CustomText(
                  text: "\$ $total",
                  color: AppColors.orange,
                  // fontSize: 14.sp,
                )
              ]),
          5.verticalSpace,
        ],
      ),
    );
  }

  // String statusType(String? status) {
  //   switch (status) {
  //     case AppStrings.inProgress:
  //       return BookingType.InProcess.name;
  //     case AppStrings.past:
  //       return BookingType.Past.name;
  //     case AppStrings.pending:
  //       return BookingType.Pending.name;
  //     case AppStrings.rejected:
  //       return BookingType.Rejected.name;
  //     case AppStrings.reschedule:
  //       return BookingType.Reschedule.name;
  //     case AppStrings.upcoming:
  //       return BookingType.Upcoming.name;
  //     default:
  //       return 'N/A';
  //   }
  // }
}
