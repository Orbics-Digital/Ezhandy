import 'package:ezhandy_user/module/core/all_services/controller/provider_services_controller.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/past_work_routing_arguments%20copy.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/utils/enums.dart';
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
  ProviderServiceModel? get _service => widget.service;

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
                              padding:
                                  const EdgeInsets.all(AppPadding.padding12),
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
                    10.verticalSpace,
                  ],
                ),
              ),
            ),
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
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      color: AppColors.black,
                      text: AppStrings.remove,
                      isLoading:
                          ProviderServicesController.i.isDeleteServiceLoading.value,
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
            25.verticalSpace,
          ],
        ),
      ),
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

        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.serviceDeleteSuccessfully,
          title: AppStrings.congratulation,
          btnTxt1: AppStrings.ok,
          onTap1: () {
            AppNavigation.navigatorPopUntil(
              context,
              AppRoutes.listOfServicesScreenRoute,
            );
          },
        );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: Column(
        children: [
          5.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.timeSlots}:',
            secondText: _service?.displayTimeSlots ?? '-',
          ),
          TwoTextRow(
            firstText: '${AppStrings.availableDates}:',
            secondText: _service?.displayCalendar ?? '-',
          ),
          10.verticalSpace,
        ],
      ),
    );
  }

  Widget _serviceImage() {
    final imageUrl = _service?.imageUrl?.trim() ?? '';

    return Container(
      height: 250.h,
      width: 1.sw,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.greyBorder.withOpacity(0.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                AssetPath.tempCleaningImage,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              AssetPath.tempCleaningImage,
              fit: BoxFit.cover,
            ),
    );
  }
}
