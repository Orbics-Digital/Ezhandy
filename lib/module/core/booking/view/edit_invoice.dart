import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/utils.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';

class EditInvoice extends StatefulWidget {
  const EditInvoice({super.key});

  @override
  State<EditInvoice> createState() => _EditInvoiceState();
}

class _EditInvoiceState extends State<EditInvoice> {
  /// Form Key
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();

  /// Text Editing Controllers
  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController billNameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();

  List<TextEditingController> itemController = [
    TextEditingController(),
  ];
  List<TextEditingController> descriptionController = [
    TextEditingController(),
  ];
  List<TextEditingController> amountController = [
    TextEditingController(),
  ];
  List<TextEditingController> otherItemController = [
    TextEditingController(),
  ];
  List<TextEditingController> otherDescriptionController = [
    TextEditingController(),
  ];
  List<TextEditingController> otherAmountController = [
    TextEditingController(),
  ];

  DateTime? dateValue;
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.editInvoice,
        actionWidget: downloadBtnWidget(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
          child: SingleChildScrollView(
            child: Column(children: [
              20.verticalSpace,
              CustomText(
                text: AppStrings.invoiceDes,
                fontWeight: FontWeight.bold,
              ),
              10.verticalSpace,
              CustomText(
                  text: AppStrings.invoice,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange,
                  fontSize: 18.sp),
              10.verticalSpace,
              CustomText(text: AppStrings.invoiceNumber),
              10.verticalSpace,
              _invoiceNumberTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.billName),
              10.verticalSpace,
              _billNameTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.date),
              10.verticalSpace,
              _dateTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.cost),
              10.verticalSpace,
              _costTextField(),
              SizedBox(height: 0.02.sh),
              Row(children: [
                Expanded(
                    child:
                        CustomText(text: "Item", fontWeight: FontWeight.bold)),
                // SizedBox.shrink(),
                10.horizontalSpace,
                Expanded(
                    child: CustomText(
                        text: "Description", fontWeight: FontWeight.bold)),
                10.horizontalSpace,
                // SizedBox.shrink(),
                Expanded(
                    child: CustomText(
                        text: "Amount", fontWeight: FontWeight.bold)),
                // SizedBox.shrink(),
              ]),
              10.verticalSpace,
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: itemController.length,
                itemBuilder: (context, index) {
                  // final item = notifications[index];
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _itemTextField(i: 0)),
                        10.horizontalSpace,
                        Expanded(child: _descriptionTextField(i: 0)),
                        10.horizontalSpace,
                        Expanded(child: _amountTextField(i: 0)),
                      ]);
                },
                separatorBuilder: (context, index) {
                  return 20.verticalSpace;
                },
              ),
              10.verticalSpace,
              GestureDetector(
                  onTap: () {
                    setState(() {
                      itemController.add(TextEditingController());
                      descriptionController.add(TextEditingController());
                      amountController.add(TextEditingController());
                    });
                  },
                  child: CustomText(
                    align: Alignment.centerRight,
                    text: AppStrings.addMoreLines,
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 0.02.sh),
              CustomText(text: "Other", fontWeight: FontWeight.bold),
              5.verticalSpace,
              _otherTextField(),
              10.verticalSpace,
              Row(children: [
                Expanded(
                    child:
                        CustomText(text: "Item", fontWeight: FontWeight.bold)),
                // SizedBox.shrink(),
                10.horizontalSpace,
                Expanded(
                    child: CustomText(
                        text: "Description", fontWeight: FontWeight.bold)),
                10.horizontalSpace,
                // SizedBox.shrink(),
                Expanded(
                    child: CustomText(
                        text: "Amount", fontWeight: FontWeight.bold)),
                // SizedBox.shrink(),
              ]),
              10.verticalSpace,
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: otherItemController.length,
                itemBuilder: (context, index) {
                  // final item = notifications[index];
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _otherItemTextField(i: 0)),
                        10.horizontalSpace,
                        Expanded(child: _otherDescriptionTextField(i: 0)),
                        10.horizontalSpace,
                        Expanded(child: _otherAmountTextField(i: 0)),
                      ]);
                },
                separatorBuilder: (context, index) {
                  return 20.verticalSpace;
                },
              ),
              10.verticalSpace,
              GestureDetector(
                  onTap: () {
                    setState(() {
                      otherItemController.add(TextEditingController());
                      otherDescriptionController.add(TextEditingController());
                      otherAmountController.add(TextEditingController());
                    });
                  },
                  child: CustomText(
                    align: Alignment.centerRight,
                    text: AppStrings.addMoreLines,
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                  )),
              CustomText(text: AppStrings.totalAmount),
              10.verticalSpace,
              _totalAmountTextField(),
              SizedBox(height: 0.02.sh),
              CustomButton(
                text: AppStrings.update,
                onclick: () {
                  HomeController.i.jobStatus.value = AppStrings.completed;
                  AppDialogs.showSuccessDialog(
                    context,
                    description: AppStrings.invoiceUpdatedSuccessfully,
                    title: AppStrings.congratulation,
                    btnTxt1: AppStrings.ok,
                    onTap1: () {
                      AppNavigation.navigatorPop(context);
                    },
                  );
                },
              ),
              25.verticalSpace,
            ]),
          ),
        ));
  }

  Padding downloadBtnWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: AppPadding.padding12),
      child: CustomButton(
          width: 140.w,
          onclick: () async {
            AppNavigation.navigateTo(context, AppRoutes.invoiceScreenRoute);
          },
          text: AppStrings.generateInvoice),
    );
  }

  Widget _invoiceNumberTextField() {
    return CustomTextField(
      hint: AppStrings.enterInvoiceNumber,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: invoiceNumberController,
      validator: (value) => value?.validateEmpty(AppStrings.invoiceNumber),
      // error_text: error_email,
    );
  }

  Widget _billNameTextField() {
    return CustomTextField(
      hint: AppStrings.enterBillName,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: billNameController,
      validator: (value) => value?.validateEmpty(AppStrings.billName),
      // error_text: error_email,
    );
  }

  Widget _dateTextField() {
    return CustomTextField(
      hint: AppStrings.selectDate,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      onTap: () async {
        dateValue = await Utils.displayDatePicker(
            context: context,
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            date: DateTime.now());
        if (dateValue != null) {
          dateController.text = Utils.formatDate(
              pattern: AppStrings.MMM_DD_YYYY_FORMAT, date: dateValue);
          setState(() {});
        }
      },
      sufixImage: Image.asset(
        AssetPath.calendarIcon,
        color: AppColors.greyLight,
        scale: 3.5,
      ),
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: dateController,
      validator: (value) => value?.validateEmpty(AppStrings.date),
      // error_text: error_email,
    );
  }

  Widget _costTextField() {
    return CustomTextField(
      hint: AppStrings.enterCost,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      // readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: costController,
      validator: (value) => value?.validateEmpty(AppStrings.cost),
      // error_text: error_email,
    );
  }

  Widget _itemTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterItem,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: itemController[i],
      validator: (value) => value?.validateEmpty(AppStrings.item),
      // error_text: error_email,
    );
  }

  Widget _descriptionTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterDescription,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: descriptionController[i],
      validator: (value) => value?.validateEmpty(AppStrings.description),
      // error_text: error_email,
    );
  }

  Widget _amountTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: amountController[i],
      validator: (value) => value?.validateEmpty(AppStrings.amount),
      // error_text: error_email,
    );
  }

  Widget _otherItemTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterItem,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: otherItemController[i],
      validator: (value) => value?.validateEmpty(AppStrings.item),
      // error_text: error_email,
    );
  }

  Widget _otherDescriptionTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterDescription,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: otherDescriptionController[i],
      validator: (value) => value?.validateEmpty(AppStrings.description),
      // error_text: error_email,
    );
  }

  Widget _otherAmountTextField({i}) {
    return CustomTextField(
      hint: AppStrings.enterAmount,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: otherAmountController[i],
      validator: (value) => value?.validateEmpty(AppStrings.amount),
      // error_text: error_email,
    );
  }

  Widget _otherTextField() {
    return CustomTextField(
      hint: AppStrings.other,
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: otherController,
      // validator: (value) => value?.validateEmpty(AppStrings.other),
      // error_text: error_email,
    );
  }

  Widget _totalAmountTextField() {
    return CustomTextField(
      hint: "\$${AppStrings.dummyAmount2}",
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      // readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      controller: totalAmountController,
      // validator: (value) => value?.validateEmpty(AppStrings.cost),
      // error_text: error_email,
    );
  }
}
