import 'dart:developer';
import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
import 'package:ezhandy_user/module/core/booking/routing_arguments/work_documents_routing_arguments.dart';
import 'package:ezhandy_user/module/core/chat/controller/chat_controller.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/map/booking_location_map.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class BookingDetails extends StatefulWidget {
  final String status;
  final int? bookingId;

  BookingDetails({
    required this.status,
    this.bookingId,
    super.key,
  });

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  int? currentHourIndex;
  final BookingsController _bookingsController = BookingsController.i;

  @override
  void initState() {
    super.initState();
    HomeController.i.jobStatus.value = widget.status;

    final bookingId = widget.bookingId;
    if (bookingId != null) {
      _bookingsController.fetchBookingDetail(bookingId);
    }
  }

  @override
  void dispose() {
    _bookingsController.clearBookingDetail();
    super.dispose();
  }

  BookingDetailModel? get _detail => _bookingsController.bookingDetail.value;

  int? get _bookingId => widget.bookingId ?? _detail?.id;

  BookingStatusEnum? get _bookingStatus =>
      BookingStatusEnum.fromId(_detail?.status);

  bool get _isStarted => _bookingStatus == BookingStatusEnum.Started;

  bool get _isCompletedOrVerified =>
      _detail?.isCompletedOrVerified ?? false;

  bool get _isCompletedUnpaid => _detail?.isCompletedUnpaid ?? false;

  bool get _isCompletedPaid => _detail?.isCompletedPaid ?? false;

  bool get _showsChatIcon =>
      BookingStatusEnum.showsChatIcon(_detail?.status);

  Future<bool> _updateBookingStatus({
    required int status,
    String? statusReason,
    bool forAccept = false,
    bool forReject = false,
  }) async {
    final bookingId = _bookingId;
    if (bookingId == null) {
      AppDialogs.showToast(message: 'Booking not found');
      return false;
    }

    return _bookingsController.updateBookingStatus(
      bookingId: bookingId,
      status: status,
      statusReason: statusReason,
      forAccept: forAccept,
      forReject: forReject,
    );
  }

  String? _statusInfoMessage() {
    switch (BookingStatusEnum.fromId(_detail?.status)) {
      case BookingStatusEnum.InRoute:
        return AppStrings.mustUploadBeforeWorkImages;
      case BookingStatusEnum.Started:
        return AppStrings.mustUploadAfterWorkImages;
      case BookingStatusEnum.Completed:
      case BookingStatusEnum.UserVerifiedIsDone:
        return AppStrings.paymentDispatchedAfterVerification;
      default:
        return null;
    }
  }

  Widget _statusInfoCard(String message) {
    return CustomContainer(
      isPadding: false,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.padding12),
        child: CustomText(
          text: message,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _openBookingChat() async {
    final user = _detail?.user;
    final otherUserId = user?.id?.trim();
    if (otherUserId == null || otherUserId.isEmpty) {
      AppDialogs.showToast(message: 'User not found');
      return;
    }

    final chatId = await ChatController.i.findOrCreateChat(
      otherUserId: otherUserId,
    );
    if (!mounted || chatId == null) return;

    await ChatController.i.refreshMyChats();
    final chat = ChatController.i.getChatById(chatId);

    final userName = user?.displayName;
    AppNavigation.navigateTo(
      context,
      AppRoutes.chatScreenRoute,
      arguments: ChatRoutingArgument(
        isBooking: true,
        chatId: chatId,
        chatType: chat?.chatType ?? 'private',
        isLocked: chat?.isLocked ?? false,
        otherUserName: userName != '-' ? userName : null,
        otherUserId: otherUserId,
        otherUserImage: user?.profileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.bookingDetails,
        actionWidget: Obx(
          () {
            _bookingsController.bookingDetail.value;
            final showIcon = _showsChatIcon;

            return Padding(
              padding: const EdgeInsets.only(right: AppPadding.padding12),
              child: showIcon
                  ? GestureDetector(
                      onTap: _openBookingChat,
                      child: Image.asset(
                        AssetPath.messageIcon,
                        width: 30.w,
                        height: 30.h,
                      ),
                    )
                  : SizedBox.shrink(),
            );
          },
        ),
        child: Obx(() {
          final isLoading = _bookingsController.isBookingDetailLoading.value;
          final isUpdatingStatus =
              _bookingsController.isUpdatingBookingStatus.value;
          final isAccepting =
              _bookingsController.isAcceptingBooking.value;
          final isRejecting =
              _bookingsController.isRejectingBooking.value;
          final hasBookingId = widget.bookingId != null;
          final statusInfoMessage = _statusInfoMessage();

          if (isLoading && hasBookingId && _detail == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          return Stack(children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.padding12),
                  child: Column(
                    children: [
                      15.verticalSpace,
                      if (statusInfoMessage != null) ...[
                        _statusInfoCard(statusInfoMessage),
                        10.verticalSpace,
                      ],
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
                      15.verticalSpace,
                      CustomContainer(
                        isPadding: false,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(AppPadding.padding12),
                              child: CustomText(
                                text: AppStrings.userDetails,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(color: AppColors.blueDark),
                            userDetailsWidget(),
                          ],
                        ),
                      ),
                      if (HomeController.i.jobStatus.value ==
                          AppStrings.pending) ...[
                        10.verticalSpace,
                        approveRejectButtonRowWidget(
                          context,
                          isAcceptLoading: isAccepting,
                          isRejectLoading: isRejecting,
                        ),
                      ],
                      rejectReasonWidget(),
                      15.verticalSpace,
                      if (HomeController.i.jobStatus.value ==
                              AppStrings.approved ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.inRoute ||
                          HomeController.i.jobStatus.value ==
                              AppStrings.started ||
                          _isCompletedOrVerified) ...[
                        if (_isStarted || _isCompletedOrVerified) ...[
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
                                                  .workDocumentsScreenRoute,
                                              arguments:
                                                  WorkDocumentsRoutingArgument(
                                                serviceName: _detail
                                                    ?.service?.displayTitle,
                                              ),
                                            );
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
                        goingButtonWidget(isLoading: isUpdatingStatus),
                      ],
                      if (HomeController.i.jobStatus.value ==
                          AppStrings.inRoute)
                        bookingLocationMapWidget(),
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
                      isLoading: isUpdatingStatus,
                      text:
                          HomeController.i.jobStatus.value == AppStrings.inRoute
                              ? "Start Job"
                              : "End Job",
                      onclick: () async {
                        if (HomeController.i.jobStatus.value ==
                            AppStrings.inRoute) {
                          AppNavigation.navigateTo(
                            context,
                            AppRoutes.uploadPictureBeforeWorkScreenRoute,
                          );
                        } else {
                          AppNavigation.navigateTo(
                            context,
                            AppRoutes.uploadPictureAfterWorkScreenRoute,
                          );
                        }
                      },
                    ),
                  ))
            ],
          ]);
        }));
  }

  Row approveRejectButtonRowWidget(
    BuildContext context, {
    bool isAcceptLoading = false,
    bool isRejectLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            isLoading: isRejectLoading,
            onclick: () {
              AppDialogs.showSuccessDialog(
                context,
                description:
                    "Are you sure you want to Reject this \nAppointment?",
                image: AssetPath.tumbIcon,
                isDoneShow: false,
                btnTxt1: AppStrings.yes,
                onTap1: () {
                  AppNavigation.navigatorPop(context);
                  AppDialogs.showRejectDialog(
                    context,
                    barrierDismissible: true,
                    title: "Reject Reason",
                    isDoneShow: false,
                    btnTxt1: AppStrings.submit,
                    onTap1: (reason) async {
                      AppNavigation.navigatorPop(context);
                      final success = await _updateBookingStatus(
                        status: BookingStatusEnum.Rejected.id,
                        statusReason: reason,
                        forReject: true,
                      );
                      if (!mounted || !success) return;

                      AppDialogs.showSuccessDialog(
                        context,
                        description:
                            "Appointment has been rejected successfully.",
                        title: AppStrings.congratulation,
                        isDoneShow: true,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPopUntil(
                            context,
                            AppRoutes.bookingScreenRoute,
                          );
                        },
                      );
                    },
                    btnTxt2: AppStrings.cancel,
                    onTap2: () {
                      AppNavigation.navigatorPop(context);
                    },
                  );
                },
                btnTxt2: AppStrings.no,
                onTap2: () {
                  AppNavigation.navigatorPop(context);
                },
              );
            },
            color: AppColors.black,
            text: AppStrings.reject,
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: CustomButton(
            isLoading: isAcceptLoading,
            onclick: () {
              AppDialogs.showSuccessDialog(
                context,
                description:
                    "Are you sure you want to approve the appointment?",
                image: AssetPath.tumbIcon,
                isDoneShow: false,
                btnTxt1: AppStrings.yes,
                onTap1: () async {
                  AppNavigation.navigatorPop(context);

                  final success = await _updateBookingStatus(
                    status: BookingStatusEnum.Assigned.id,
                    forAccept: true,
                  );
                  if (!mounted || !success) return;

                  AppDialogs.showSuccessDialog(
                    context,
                    description:
                        "Appointment has been approved successfully.",
                    btnTxt1: AppStrings.ok,
                    onTap1: () {
                      AppNavigation.navigatorPopUntil(
                        context,
                        AppRoutes.bookingScreenRoute,
                      );
                    },
                  );
                },
                btnTxt2: AppStrings.no,
                onTap2: () {
                  AppNavigation.navigatorPop(context);
                },
              );
            },
            text: AppStrings.accept,
          ),
        ),
      ],
    );
  }

  Widget rejectReasonWidget() {
    final status = _detail?.status;

    return Visibility(
      visible: BookingStatusEnum.showsReason(status),
      child: Column(
        children: [
          15.verticalSpace,
          CustomContainer(
            isPadding: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppPadding.padding12),
                  child: CustomText(
                    text: BookingStatusEnum.reasonTitle(status),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(color: AppColors.blueDark),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.padding12,
                  ),
                  child: Column(
                    children: [
                      5.verticalSpace,
                      CustomText(
                        text: _detail?.displayReason ?? '-',
                        color: AppColors.grey,
                      ),
                      10.verticalSpace,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding serviceDetailsWidget() {
    final service = _detail?.service;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.service}:',
            secondText: service?.displayTitle ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.visitCharges}:',
            secondText: service?.displayVisitCharges ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.hourlyRate}:',
            secondText: service?.displayHourlyRate ?? '-',
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Padding bookingDetailsWidget() {
    final detail = _detail;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.bookingId}:',
            secondText: detail?.displayBookingId ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.bookingDate}:',
            secondText: detail?.displayBookingDate ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.serviceDate}:',
            secondText: detail?.displayServiceDate ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.serviceTime}:',
            secondText: detail?.displayServiceTime ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.duration}:',
            secondText: detail?.displayDuration ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.charges}:',
            secondText: detail?.displayCharges ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.paymentStatus}:',
            secondText: detail?.displayPaymentStatus ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.verificationStatus}:',
            secondText: detail?.displayVerificationStatus ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.starttime}:',
            secondText: detail?.displayStartTime ?? '-',
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Padding userDetailsWidget() {
    final user = _detail?.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.userName}:',
            secondText: user?.displayName ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.phoneNumber}:',
            secondText: user?.displayPhone ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.emailAddress}:',
            secondText: user?.displayEmail ?? '-',
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget bookingLocationMapWidget() {
    final user = _detail?.user;

    return Column(
      children: [
        15.verticalSpace,
        CustomContainer(
          isPadding: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppPadding.padding12),
                child: CustomText(
                  text: AppStrings.location,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: AppColors.blueDark),
              BookingLocationMap(
                destinationLatitude: user?.parsedLatitude,
                destinationLongitude: user?.parsedLongitude,
                address: user?.address,
              ),
              10.verticalSpace,
            ],
          ),
        ),
      ],
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
        visible: _isCompletedPaid,
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
        visible: _isCompletedUnpaid,
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

  Widget goingButtonWidget({bool isLoading = false}) {
    return Visibility(
        visible: (HomeController.i.jobStatus.value == AppStrings.approved),
        child: CustomButton(
            isLoading: isLoading,
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
                () async {
              final success = await _updateBookingStatus(
                status: BookingStatusEnum.InRoute.id,
              );
              if (!mounted || !success) return;

              AppDialogs.showSuccessDialog(
                context,
                description: AppStrings.jobStatusUpdated,
                image: AssetPath.tumbIcon,
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
