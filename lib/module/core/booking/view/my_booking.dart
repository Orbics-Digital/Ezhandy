import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
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
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
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
                      if (isLoading &&
                          controller.providerBookings.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      else if (bookings.isEmpty)
                        const EmptyMessage(
                          message: AppStrings.noBookingsFound,
                        )
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
                                final statusLabel =
                                    BookingStatusEnum.label(booking.status);
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
                              date: booking.bookingDate ??
                                  AppStrings.dummyDate,
                              status: BookingStatusEnum.label(booking.status),
                              bookingId:
                                  booking.bookingId?.toString() ?? '-',
                              total: booking.amount ?? '0',
                              isQuick: booking.isQuick,
                              showUnpaid: !booking.isPaid &&
                                  BookingStatusEnum.showsUnpaidTag(
                                    booking.status,
                                  ),
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
    return Obx(
      () => CustomDropDown2(
        dropDownHeight: 280.h,
        dropDownWidth: .94.sw,
        dropDownData: BookingStatusEnum.dropdownLabels,
        borderRadius: 10.r,
        hintText: "Status: ",
        dropdownValue: BookingsController.i.selectedStatusLabel,
        dropdownListColor: AppColors.white,
        hintTextColor: AppColors.black,
        onChanged: (value) {
          BookingsController.i.setStatusFilterByLabel(value?.toString());
        },
      ),
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
          text: AppStrings.myBookings,
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

  Widget singleWidget({
    date,
    bookingId,
    status,
    total,
    ontap,
    bool isQuick = false,
    bool showUnpaid = false,
  }) {
    return CustomContainer(
      onTap: ontap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isQuick || showUnpaid)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isQuick) _bookingTagLabel(
                  text: AppStrings.quick,
                  color: AppColors.orange,
                ),
                if (isQuick && showUnpaid) 4.horizontalSpace,
                if (showUnpaid)
                  _bookingTagLabel(
                    text: AppStrings.unpaid,
                    color: AppColors.red,
                  ),
              ],
            ),
          if (isQuick || showUnpaid) 8.verticalSpace else 5.verticalSpace,
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
              ),
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

  Widget _bookingTagLabel({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          height: 1,
          fontFamily: AppStrings.montserrat,
        ),
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
