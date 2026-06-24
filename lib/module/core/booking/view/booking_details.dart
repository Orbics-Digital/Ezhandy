import 'dart:developer';
import 'package:ezhandy_user/module/core/booking/routing_arguments/booking_routing_arguments.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:flutter/material.dart';
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

class BookingDetails extends StatefulWidget {
  String status;
  BookingDetails({required this.status, super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  int? currentHourIndex;
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.job,
        actionWidget: Obx(
          () {
            bool showIcon = HomeController.i.jobStatus.value ==
                    AppStrings.inRoute ||
                HomeController.i.jobStatus.value == AppStrings.started ||
                HomeController.i.jobStatus.value == AppStrings.completedUnPaid;

            return Padding(
              padding: const EdgeInsets.only(right: AppPadding.padding12),
              child: showIcon
                  ? GestureDetector(
                      onTap: () {
                        AppNavigation.navigateTo(
                          context,
                          AppRoutes.chatScreenRoute,
                          arguments: ChatRoutingArgument(isBooking: false),
                        );
                      },
                      child: Image.asset(
                        AssetPath.messageIcon,
                        width: 30.w,
                        height: 30.h,
                      ),
                    )
                  : SizedBox.shrink(), // safe empty widget instead of null
            );
          },
        ),
        child: Obx(() {
          return Stack(children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.padding12),
                  child: Column(
                    children: [
                      15.verticalSpace,
                      CustomContainer(
                          isPadding: false,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppPadding.padding12),
                                child: CustomText(
                                    text: AppStrings.serviceName,
                                    // color: AppColors.blueDark,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Divider(color: AppColors.blueDark),
                              serviceDetailsWidget(),
                              // reScheduleWidget(),
                            ],
                          )),
                      10.verticalSpace,
                      CustomContainer(
                          isPadding: false,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppPadding.padding12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                        text: AppStrings.bookingDetails,
                                        // color: AppColors.blueDark,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                    CustomText(
                                        text:
                                            "${AppStrings.status}: ${HomeController.i.jobStatus.value}",
                                        fontWeight: FontWeight.w600),
                                  ],
                                ),
                              ),
                              Divider(color: AppColors.blueDark),
                              bookingDetailsWidget(),
                              // reScheduleWidget(),
                            ],
                          )),
                      if (HomeController.i.jobStatus.value ==
                          AppStrings.pending) ...[
                        10.verticalSpace,
                        approveRejectButtonRowWidget(context)
                      ],
                      rejectReasonWidget(),
                      15.verticalSpace,
                      if (HomeController.i.jobStatus.value ==
                              AppStrings.approved ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.inRoute ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.started ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.completedPaid ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.completedUnPaid) ...[
                        CustomContainer(
                            isPadding: false,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                      AppPadding.padding12),
                                  child: CustomText(
                                      text: AppStrings.userDetails,
                                      // color: AppColors.blueDark,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(color: AppColors.blueDark),
                                userDetailsWidget(),
                                // reScheduleWidget(),
                              ],
                            )),
                        15.verticalSpace,
                        if (HomeController.i.jobStatus.value ==
                                AppStrings.started ||
                            HomeController.i.jobStatus.value ==
                                AppStrings.completedPaid ||
                            HomeController.i.jobStatus.value ==
                                AppStrings.completedUnPaid) ...[
                          CustomContainer(
                              isPadding: false,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        AppPadding.padding12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                            text: AppStrings.workDocuments,
                                            // color: AppColors.blueDark,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                        HomeController.i.jobStatus.value ==
                                                AppStrings.started
                                            ? SizedBox.shrink()
                                            : CustomText(
                                                text: AppStrings.invoice,
                                                // color: AppColors.blueDark,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                  ),
                                  Divider(color: AppColors.blueDark),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        10.horizontalSpace,
                                        GestureDetector(
                                          onTap: () {
                                            AppNavigation.navigateTo(
                                                context,
                                                AppRoutes
                                                    .workDocumentsScreenRoute);
                                          },
                                          child: Image.asset(
                                              AssetPath.documentTotalIcon,
                                              width: 50.w,
                                              height: 50.h),
                                        ),
                                        Spacer(),
                                        HomeController.i.jobStatus.value ==
                                                AppStrings.started
                                            ? SizedBox.shrink()
                                            : GestureDetector(
                                                onTap: () {
                                                  AppNavigation.navigateTo(
                                                      context,
                                                      AppRoutes
                                                          .editInvoiceScreenRoute);
                                                },
                                                child: Image.asset(
                                                    AssetPath.documentTotalIcon,
                                                    width: 50.w,
                                                    height: 50.h),
                                              ),
                                        10.horizontalSpace,
                                      ],
                                    ),
                                  ),
                                  // reScheduleWidget(),
                                ],
                              )),
                          15.verticalSpace,
                        ],
                        // reportReviewButtonWidget(),
                        // endWorkButtonWidget(),
                        goingButtonWidget(),
                      ],
                      HomeController.i.jobStatus.value == AppStrings.inRoute
                          ? CustomContainer(
                              onTap: () {
                                // AppNavigation.navigateTo(
                                //     context, AppRoutes.MyAppointmentScreenRoute);
                              },
                              height: 200.h,
                              width: 1.sw,
                              isPadding: false,
                              child:
                                  Image.asset(AssetPath.map, fit: BoxFit.cover))
                          : SizedBox.shrink(),
                      25.verticalSpace,
                      if (HomeController.i.jobStatus.value ==
                              AppStrings.inRoute ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.started) ...[
                        45.verticalSpace,
                      ]
                    ],
                  ),
                ),
              ),
            ),
            if (HomeController.i.jobStatus.value == AppStrings.inRoute ||
                HomeController.i.jobStatus.value == AppStrings.started) ...[
              Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.padding12),
                    child: CustomButton(
                      text:
                          HomeController.i.jobStatus.value == AppStrings.inRoute
                              ? "Start Job"
                              : "End Job",
                      onclick: () {
                        if (HomeController.i.jobStatus.value ==
                            AppStrings.inRoute) {
                          AppNavigation.navigateTo(context,
                              AppRoutes.uploadPictureBeforeWorkScreenRoute);
                        } else {
                          AppDialogs.showSuccessDialog(context,
                              description: "Are you sure you want to end job?",
                              // title: AppStrings.logout,
                              image: AssetPath.tumbIcon,
                              isDoneShow: false,
                              btnTxt1: AppStrings.yes,
                              onTap1: () {
                                HomeController.i.jobStatus.value =
                                    AppStrings.completedPaid;
                                AppNavigation.navigatorPop(context);
                                AppDialogs.showSuccessDialog(
                                  context,
                                  description: "Job ended successfully",
                                  title: AppStrings.congratulation,
                                  btnTxt1: AppStrings.ok,
                                  onTap1: () {
                                    AppNavigation.navigatorPopUntil(
                                        context, AppRoutes.bookingScreenRoute);
                                  },
                                );
                              },
                              btnTxt2: AppStrings.no,
                              onTap2: () {
                                AppNavigation.navigatorPop(context);
                              });
                        }
                      },
                    ),
                  ))
            ],
          ]);
        }));
  }

  Row approveRejectButtonRowWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomButton(
                onclick: () {
                  AppDialogs.showSuccessDialog(context,
                      description:
                          "Are you sure you want to approve the appointment?",
                      // title: AppStrings.logout,
                      image: AssetPath.tumbIcon,
                      isDoneShow: false,
                      btnTxt1: AppStrings.yes,
                      onTap1: () {
                        AppNavigation.navigatorPop(context);

                        AppDialogs.showSuccessDialog(
                          context,
                          description:
                              "Appointment has been approved successfully.",
                          // title: AppStrings.congratulation,
                          btnTxt1: AppStrings.ok,
                          onTap1: () {
                            AppNavigation.navigatorPopUntil(
                              context,
                              AppRoutes.bookingScreenRoute,
                            );
                            setState(() {
                              HomeController.i.jobStatus.value =
                                  AppStrings.approved;
                            });
                          },
                        );
                      },
                      btnTxt2: AppStrings.no,
                      onTap2: () {
                        AppNavigation.navigatorPop(context);
                      });
                },
                text: AppStrings.approve)),
        10.horizontalSpace,
        Expanded(
            child: CustomButton(
                onclick: () {
                  AppDialogs.showSuccessDialog(context,
                      description:
                          "Are you sure you want to Reject this \nAppointment?",
                      // title: AppStrings.logout,
                      image: AssetPath.tumbIcon,
                      isDoneShow: false,
                      btnTxt1: AppStrings.yes,
                      onTap1: () {
                        AppNavigation.navigatorPop(context);
                        AppDialogs.showRejectDialog(context,
                            barrierDismissible: true,
                            // description:
                            //     "Are you sure you want to cancel this \nbooking?",
                            title: "Reject Reason",
                            // image: AssetPath.tumbIcon,
                            isDoneShow: false,
                            btnTxt1: AppStrings.submit,
                            onTap1: () {
                              AppNavigation.navigatorPop(context);
                              setState(() {
                                HomeController.i.jobStatus.value =
                                    AppStrings.rejected;
                              });
                              AppDialogs.showSuccessDialog(
                                context,
                                description:
                                    "Appointment has been rejected successfully.",
                                title: AppStrings.congratulation,
                                // image: AssetPath.deletePopUpIcon,
                                isDoneShow: true,
                                btnTxt1: AppStrings.ok,
                                onTap1: () {
                                  // AppNavigation.navigatorPop(context);
                                  AppNavigation.navigatorPopUntil(
                                      context, AppRoutes.bookingScreenRoute);
                                },
                              );
                            },
                            btnTxt2: AppStrings.cancel,
                            onTap2: () {
                              AppNavigation.navigatorPop(context);
                            });
                      },
                      btnTxt2: AppStrings.no,
                      onTap2: () {
                        AppNavigation.navigatorPop(context);
                      });
                },
                color: AppColors.black,
                text: AppStrings.reject))
      ],
    );
  }

  Widget rejectReasonWidget() {
    return Visibility(
      visible: HomeController.i.jobStatus.value == AppStrings.rejected ||
          HomeController.i.jobStatus.value == AppStrings.cancelled,
      child: Column(
        children: [
          10.verticalSpace,
          CustomText(
              text: AppStrings.reason,
              // color: AppColors.blueDark,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold),
          10.verticalSpace,
          CustomText(
            text: AppStrings.lorem5,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Padding serviceDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.service}:", secondText: "Type Name"),
          TwoTextRow(
              firstText: "${AppStrings.visitCharges}:", secondText: "\$10"),
          TwoTextRow(
              firstText: "${AppStrings.hourlyRate}:", secondText: "\$10"),
          10.verticalSpace,
        ],
      ),
    );
  }

  Padding bookingDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.bookingId}:",
              secondText: "#${AppStrings.dummyOrderNumber}"),
          TwoTextRow(
              firstText: "${AppStrings.bookingDate}:",
              secondText: AppStrings.dummyDate),
          TwoTextRow(
              firstText: "${AppStrings.userName}:",
              secondText: AppStrings.dummyName),
          TwoTextRow(
              firstText: "${AppStrings.phoneNumber}:",
              secondText: AppStrings.dummyPhoneNUmber),
          TwoTextRow(
              firstText: "${AppStrings.emailAddress}:",
              secondText: AppStrings.dummyEmail),
          TwoTextRow(
              firstText: "${AppStrings.address}:",
              secondText: AppStrings.lorem1),
          TwoTextRow(
              firstText: "${AppStrings.serviceDate}:",
              secondText: AppStrings.dummyDate),
          TwoTextRow(
              firstText: "${AppStrings.serviceTime}:",
              secondText: AppStrings.dummytime),
          10.verticalSpace,
        ],
      ),
    );
  }

  Padding userDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
              firstText: "${AppStrings.userName}:",
              secondText: AppStrings.dummyName),
          TwoTextRow(
              firstText: "${AppStrings.phoneNumber}:",
              secondText: AppStrings.dummyPhoneNUmber),
          HomeController.i.jobStatus.value == AppStrings.started ||
                  HomeController.i.jobStatus.value ==
                      AppStrings.completedPaid ||
                  HomeController.i.jobStatus.value == AppStrings.completedUnPaid
              ? TwoTextRow(
                  firstText: "${AppStrings.starttime}:",
                  secondText: AppStrings.dummytime)
              : SizedBox.shrink(),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget reScheduleWidget() {
    return Visibility(
      // visible: HomeController.i.jobStatus.value == BookingType.Reschedule.name,
      child: Column(
        children: [
          Divider(color: AppColors.blueDark),
          Padding(
            padding: const EdgeInsets.all(AppPadding.padding12),
            child: CustomText(
                text: AppStrings.reScheduleTimeAndDate,
                color: AppColors.blueDark,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold),
          ),
          Divider(
            color: AppColors.blueDark,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
            child: Column(
              children: [
                5.verticalSpace,
                TwoTextRow(
                    firstText: "${AppStrings.sessionDate}:",
                    secondText: AppStrings.dummyDate),
                TwoTextRow(
                    firstText: "${AppStrings.sessionTime}:",
                    secondText:
                        "${AppStrings.dummytime} - ${AppStrings.dummytime}"),
                10.verticalSpace,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget reportReviewButtonWidget() {
    return Visibility(
        visible: (HomeController.i.jobStatus.value == AppStrings.completedPaid),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                  color: AppColors.black,
                  text:
                      // (
                      // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                      //       HomeController.i.jobStatus.value == BookingType.InProcess.name)
                      //   ? AppStrings.joinSession
                      //   :
                      AppStrings.reportIssue,
                  onclick:
                      // (HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                      //         HomeController.i.jobStatus.value == BookingType.InProcess.name)
                      //     ? () {
                      //         AppNavigation.navigateTo(
                      //             context, AppRoutes.videoCallScreenRoute);
                      //       }
                      //     :
                      () {
                    AppNavigation.navigateTo(
                        context, AppRoutes.reportIssueScreenRoute);
                  }),
            ),
            10.horizontalSpace,
            Expanded(
              child: CustomButton(
                  text:
                      // (
                      // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                      //       HomeController.i.jobStatus.value == BookingType.InProcess.name)
                      //   ? AppStrings.joinSession
                      //   :
                      AppStrings.review,
                  onclick:
                      // (HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                      //         HomeController.i.jobStatus.value == BookingType.InProcess.name)
                      //     ? () {
                      //         AppNavigation.navigateTo(
                      //             context, AppRoutes.videoCallScreenRoute);
                      //       }
                      //     :
                      () {
                    AppNavigation.navigateTo(
                        context, AppRoutes.writeReviewScreenRoute);
                  }),
            ),
          ],
        ));
  }

  Widget endWorkButtonWidget() {
    return Visibility(
        visible:
            (HomeController.i.jobStatus.value == AppStrings.completedUnPaid),
        child: CustomButton(
            text:
                // (
                // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                //       HomeController.i.jobStatus.value == BookingType.InProcess.name)
                //   ? AppStrings.joinSession
                //   :
                AppStrings.payFurtherAmount,
            onclick:
                // (HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                //         HomeController.i.jobStatus.value == BookingType.InProcess.name)
                //     ? () {
                //         AppNavigation.navigateTo(
                //             context, AppRoutes.videoCallScreenRoute);
                //       }
                //     :
                () {
              // AppDialogs.showSuccessDialog(context,
              //     description: AppStrings.refundPolicyWork,
              //     // title: AppStrings.deleteAccount,
              //     image: AssetPath.tumbIcon,
              //     isDoneShow: false,
              //     btnTxt1: AppStrings.refund,
              //     onTap1: () {
              //       AppNavigation.navigatorPop(context);
              //       AppDialogs.showSuccessDialog(
              //         context,
              //         description: AppStrings.oneOfOurRepresentative,
              //         title: AppStrings.refundRequestSubmitted,
              //         btnTxt1: AppStrings.goToHome,
              //         onTap1: () {
              //           AppNavigation.navigatorPopUntil(
              //               context, AppRoutes.mainMenuScreenRoute);
              //         },
              //       );
              //     },
              //     btnTxt2: AppStrings.cancel,
              //     onTap2: () {
              //       AppNavigation.navigatorPop(context);
              //     });
            }));
  }

  Widget goingButtonWidget() {
    return Visibility(
        visible: (HomeController.i.jobStatus.value == AppStrings.approved),
        child: CustomButton(
            text:
                // (
                // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                //       HomeController.i.jobStatus.value == BookingType.InProcess.name)
                //   ? AppStrings.joinSession
                //   :
                AppStrings.going,
            onclick:
                // (HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
                //         HomeController.i.jobStatus.value == BookingType.InProcess.name)
                //     ? () {
                //         AppNavigation.navigateTo(
                //             context, AppRoutes.videoCallScreenRoute);
                //       }
                //     :
                () {
              setState(() {
                HomeController.i.jobStatus.value = AppStrings.inRoute;
              });
              AppDialogs.showSuccessDialog(
                context,
                description: AppStrings.jobStatusUpdated,
                // title: AppStrings.deleteAccount,
                image: AssetPath.tumbIcon,
                // isDoneShow: false,
                btnTxt1: AppStrings.ok,
                onTap1: () {
                  AppNavigation.navigatorPop(context);
                },
              );
            }));
  }

  Widget buttonWidget(BuildContext context) {
    log(HomeController.i.jobStatus.value.toString());
    log(HomeController.i.jobStatus.value.toString());

    return Visibility(
      // visible: (
      // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
      //   HomeController.i.jobStatus.value == BookingType.InProcess.name ||
      // HomeController.i.jobStatus.value == BookingType.Past.name
      // ),
      child: CustomButton(
        text:
            // (
            // HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
            //       HomeController.i.jobStatus.value == BookingType.InProcess.name)
            //   ? AppStrings.joinSession
            //   :
            AppStrings.rateService,
        onclick:
            // (HomeController.i.jobStatus.value == BookingType.Upcoming.name ||
            //         HomeController.i.jobStatus.value == BookingType.InProcess.name)
            //     ? () {
            //         AppNavigation.navigateTo(
            //             context, AppRoutes.videoCallScreenRoute);
            //       }
            //     :
            () {
          AppNavigation.navigateTo(context, AppRoutes.writeReviewScreenRoute);
        },
      ),
    );
  }
}
