import 'dart:io';

import 'package:ezhandy_user/module/core/all_services/controller/provider_services_controller.dart';
import 'package:ezhandy_user/module/core/all_services/model/create_provider_service_params.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/calendar/calendar.dart';
import 'package:ezhandy_user/widgets/checkbox/custom_checkbox.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/switch/animated_switch.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';

class AddEditService extends StatefulWidget {
  String name;
  String type;
  String serviceTypeId;
  ProviderServiceModel? service;

  AddEditService({
    required this.name,
    required this.type,
    required this.serviceTypeId,
    this.service,
    super.key,
  });

  bool get isEdit => type == AddEditType.edit.name;

  @override
  State<AddEditService> createState() => _AddEditServiceState();
}

class _AddEditServiceState extends State<AddEditService> {
  final GlobalKey<FormState> serviceKey = GlobalKey<FormState>();

  bool isQuickService = false;
  File? serviceImageFile;
  String? existingImageUrl;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController visitChargesController = TextEditingController();
  final TextEditingController hourlyRateController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController quickServiceExtraFeeController =
      TextEditingController();

  final List<String> shiftList = ProviderServiceFieldMapper.uiTimeSlotOptions;
  final List<String> selectedShiftList = [];
  List<DateTime> selectedCalendarDates = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.service != null) {
      _prefillForm(widget.service!);
    } else {
      selectedShiftList.add(shiftList.first);
      selectedCalendarDates = [DateTime.now()];
    }
  }

  void _prefillForm(ProviderServiceModel service) {
    titleController.text = service.title?.trim() ?? '';
    descriptionController.text = service.description?.trim() ?? '';
    visitChargesController.text =
        ProviderServiceFieldMapper.formatInputAmount(service.visitCharges);
    hourlyRateController.text =
        ProviderServiceFieldMapper.formatInputAmount(service.hourlyRate);
    radiusController.text =
        ProviderServiceFieldMapper.formatInputAmount(service.radius);

    isQuickService = service.isQuickService;
    if (isQuickService) {
      quickServiceExtraFeeController.text =
          ProviderServiceFieldMapper.formatInputAmount(
        service.quickServiceExtraFee,
      );
    }

    existingImageUrl = service.imageUrl?.trim();
    if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      imageController.text = AppStrings.changeImage;
    }

    final uiTimeSlots =
        ProviderServiceFieldMapper.mapTimeSlotsToUi(service.timeSlots);
    selectedShiftList
      ..clear()
      ..addAll(uiTimeSlots.isNotEmpty ? uiTimeSlots : [shiftList.first]);

    final parsedDates =
        ProviderServiceFieldMapper.parseCalendarDates(service.calendar);
    selectedCalendarDates =
        parsedDates.isNotEmpty ? parsedDates : [DateTime.now()];
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    visitChargesController.dispose();
    hourlyRateController.dispose();
    radiusController.dispose();
    quickServiceExtraFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: widget.name,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: SingleChildScrollView(
          child: Form(
            key: serviceKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: '${AppStrings.title}*'),
                5.verticalSpace,
                _titleField(),
                10.verticalSpace,
                CustomText(text: AppStrings.description),
                5.verticalSpace,
                _descriptionField(),
                10.verticalSpace,
                CustomText(text: AppStrings.visitCharges),
                5.verticalSpace,
                _visitChargesTextField(),
                10.verticalSpace,
                CustomText(text: AppStrings.hourlyRate),
                5.verticalSpace,
                _hourlyRateTextField(),
                10.verticalSpace,
                CustomText(text: AppStrings.radius),
                5.verticalSpace,
                _radiusTextField(),
                10.verticalSpace,
                CustomText(text: AppStrings.uploadImage),
                5.verticalSpace,
                _serviceImageField(),
                if (_hasServiceImagePreview) ...[
                  10.verticalSpace,
                  _serviceImagePreview(),
                ],
                10.verticalSpace,
                calendarWidget(),
                10.verticalSpace,
                CustomText(
                  text: AppStrings.timeSlots,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                10.verticalSpace,
                hourListWidget(),
                10.verticalSpace,
                _quickServiceSection(),
                if (isQuickService) ...[
                  10.verticalSpace,
                  CustomText(text: '${AppStrings.quickServiceExtraFee}*'),
                  5.verticalSpace,
                  _quickServiceExtraFeeField(),
                ],
                10.verticalSpace,
                _button(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickServiceSection() {
    return CustomContainer(
      child: Column(
        children: [
          CustomText(
            text: AppStrings.wantToGiveAQuickService,
            fontWeight: FontWeight.bold,
          ),
          5.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomText(
                  text: AppStrings.quickServiceDescription,
                ),
              ),
              10.horizontalSpace,
              AnimatedSwitch(
                isSwitched: isQuickService,
                onCallBack: (value) {
                  setState(() {
                    isQuickService = value;
                    if (!value) {
                      quickServiceExtraFeeController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hourListWidget() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: shiftList.length,
      itemBuilder: (context, index) {
        final shift = shiftList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppPadding.padding12,
          ),
          child: CheckBoxWidget(
            isChecked: selectedShiftList.contains(shift),
            ontapCheck: () {
              setState(() {
                if (selectedShiftList.contains(shift)) {
                  selectedShiftList.remove(shift);
                } else {
                  selectedShiftList.add(shift);
                }
              });
            },
            title: shift,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(thickness: 1);
      },
    );
  }

  CustomCalendar calendarWidget() {
    return CustomCalendar(
      key: ValueKey(
        selectedCalendarDates.map((date) => date.toIso8601String()).join(','),
      ),
      highlightedDates: selectedCalendarDates,
      onDatesChanged: (dates) {
        setState(() {
          selectedCalendarDates = dates;
        });
      },
    );
  }

  Widget _titleField() {
    return CustomTextField(
      hint: AppStrings.enterTitle,
      divider: false,
      label: false,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.titleMaxLength),
      ],
      controller: titleController,
      validator: (value) => value?.validateEmpty(AppStrings.title),
    );
  }

  Widget _visitChargesTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      label: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: visitChargesController,
      validator: (value) => value?.validateEmpty(AppStrings.visitCharges),
    );
  }

  Widget _hourlyRateTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      label: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: hourlyRateController,
      validator: (value) => value?.validateEmpty(AppStrings.hourlyRate),
    );
  }

  Widget _quickServiceExtraFeeField() {
    return CustomTextField(
      hint: AppStrings.enterQuickServiceExtraFee,
      divider: false,
      label: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: quickServiceExtraFeeController,
      validator: (value) {
        if (!isQuickService) return null;
        return value?.validateEmpty(AppStrings.quickServiceExtraFee);
      },
    );
  }

  Widget _radiusTextField() {
    return CustomTextField(
      hint: AppStrings.enterRadius,
      divider: false,
      label: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: radiusController,
      validator: (value) => value?.validateEmpty(AppStrings.radius),
    );
  }

  bool get _hasServiceImagePreview {
    if (serviceImageFile != null) return true;

    final imageUrl = existingImageUrl?.trim();
    return imageUrl != null && imageUrl.isNotEmpty;
  }

  Widget _serviceImageField() {
    return CustomTextField(
      hint: AppStrings.uploadImageLabel,
      divider: false,
      sufixImage: Image.asset(
        AssetPath.uploadIcon,
        scale: 3.5.sp,
      ),
      label: false,
      readOnly: true,
      controller: imageController,
      onTap: () {
        AppDialogs.showImageSourceDialog(context, setFile: (file) {
          setState(() {
            serviceImageFile = file;
            imageController.text = AppStrings.changeImage;
          });
        });
      },
      validator: (value) {
        if (serviceImageFile != null) return null;
        if (widget.isEdit &&
            existingImageUrl != null &&
            existingImageUrl!.isNotEmpty) {
          return null;
        }
        return value?.validateEmpty(AppStrings.uploadImage);
      },
    );
  }

  Widget _serviceImagePreview() {
    if (serviceImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.file(
          serviceImageFile!,
          fit: BoxFit.cover,
          height: 180.h,
          width: double.infinity,
        ),
      );
    }

    final imageUrl = existingImageUrl?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 180.h,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Image.asset(
          AssetPath.cleaningIcon,
          fit: BoxFit.cover,
          height: 180.h,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return CustomTextField(
      hint: AppStrings.typeHere,
      divider: false,
      label: false,
      borderRadius: 10.r,
      lines: 5,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength),
      ],
      controller: descriptionController,
      validator: (value) => value?.validateEmpty(AppStrings.description),
    );
  }

  bool _validateScheduleFields() {
    if (selectedShiftList.isEmpty) {
      AppDialogs.showToast(message: AppStrings.selectAtLeastOneTimeSlot);
      return false;
    }

    if (selectedCalendarDates.isEmpty) {
      AppDialogs.showToast(message: AppStrings.selectAtLeastOneCalendarDate);
      return false;
    }

    return true;
  }

  Widget _button() {
    return Obx(
      () => CustomButton(
        text: AppStrings.save,
        isLoading: widget.isEdit
            ? ProviderServicesController.i.isUpdateServiceLoading.value
            : ProviderServicesController.i.isCreateServiceLoading.value,
        onclick: _handleSubmit,
      ),
    );
  }

  CreateProviderServiceParams? _buildParams({
    required String serviceTypeId,
  }) {
    final timeSlots =
        ProviderServiceFieldMapper.mapTimeSlots(selectedShiftList);
    if (timeSlots.isEmpty) {
      AppDialogs.showToast(message: AppStrings.selectAtLeastOneTimeSlot);
      return null;
    }

    return CreateProviderServiceParams(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      visitCharges: visitChargesController.text.trim(),
      hourlyRate: hourlyRateController.text.trim(),
      radius: radiusController.text.trim(),
      serviceTypeId: serviceTypeId,
      isQuickService: isQuickService,
      isServiceActive: widget.service?.isServiceActive ?? true,
      timeSlots: timeSlots,
      calendar: ProviderServiceFieldMapper.mapCalendarDates(
        selectedCalendarDates,
      ),
      quickServiceExtraFee:
          isQuickService ? quickServiceExtraFeeController.text.trim() : null,
      image: serviceImageFile,
    );
  }

  Future<void> _handleSubmit() async {
    if (!serviceKey.currentState!.validate()) return;
    if (!_validateScheduleFields()) return;

    if (widget.isEdit) {
      final serviceId = widget.service?.id?.trim() ?? '';
      if (serviceId.isEmpty) {
        AppDialogs.showToast(message: AppStrings.noServicesFound);
        return;
      }

      final serviceTypeId =
          widget.serviceTypeId.trim().isNotEmpty
              ? widget.serviceTypeId.trim()
              : widget.service?.serviceTypeId?.trim() ?? '';
      if (serviceTypeId.isEmpty) {
        AppDialogs.showToast(message: AppStrings.selectServiceType);
        return;
      }

      if (serviceImageFile == null &&
          (existingImageUrl == null || existingImageUrl!.isEmpty)) {
        AppDialogs.showToast(message: AppStrings.uploadImage);
        return;
      }

      final params = _buildParams(serviceTypeId: serviceTypeId);
      if (params == null || !mounted) return;

      final success = await ProviderServicesController.i.updateService(
        serviceId: serviceId,
        params: params,
      );
      if (!success || !mounted) return;

      final updatedService =
          ProviderServicesController.i.getServiceById(serviceId);

      AppDialogs.showSuccessDialog(
        context,
        description: 'Service Updated successfully. ',
        title: AppStrings.congratulation,
        btnTxt1: AppStrings.ok,
        onTap1: () {
          AppNavigation.navigatorPop(context);
          AppNavigation.navigateReplacementNamed(
            context,
            AppRoutes.serviceDetailsScreenRoute,
            arguments: ServiceRoutingArgument(
              service: updatedService ?? widget.service,
              serviceName: params.title,
              serviceTypeId: serviceTypeId,
              type: isQuickService
                  ? ServiceType.instant.name
                  : ServiceType.schedule.name,
            ),
          );
        },
      );
      return;
    }

    final serviceTypeId = widget.serviceTypeId.trim();
    if (serviceTypeId.isEmpty) {
      AppDialogs.showToast(message: AppStrings.selectServiceType);
      return;
    }

    if (serviceImageFile == null) {
      AppDialogs.showToast(message: AppStrings.uploadImage);
      return;
    }

    final params = _buildParams(serviceTypeId: serviceTypeId);
    if (params == null || !mounted) return;

    final success =
        await ProviderServicesController.i.createService(params);
    if (!success || !mounted) return;

    AppDialogs.showSuccessDialog(
      context,
      description: 'Service Added successfully. ',
      title: AppStrings.congratulation,
      btnTxt1: AppStrings.ok,
      onTap1: () {
        AppNavigation.navigatorPop(context);
        AppNavigation.navigateReplacementNamed(
          Constants.navigatorKey.currentContext!,
          AppRoutes.listOfServicesScreenRoute,
        );
      },
    );
  }
}
