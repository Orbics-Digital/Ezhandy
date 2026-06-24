import 'package:ezhandy_user/module/core/booking/model/item_data_model.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/constant.dart';
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

class WorkDocuments extends StatefulWidget {
  WorkDocuments({super.key});

  @override
  State<WorkDocuments> createState() => _WorkDocumentsState();
}

class _WorkDocumentsState extends State<WorkDocuments> {
  List<ItemDataModel> items = [];
  final GlobalKey<FormState> docKey = GlobalKey<FormState>();
 late bool isEdit ;
  @override
  void initState() {
    isEdit=(HomeController.i.jobStatus.value != AppStrings.completedPaid ||
      HomeController.i.jobStatus.value != AppStrings.completedPaid);
    setController();
    // TODO: implement initState
    super.initState();
  }

  void setController() {
    if (isEdit) {
      items.add(ItemDataModel());
    } else {
      items.add(ItemDataModel(
          heading: "Service Performed",
          description:
              "•Task Description: A detailed list of all services performed, such as:\nPool cleaning (vacuuming, skimming, etc.)\nChemical testing and balancing Filter cleaning\nInspection of equipment (pump, heater, etc.)\nTime Spent: Duration for each task, or the total time spent on the entire job."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.workDocuments,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.padding12,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    bool isAdded =
                        item.headingController.text.trim().isNotEmpty ||
                            item.descriptionController.text.trim().isNotEmpty;

                    if (isAdded) {
                      return singleQuestionWidget(
                        ontapDelete: () {
                          setState(() {
                            items.removeAt(index);
                          });
                        },
                        number: index + 1,
                        task: item.headingController.text,
                        taskDetail: item.descriptionController.text,
                      );
                    }

                    // Show text fields for editing
                    return Form(
                      key: docKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: "Title"),
                          5.verticalSpace,
                          _titleTextField(controller: item.headingController),
                          10.verticalSpace,
                          CustomText(text: "Description"),
                          5.verticalSpace,
                          _descriptionTextField(
                              controller: item.descriptionController),
                          10.verticalSpace,
                          Row(
                            children: [
                              SizedBox(width: 0.7.sw),
                              Expanded(
                                child: CustomButton(
                                  onclick: () {
                                    if (docKey.currentState!.validate()) {
                                      final heading =
                                          item.headingController.text.trim();
                                      final description = item
                                          .descriptionController.text
                                          .trim();

                                      if (heading.isNotEmpty ||
                                          description.isNotEmpty) {
                                        setState(() {
                                          item.headingController.text = heading;
                                          item.descriptionController.text =
                                              description;
                                        });
                                      } else {
                                        Get.snackbar("Warning",
                                            "Please enter heading or description");
                                      }
                                    }
                                  },
                                  text: "Add",
                                  height: 40.h,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => 10.verticalSpace,
                ),
                15.verticalSpace,
                // ✅ Show Add New Line only if no text fields are open
                Builder(
                  builder: (context) {
                    bool anyEditing = items.any(
                      (item) =>
                          item.headingController.text.trim().isEmpty &&
                          item.descriptionController.text.trim().isEmpty,
                    );

                    if (!anyEditing&&isEdit) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            items.add(ItemDataModel());
                          });
                        },
                        child: CustomText(
                          text: "Add New Line +",
                          color: AppColors.orange,
                          textDecoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return SizedBox
                          .shrink(); // hide if any text field is open
                    }
                  },
                ),

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
                Visibility(
                  visible: isEdit,
                  child: CustomButton(
                    text: "Save",
                    onclick: () {
                      AppDialogs.showSuccessDialog(
                        context,
                        description: AppStrings.documentSaveSuccessfully,
                        title: AppStrings.congratulation,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPopUntil(
                              context, AppRoutes.bookingScreenRoute);
                        },
                      );
                    },
                  ),
                ),
                25.verticalSpace,
              ],
            ),
          ),
        ));
  }

  Widget _titleTextField({controller}) {
    return CustomTextField(
      hint: AppStrings.enterTitle,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,

      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: controller,
      validator: (value) => value?.validateEmpty("Title"),
      // error_text: error_email,
    );
  }

  Widget _descriptionTextField({controller}) {
    return CustomTextField(
      hint: AppStrings.enterDescription,
      divider: false,
      // prefxicon: AssetPath.languageIcon,
      label: false,
      lines: 3,
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
      ],
      controller: controller,
      validator: (value) => value?.validateEmpty("Description"),
      // error_text: error_email,
    );
  }

  Widget singleQuestionWidget({number, task, taskDetail, ontapDelete}) {
    return Column(children: [
      20.verticalSpace,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
              text: "${number}. $task:",
              // fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.orange),
          Visibility(visible: isEdit,
            child: GestureDetector(
                onTap: ontapDelete,
                child: Icon(
                  Icons.delete,
                  color: AppColors.red,
                )),
          )
        ],
      ),
      10.verticalSpace,
      CustomText(
        text: taskDetail,
      ),
      // 10.verticalSpace,
      // imageListWidget(),
    ]);
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
