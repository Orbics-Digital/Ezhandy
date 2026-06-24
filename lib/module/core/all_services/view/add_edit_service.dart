import 'package:ezhandy_user/utils/app_colors.dart';
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
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
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
  AddEditService({required this.name, required this.type, super.key});

  @override
  State<AddEditService> createState() => _AddEditServiceState();
}

class _AddEditServiceState extends State<AddEditService> {
  final GlobalKey<FormState> serviceKey = GlobalKey<FormState>();

  // String selectedValue = "";
  bool switchOff = false;
  bool isQuickService = false;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController visitChargesController = TextEditingController();
  TextEditingController visitChargesCommissionController =
      TextEditingController();
  TextEditingController quickVisitChargesController = TextEditingController();
  TextEditingController quickHourlyRateController = TextEditingController();
  TextEditingController hourlyRateController = TextEditingController();
  TextEditingController hourlyRateCommissionController =
      TextEditingController();
  TextEditingController radiusController = TextEditingController();
  List<String> shiftList = [
    "Morning (8am - 12pm)",
    "Afternoon (12pm - 5pm)",
    "Evening (5pm - 9:30pm)"
  ];
  List<String> selectedShiftList = [];
  @override
  void initState() {
    // selectedValue = Constants.servicesList[0]['name'] ?? "";
    selectedShiftList.add("Morning (8am - 12pm)");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: widget.name,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
          child: SingleChildScrollView(
            child: Form(
              key: serviceKey,
              child: Column(
                children: [
                  CustomContainer(
                      child: Column(
                    children: [
                      CustomText(
                          text: "${AppStrings.searchSetting}*",
                          fontWeight: FontWeight.bold),
                      5.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: "${AppStrings.searchSettingText}",
                            ),
                          ),
                          10.horizontalSpace,
                          AnimatedSwitch(
                              isSwitched: switchOff, onCallBack: (r) {}),
                        ],
                      )
                    ],
                  )),
                  10.verticalSpace,
                  CustomText(text: AppStrings.visitCharges),
                  5.verticalSpace,
                  _visitChargesTextField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.visitChargesCommission),
                  5.verticalSpace,
                  _visitChargesCommissionTextField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.hourlyRate),
                  5.verticalSpace,
                  _hourlyRateTextField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.hourlyRateCommission),
                  5.verticalSpace,
                  _hourlyRateCommissionTextField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.description),
                  5.verticalSpace,
                  _descriptionField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.uploadImage),
                  5.verticalSpace,
                  _uploadTextField(),
                  10.verticalSpace,
                  CustomText(text: AppStrings.radius),
                  5.verticalSpace,
                  _radiusTextField(),
                  10.verticalSpace,
                  calendarWidget(),
                  10.verticalSpace,
                  CustomText(
                      text: AppStrings.timeSlots,
                      // color: AppColors.blueDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                  10.verticalSpace,
                  hourListWidget(),
                  10.verticalSpace,
                  CustomContainer(
                      child: Column(
                    children: [
                      CustomText(
                          text: "${AppStrings.wantToGiveAQuickService}",
                          fontWeight: FontWeight.bold),
                      5.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: "${AppStrings.searchSettingText}",
                            ),
                          ),
                          10.horizontalSpace,
                          AnimatedSwitch(
                              isSwitched: isQuickService,
                              onCallBack: (r) {
                                setState(() {
                                  isQuickService = r;
                                });
                              }),
                        ],
                      )
                    ],
                  )),
                  if (isQuickService) ...[
                    10.verticalSpace,
                    CustomText(
                      text: "Slots Doesn't work on the quick service",
                      textDecoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    5.verticalSpace,
                    CustomText(text: AppStrings.visitCharges + "*"),
                    5.verticalSpace,
                    _quickVisitChargesTextField(),
                    10.verticalSpace,
                    CustomText(text: AppStrings.hourlyRate + "*"),
                    5.verticalSpace,
                    _quickHourlyRateTextField(),
                  ],
                  10.verticalSpace,
                  _button()
                ],
              ),
            ),
          ),
        ));
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
                  // ❌ Remove if already selected
                  selectedShiftList.remove(shift);
                } else {
                  // ✅ Add if not selected
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
      highlightedDates: [
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 6),
        DateTime(2026, 1, 10),
      ],
      onDatesChanged: (dates) {
        print("Selected dates:");
        for (final d in dates) {
          print(d);
        }
      },
    );
  }

  Widget _visitChargesTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: visitChargesController,
      validator: (value) => value?.validateEmpty(AppStrings.visitCharges),
      // error_text: error_email,
    );
  }

  Widget _hourlyRateTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: hourlyRateController,
      validator: (value) => value?.validateEmpty(AppStrings.hourlyRate),
      // error_text: error_email,
    );
  }

  Widget _visitChargesCommissionTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: visitChargesCommissionController,
      validator: (value) =>
          value?.validateEmpty(AppStrings.visitChargesCommission),
      // error_text: error_email,
    );
  }

  Widget _quickHourlyRateTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: quickHourlyRateController,
      validator: (value) => value?.validateEmpty(AppStrings.hourlyRate),
      // error_text: error_email,
    );
  }

  Widget _quickVisitChargesTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: quickVisitChargesController,
      validator: (value) => value?.validateEmpty(AppStrings.visitCharges),
      // error_text: error_email,
    );
  }

  Widget _hourlyRateCommissionTextField() {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: hourlyRateCommissionController,
      validator: (value) =>
          value?.validateEmpty(AppStrings.hourlyRateCommission),
      // error_text: error_email,
    );
  }

  Widget _radiusTextField() {
    return CustomTextField(
      hint: AppStrings.enterRadius,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: radiusController,
      validator: (value) => value?.validateEmpty(AppStrings.radius),
      // error_text: error_email,
    );
  }

  Widget _uploadTextField() {
    return CustomTextField(
      hint: AppStrings.uploadImage,
      divider: false,
      // prefxicon: AssetPath.uploadIcon,
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
            imageController.text = file?.path ?? "";
          });
        });
      },
      validator: (value) => value?.validateEmpty(AppStrings.uploadImage),
    );
  }

  Widget _descriptionField() {
    return CustomTextField(
      hint: AppStrings.typeHere,
      divider: false,
      // prefxicon: AssetPath.convertIcon,
      label: false,
      borderRadius: 10.r,
      lines: 5,
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
      ],
      controller: descriptionController,
      validator: (value) => value?.validateEmpty(AppStrings.message),
      // error_text: error_email,
    );
  }

  Widget _button() {
    return CustomButton(
      text: AppStrings.save,
      onclick: () {
        if (serviceKey.currentState!.validate()) {
          AppDialogs.showSuccessDialog(
            context,
            description: widget.type == AddEditType.add.name
                ? "Service Added successfully. "
                : "Service Updated successfully. ",
            title: AppStrings.congratulation,
            btnTxt1: AppStrings.ok,
            onTap1: () {
              AppNavigation.navigatorPop(context);
              if (widget.type == AddEditType.add.name) {
                AppNavigation.navigateReplacementNamed(
                    Constants.navigatorKey.currentContext!,
                    AppRoutes.listOfServicesScreenRoute);
              } else {
                AppNavigation.navigatorPop(context);
              }
            },
          );
        }
      },
    );
  }
}
