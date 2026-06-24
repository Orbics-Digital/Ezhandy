import 'package:ezhandy_user/module/core/booking/model/item_data_model.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class AddEditPastWork extends StatefulWidget {
  String type;
  AddEditPastWork({required this.type, super.key});

  @override
  State<AddEditPastWork> createState() => _AddEditPastWorkState();
}

class _AddEditPastWorkState extends State<AddEditPastWork> {
  final GlobalKey<FormState> pastWorkKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void setController() {}

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: widget.type == AddEditType.add.name
            ? AppStrings.addPastWork
            : AppStrings.editPastWork,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.padding12,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: pastWorkKey,
              child: Column(
                children: [
                  // Show text fields for editing
                  15.verticalSpace,

                  CustomText(text: "Past Work Name*"),
                  5.verticalSpace,
                  _titleTextField(),
                  10.verticalSpace,
                  CustomText(text: "Work Description*"),
                  5.verticalSpace,
                  _descriptionTextField(),
                  10.verticalSpace,

                  // ✅ Show Add New Line only if no text fields are open

                  15.verticalSpace,
                  CustomText(
                    text: AppStrings.beforeImage,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  5.verticalSpace,
                  imageListWidget(),
                  10.verticalSpace,
                  CustomText(
                    text: AppStrings.afterImage,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  5.verticalSpace,
                  imageListWidget(),
                  10.verticalSpace,
                  CustomButton(
                    text:
                        widget.type == AddEditType.add.name ? "Create" : "Save",
                    onclick: () {
                      AppDialogs.showSuccessDialog(
                        context,
                        description: widget.type == AddEditType.add.name
                            ? AppStrings.pastWorkCreateSuccessfully
                            : AppStrings.pastWorkUpdatedSuccessfully,
                        title: AppStrings.congratulation,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPopUntil(
                              context, AppRoutes.pastworkScreenRoute);
                        },
                      );
                    },
                  ),
                  25.verticalSpace,
                ],
              ),
            ),
          ),
        ));
  }

  Widget _titleTextField() {
    return CustomTextField(
      hint: AppStrings.enterPastWorkName,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: nameController,
      validator: (value) => value?.validateEmpty("Past Work Name"),
      // error_text: error_email,
    );
  }

  Widget _descriptionTextField() {
    return CustomTextField(
      hint: AppStrings.enterWorkDescription,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,
      lines: 3,
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
      ],
      controller: descriptionController,
      validator: (value) => value?.validateEmpty("Work Description"),
      // error_text: error_email,
    );
  }

  Widget imageListWidget() {
    return Container(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: .45.sw,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        "https://t4.ftcdn.net/jpg/02/14/20/51/360_F_214205168_JqvyKVeKzYGTpQEdy3Y1c7CUh6fRMg0W.jpg"))),
          );
        },
        separatorBuilder: (context, index) {
          return 10.horizontalSpace;
        },
        itemCount: 5,
      ),
    );
  }
}
