// ignore_for_file: must_be_immutable
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/profile_widget/profile_picture_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditUserProfile extends StatefulWidget {
  EditUserProfile({super.key});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final GlobalKey<FormState> editProfileKey = GlobalKey<FormState>();

  /// Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  File? _profileImage;

  String? genderValue;
  var genderList = ["Male", "Female"];

  /// Certificate dynamic fields
  List<Map<String, TextEditingController>> certificates = [];

  bool keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    addCertificate();
  }

  void addCertificate() {
    setState(() {
      certificates.add({
        "institute": TextEditingController(),
        "title": TextEditingController(),
        "picture": TextEditingController(),
      });
    });
  }

  void removeCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    log("Keyboard: $keyboardVisible");
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: AppStrings.editProfile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: editProfileKey,
                  child: Column(
                    children: [
                      10.verticalSpace,
                      profileWidget(),
                      20.verticalSpace,

                      /// Full Name
                      CustomText(text: AppStrings.fullName + "*"),
                      10.verticalSpace,
                      _fullNameTextField(),
                      SizedBox(height: 0.02.sh),

                      /// Email
                      CustomText(text: AppStrings.emailAddress + "*"),
                      10.verticalSpace,
                      _emailTextField(),
                      SizedBox(height: 0.02.sh),

                      /// Phone Number
                      CustomText(
                          text: AppStrings.phoneNumber + AppStrings.optional),
                      10.verticalSpace,
                      _phoneNumberTextField(),
                      SizedBox(height: 0.02.sh),

                      /// Language
                      CustomText(text: AppStrings.language + "*"),
                      10.verticalSpace,
                      _languageTextField(),
                      SizedBox(height: 0.02.sh),

                      /// Gender
                      CustomText(text: AppStrings.gender + "*"),
                      10.verticalSpace,
                      genderDropDown(),
                      SizedBox(height: 0.03.sh),

                      /// Certificates
                      CustomText(
                        text: "Certifications Details",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                      20.verticalSpace,

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: certificates.length,
                        itemBuilder: (context, index) {
                          var item = certificates[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: "${AppStrings.insituteName} *",
                                    ),
                                  ),
                                  if (certificates.length > 1 && index != 0)
                                    GestureDetector(
                                      onTap: () => removeCertificate(index),
                                      child: Row(
                                        children: [
                                          Image.asset(AssetPath.deleteRedIcon,
                                              scale: 3),
                                          5.horizontalSpace,
                                          CustomText(
                                            text: AppStrings.delete,
                                            color: AppColors.pinkDark,
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              10.verticalSpace,
                              _instituteNameTextField(item["institute"]!),
                              15.verticalSpace,
                              CustomText(
                                  text: "${AppStrings.certificateTitle} *"),
                              10.verticalSpace,
                              _degreeTitleTextField(item["title"]!),
                              15.verticalSpace,
                              CustomText(
                                  text: "${AppStrings.certificatePicture} *"),
                              10.verticalSpace,
                              _uploadTextField(item["picture"]!),
                              SizedBox(height: 0.03.sh),
                              Divider(
                                  thickness: 1, color: AppColors.greyBorder),
                              SizedBox(height: 0.02.sh),
                            ],
                          );
                        },
                      ),

                      /// Add more
                      GestureDetector(
                        onTap: addCertificate,
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle,
                                color: AppColors.orange),
                            5.horizontalSpace,
                            CustomText(
                              text: AppStrings.addMore,
                              color: AppColors.orange,
                            ),
                            5.horizontalSpace,
                            const Expanded(child: Divider(thickness: 2)),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.03.sh),
                    ],
                  ),
                ),
              ),
            ),

            /// Update button
            Visibility(
              visible: !keyboardVisible,
              child: _updateButton(context: context),
            ),
            Visibility(visible: !keyboardVisible, child: 25.verticalSpace),
          ],
        ),
      ),
    );
  }

  ProfilePictureWidget profileWidget() {
    return ProfilePictureWidget(
      showUpload: true,
      setFile: _setFile,
      profileImage: _profileImage,
      assetPath: null,
    );
  }

  _setFile(File? file) {
    setState(() {
      _profileImage = file;
    });
  }

  Widget _fullNameTextField() => CustomTextField(
        hint: AppStrings.enterFullName,
        divider: false,
        prefxicon: AssetPath.profileCircleIcon,
        label: false,
        inputFormatters: [
          LengthLimitingTextInputFormatter(Constants.nameMaxLength)
        ],
        controller: fullNameController,
        validator: (v) => v?.validateEmpty(AppStrings.fullName),
      );

  Widget _emailTextField() => CustomTextField(
        hint: AppStrings.enterUserEmail,
        divider: false,
        prefxicon: AssetPath.emailIcon,
        label: false,
        readOnly: true,
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          LengthLimitingTextInputFormatter(Constants.emailMaxLength)
        ],
        controller: emailController,
        validator: (v) => v?.validateEmail,
      );

  Widget _phoneNumberTextField() => CustomTextField(
        hint: AppStrings.enterPhoneNumber,
        divider: false,
        prefxicon: AssetPath.callIcon,
        label: false,
        keyboardType: TextInputType.number,
        inputFormatters: [Constants.maskTextInputFormatterPhoneUSWithCode],
        controller: phoneController,
      );

  Widget _languageTextField() => CustomTextField(
        hint: AppStrings.enterLanguage,
        divider: false,
        prefxicon: AssetPath.languageIcon,
        label: false,
        controller: languageController,
        validator: (v) => v?.validateEmpty(AppStrings.language),
      );

  Widget genderDropDown() {
    return CustomDropDown2(
      dropDownHeight: 220.h,
      // width: 95.w, // 👈 Controls button width
      dropDownWidth: .91.sw, // 👈 Controls dropdown menu width
      dropDownData: genderList,
      borderRadius: 10.r,
      isPrefix: true,
      hintText: AppStrings.selectGender,
      dropdownValue: genderValue,
      dropdownListColor: AppColors.white,
      // borderColor: AppColors.greyBorder,
      hintTextColor: AppColors.black,
      onChanged: (value) {
        setState(() {
          genderValue = value.toString();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.selectGender;
        }
        return null;
      },
    );
  }

  Widget _instituteNameTextField(TextEditingController controller) =>
      CustomTextField(
        hint: AppStrings.enterInstituteName,
        divider: false,
        prefxicon: AssetPath.instituteIcon,
        label: false,
        controller: controller,
        validator: (v) => v?.validateEmpty(AppStrings.insituteName),
      );

  Widget _degreeTitleTextField(TextEditingController controller) =>
      CustomTextField(
        hint: AppStrings.enterCertificateTitle,
        divider: false,
        prefxicon: AssetPath.certificateIcon,
        label: false,
        controller: controller,
        validator: (v) => v?.validateEmpty(AppStrings.certificateTitle),
      );

  Widget _uploadTextField(TextEditingController controller) => CustomTextField(
        hint: AppStrings.uploadCertificatePicture,
        divider: false,
        prefxicon: AssetPath.uploadIcon,
        label: false,
        readOnly: true,
        controller: controller,
        onTap: () {
          AppDialogs.showImageSourceDialog(context, setFile: (file) {
            setState(() {
              controller.text = file?.path ?? "";
            });
          });
        },
        validator: (v) => v?.validateEmpty(AppStrings.certificatePicture),
      );

  Widget _updateButton({required BuildContext context}) => CustomButton(
        text: AppStrings.update,
        onclick: () {
          if (editProfileKey.currentState!.validate()) {
            AppDialogs.showSuccessDialog(
              context,
              description: AppStrings.profileUpdatedSuccessful,
              title: AppStrings.congratulation,
              btnTxt1: AppStrings.ok,
              onTap1: () {
                AppNavigation.navigatorPopUntil(
                    context, AppRoutes.userProfileScreenRoute);
              },
            );
          }
          FocusScope.of(context).unfocus();
        },
      );
}
