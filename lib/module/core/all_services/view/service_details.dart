import 'package:ezhandy_user/module/core/all_services/controller/provider_services_controller.dart';
import 'package:ezhandy_user/module/core/all_services/model/create_provider_service_params.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/past_work_routing_arguments%20copy.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/widgets/calendar/calendar.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
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
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ServiceDetails extends StatefulWidget {
  final String? type;
  final ProviderServiceModel? service;

  const ServiceDetails({
    this.type,
    this.service,
    super.key,
  });

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  late bool _isServiceActive;

  ProviderServiceModel? get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _isServiceActive = widget.service?.isServiceActive ?? true;
  }
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: AppStrings.serviceDetails,
      appBarheight: 50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _serviceImage(),
            15.verticalSpace,
            CustomText(
              text: _service?.title ?? AppStrings.titleName,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
            5.verticalSpace,
            CustomText(
              text: _service?.description ?? AppStrings.lorem5,
            ),
            15.verticalSpace,
            CustomContainer(
              isPadding: false,
              child: chargesDetailsWidget(),
            ),
            if (_service?.isQuickService == true) ...[
              15.verticalSpace,
              CustomContainer(
                isPadding: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppPadding.padding12),
                      child: CustomText(
                        text: AppStrings.quickService,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: AppColors.blueDark),
                    quickChargesDetailsWidget(),
                  ],
                ),
              ),
            ],
            15.verticalSpace,
            CustomContainer(
              isPadding: false,
              child: scheduleDetailsWidget(),
            ),
            15.verticalSpace,
            _actionButtonsWidget(),
            25.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _actionButtonsWidget() {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.pastWork,
          onclick: () {
            final serviceId = _service?.id?.trim();
            if (serviceId == null || serviceId.isEmpty) {
              AppDialogs.showToast(message: AppStrings.noServicesFound);
              return;
            }

            AppNavigation.navigateTo(
              context,
              AppRoutes.pastworkScreenRoute,
              arguments: PastWorkRoutingArgument(serviceId: serviceId),
            );
          },
        ),
        10.verticalSpace,
        Obx(
          () => CustomButton(
            color: _isServiceActive ? AppColors.black : AppColors.orange,
            text: _isServiceActive
                ? AppStrings.deactivateService
                : AppStrings.activateService,
            isLoading:
                ProviderServicesController.i.isUpdateServiceStatusLoading.value,
            onclick: _handleToggleServiceStatus,
          ),
        ),
        10.verticalSpace,
        Row(
          children: [
            Expanded(
              child: Obx(
                () => CustomButton(
                  color: AppColors.black,
                  text: AppStrings.remove,
                  isLoading: ProviderServicesController
                      .i.isDeleteServiceLoading.value,
                  onclick: _handleDeleteService,
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: CustomButton(
                text: AppStrings.edit,
                onclick: () {
                  AppNavigation.navigateReplacementNamed(
                    context,
                    AppRoutes.addEditServiceScreenRoute,
                    arguments: ServiceRoutingArgument(
                      service: _service,
                      serviceName: _service?.title ?? AppStrings.edit,
                      serviceTypeId: _service?.serviceTypeId,
                      type: AddEditType.edit.name,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleToggleServiceStatus() {
    final serviceId = _service?.id?.trim() ?? '';
    if (serviceId.isEmpty) {
      AppDialogs.showToast(message: AppStrings.noServicesFound);
      return;
    }

    final activating = !_isServiceActive;

    AppDialogs.showSuccessDialog(
      context,
      description: activating
          ? AppStrings.areYouSureYouWantToActivateThisService
          : AppStrings.areYouSureYouWantToDeactivateThisService,
      image: AssetPath.tumbIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.yes,
      onTap1: () async {
        AppNavigation.navigatorPop(context);

        final success = await ProviderServicesController.i.updateServiceStatus(
          serviceId: serviceId,
          isServiceActive: activating,
        );
        if (!success || !mounted) return;

        final updatedService =
            ProviderServicesController.i.getServiceById(serviceId);
        setState(() {
          _isServiceActive =
              updatedService?.isServiceActive ?? activating;
        });

        AppDialogs.showSuccessDialog(
          context,
          description: activating
              ? AppStrings.serviceActivatedSuccessfully
              : AppStrings.serviceDeactivatedSuccessfully,
          title: AppStrings.congratulation,
          btnTxt1: AppStrings.ok,
          onTap1: () {
            AppNavigation.navigatorPop(context);
          },
        );
      },
      btnTxt2: AppStrings.no,
      onTap2: () {
        AppNavigation.navigatorPop(context);
      },
    );
  }

  void _handleDeleteService() {
    final serviceId = _service?.id?.trim() ?? '';
    if (serviceId.isEmpty) {
      AppDialogs.showToast(message: AppStrings.noServicesFound);
      return;
    }

    AppDialogs.showSuccessDialog(
      context,
      description: AppStrings.areYouSureYouWantToDeleteThisService,
      image: AssetPath.deleteWithCircleIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.yes,
      onTap1: () async {
        AppNavigation.navigatorPop(context);

        final success =
            await ProviderServicesController.i.deleteService(serviceId);
        if (!success || !mounted) return;

        AppDialogs.showToast(message: AppStrings.serviceDeleteSuccessfully);
        Get.back();
      },
      btnTxt2: AppStrings.no,
      onTap2: () {
        AppNavigation.navigatorPop(context);
      },
    );
  }

  Widget chargesDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.visitCharges}:',
            secondText: _service?.displayVisitCharges ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.hourlyRate}:',
            secondText: _service?.displayHourlyRate ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.radius}:',
            secondText: _service?.displayRadius ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.status}:',
            secondText:
                _isServiceActive ? AppStrings.active : AppStrings.inactive,
            secondColor:
                _isServiceActive ? AppColors.green : AppColors.red,
          ),
          if ((_service?.serviceType?.displayName ?? '').isNotEmpty)
            TwoTextRow(
              firstText: '${AppStrings.category}:',
              secondText: _service!.serviceType!.displayName,
            ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget quickChargesDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.quickServiceExtraFee}:',
            secondText: _service?.displayQuickServiceExtraFee ?? '-',
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget scheduleDetailsWidget() {
    final timeSlots = _service?.timeSlotDisplayItems ?? const [];
    final availableDates = _service?.availableCalendarDates ?? const [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.verticalSpace,
          CustomText(
            text: AppStrings.timeSlots,
            fontWeight: FontWeight.w600,
          ),
          8.verticalSpace,
          if (timeSlots.isEmpty)
            CustomText(
              text: '-',
              color: AppColors.grey,
            )
          else
            Column(
              children: [
                for (var i = 0; i < timeSlots.length; i++) ...[
                  if (i > 0) 8.verticalSpace,
                  _timeSlotCard(timeSlots[i]),
                ],
              ],
            ),
          15.verticalSpace,
          CustomText(
            text: AppStrings.availableDates,
            fontWeight: FontWeight.w600,
          ),
          8.verticalSpace,
          if (availableDates.isEmpty)
            CustomText(
              text: '-',
              color: AppColors.grey,
            )
          else
            CustomCalendar(
              key: ValueKey(
                availableDates.map((date) => date.toIso8601String()).join(','),
              ),
              highlightedDates: availableDates,
              initialFocusedDate: availableDates.first,
              readOnly: true,
            ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget _timeSlotCard(TimeSlotDisplayInfo slot) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.orange.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: slot.range.isEmpty ? 24.h : 36.h,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: slot.title,
                  fontWeight: FontWeight.w600,
                ),
                if (slot.range.isNotEmpty) ...[
                  2.verticalSpace,
                  CustomText(
                    text: slot.range,
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceImage() {
    final imageUrl = _service?.imageUrl?.trim() ?? '';
    final isQuickService = _service?.isQuickService == true;

    return Container(
      height: 250.h,
      width: 1.sw,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.greyBorder.withOpacity(0.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                AssetPath.tempCleaningImage,
                fit: BoxFit.cover,
              ),
            )
          else
            Image.asset(
              AssetPath.tempCleaningImage,
              fit: BoxFit.cover,
            ),
          if (isQuickService)
            Positioned(
              top: 10.h,
              left: 0,
              child: _quickServiceBadge(),
            ),
        ],
      ),
    );
  }

  Widget _quickServiceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35.r),
          bottomRight: Radius.circular(35.r),
        ),
      ),
      child: CustomText(
        text: AppStrings.quickService,
        color: AppColors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
