// ignore_for_file: must_be_immutable
import 'dart:io';

import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/model/register_provider_params.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/app_logo.dart';
import 'package:ezhandy_user/widgets/profile_widget/profile_picture_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/rich_text_widget.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpForm extends StatefulWidget {
  bool keyboardVisible;
  SignUpForm({required this.keyboardVisible, super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // String? error_email;

  /// Form Key
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();

  /// Text Editing Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController uploadController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController aboutYouController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _profileImage;

  String? genderValue;
  var genderList = ["Male", "Female"];

  String? languageValue;
  final languageList = const ["English", "Spanish", "French"];

  /// Certificates list — each map holds controllers and image file
  List<Map<String, dynamic>> certificates = [];

  @override
  void initState() {
    super.initState();
    // Add the first certificate by default
    addCertificate();
  }

  void addCertificate() {
    setState(() {
      certificates.add({
        "institute": TextEditingController(),
        "title": TextEditingController(),
        "picture": TextEditingController(),
        "pictureFile": null,
      });
    });
  }

  void removeCertificate(int index) {
    setState(() {
      certificates.removeAt(index);
    });
  }

  // bool switchOff = false;
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.padding16,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: bottomInset + 25.h),
        child: Form(
          key: signUpKey,
          child: Column(
            children: [
              AppLogo(scale: 5.sp),
              15.verticalSpace,
              createAccountTextWidget(),
              5.verticalSpace,
              CustomText(
                  is_alignLeft: false, text: AppStrings.createYouAccountText),
              25.verticalSpace,
              Center(child: profileWidget()),
              10.verticalSpace,
              CustomText(
                text: AppStrings.uploadProfileImage,
                is_alignLeft: false,
                color: AppColors.grey,
                fontSize: 12.sp,
              ),
              20.verticalSpace,
              CustomText(text: AppStrings.fullName + "*"),
              10.verticalSpace,
              _fullNameTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.emailAddress + "*"),
              10.verticalSpace,
              _emailTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.phoneNumber + AppStrings.optional),
              10.verticalSpace,
              _phoneNumberTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.language + "*"),
              10.verticalSpace,
              languageDropDown(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.gender + "*"),
              10.verticalSpace,
              genderDropDown(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.experience + "*"),
              10.verticalSpace,
              _experienceTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.aboutYou + "*"),
              10.verticalSpace,
              _aboutYouTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.address + "*"),
              10.verticalSpace,
              _addressTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.password + "*"),
              10.verticalSpace,
              _passwordTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(text: AppStrings.confirmPassword + "*"),
              10.verticalSpace,
              _confirmPasswordTextField(),
              SizedBox(height: 0.02.sh),
              CustomText(
                text: "Certifications Details",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              20.verticalSpace,

              /// 📜 Dynamic List of Certification Forms
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
                                text: "${AppStrings.insituteName} *"),
                          ),
                          if (certificates.length > 1 && index != 0)
                            GestureDetector(
                              onTap: () => removeCertificate(index),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    AssetPath.deleteRedIcon,
                                    scale: 3,
                                  ),
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
                      _instituteNameTextField(item["institute"]! as TextEditingController),
                      15.verticalSpace,
                      CustomText(text: "${AppStrings.certificateTitle} *"),
                      10.verticalSpace,
                      _degreeTitleTextField(item["title"]! as TextEditingController),
                      15.verticalSpace,
                      CustomText(text: "${AppStrings.certificatePicture} *"),
                      10.verticalSpace,
                      _uploadTextField(
                        item["picture"]! as TextEditingController,
                        imageFile: item["pictureFile"] as File?,
                        onFileSelected: (file) {
                          certificates[index]["pictureFile"] = file;
                        },
                      ),
                      if (item["pictureFile"] != null) ...[
                        10.verticalSpace,
                        _certificateImagePreview(
                          item["pictureFile"] as File,
                        ),
                      ],
                      SizedBox(height: 0.03.sh),
                      Divider(thickness: 1, color: AppColors.greyBorder),
                      SizedBox(height: 0.02.sh),
                    ],
                  );
                },
              ),

              /// ➕ Add More Button
              GestureDetector(
                onTap: addCertificate,
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: AppColors.orange),
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
              SizedBox(height: 0.02.sh),
              _signUpButton(context: context),
              SizedBox(height: 0.02.sh),
              if (!widget.keyboardVisible) alreadyHaveAnAccountWidget(),
            ],
          ),
        ),
      ),
    );
  }

  ProfilePictureWidget profileWidget() {
    return ProfilePictureWidget(
      showUpload: true,
      setFile: (file) => _setFile(file),
      profileImage: _profileImage,
      assetPath: AssetPath.userIcon,
    );
  }

  _setFile(File? file) {
    setState(() {
      _profileImage = file;
      uploadController.text = file?.path ?? "";
    });
  }

  CustomText createAccountTextWidget() {
    return CustomText(
      text: AppStrings.createAccount,
      is_alignLeft: false,
      fontSize: 25.sp,
      fontWeight: FontWeight.bold,
    );
  }

  Widget languageDropDown() {
    return CustomDropDown2(
      dropDownHeight: 220.h,
      dropDownWidth: .91.sw,
      dropDownData: languageList,
      borderRadius: 10.r,
      isPrefix: true,
      hintText: AppStrings.selectLanguage,
      dropdownValue: languageValue,
      dropdownListColor: AppColors.white,
      hintTextColor: AppColors.black,
      onChanged: (value) {
        setState(() {
          languageValue = value?.toString();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.selectLanguage;
        }
        return null;
      },
    );
  }

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


  Widget _passwordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.enterPassword,
        prefxicon: AssetPath.lockIcon,
        inputFormatters: [LengthLimitingTextInputFormatter(35)],
        sufixImage: Icon(
          FieldValidator.isHidepassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: AppColors.orange,
        ),
        obscureText: FieldValidator.isHidepassword,
        onclickSufix: () {
          setState(() {
            FieldValidator.passwordHideIcon();
          });
        },
        controller: passwordController,
        validator: (value) {
          return FieldValidator.validateLoginPassword(value!, "Password");
        });
  }

  Widget _confirmPasswordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.confirmPassword,
        prefxicon: AssetPath.lockIcon,
        // prefixRIghtPadding: 8.w,
        inputFormatters: [LengthLimitingTextInputFormatter(35)],
        sufixImage: Icon(
          FieldValidator.isHideconfirmpassword
              ? Icons.visibility_off
              : Icons.visibility,
          size: 20.sp,
          color: AppColors.orange,
        ),
        obscureText: FieldValidator.isHideconfirmpassword,
        onclickSufix: () {
          setState(() {
            FieldValidator.confirmPasswordHideIcon();
          });
        },
        controller: confirmPasswordController,
        validator: (value) {
          return FieldValidator.validateConfirmPassword(
              value!, passwordController.text, AppStrings.confirmPassword);
        });
  }

  Widget alreadyHaveAnAccountWidget() {
    return RichTextWidget(
        text: AppStrings.alreadyHaveAnAccount,
        subText: AppStrings.logIn,
        onSubTextPress: () {
          FocusScope.of(context).unfocus();
          AppNavigation.navigatorPop(context);

          // AppNavigation.navigateTo(context, AppRoutes.signupScreenRoute);
          // Get.toNamed(Paths.SIGNUP_SCREEN_ROUTE);
        });
  }

  // Modified field builders to accept controller
  Widget _instituteNameTextField(TextEditingController controller) {
    return CustomTextField(
      hint: AppStrings.enterInstituteName,
      divider: false,
      prefxicon: AssetPath.instituteIcon,
      label: false,
      controller: controller,
      validator: (value) => value?.validateEmpty(AppStrings.insituteName),
    );
  }

  Widget _degreeTitleTextField(TextEditingController controller) {
    return CustomTextField(
      hint: AppStrings.enterCertificateTitle,
      divider: false,
      prefxicon: AssetPath.certificateIcon,
      label: false,
      controller: controller,
      validator: (value) => value?.validateEmpty(AppStrings.certificateTitle),
    );
  }

  Widget _uploadTextField(
    TextEditingController controller, {
    File? imageFile,
    required void Function(File? file) onFileSelected,
  }) {
    final hasImage = imageFile != null;

    return CustomTextField(
      hint: AppStrings.uploadImageLabel,
      divider: false,
      prefxicon: AssetPath.uploadIcon,
      label: false,
      readOnly: true,
      controller: controller,
      onTap: () {
        AppDialogs.showImageSourceDialog(context, setFile: (file) {
          setState(() {
            onFileSelected(file);
            controller.text =
                file != null ? AppStrings.changeImage : '';
          });
        });
      },
      validator: (_) {
        if (!hasImage) {
          return AppStrings.uploadImageLabel;
        }
        return null;
      },
    );
  }

  Widget _certificateImagePreview(File imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.file(
        imageFile,
        fit: BoxFit.cover,
        height: 180.h,
        width: double.infinity,
      ),
    );
  }

  Widget _fullNameTextField() {
    return CustomTextField(
      hint: AppStrings.enterFullName,
      divider: false,
      prefxicon: AssetPath.profileCircleIcon,
      label: false,
      // readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      // ],
      controller: fullNameController,
      validator: (value) => value?.validateEmpty(AppStrings.fullName),
      // error_text: error_email,
    );
  }

  Widget _statusTextField() {
    return CustomTextField(
      hint: AppStrings.EnterStatus,
      divider: false,
      prefxicon: AssetPath.statusUpIcon,
      label: false,

      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: statusController,
      validator: (value) => value?.validateEmpty(AppStrings.status),
      // error_text: error_email,
    );
  }

  Widget _phoneNumberTextField() {
    return CustomTextField(
      hint: AppStrings.enterPhoneNumber,
      divider: false,
      prefxicon: AssetPath.callIcon,
      label: false,
      keyboardType: TextInputType.number,
      inputFormatters: [Constants.maskTextInputFormatterPhoneUSWithCode],
      controller: phoneController,
      // validator: (value) => value?.validateEmpty(AppStrings.phon),
      // error_text: error_email,
    );
  }

  Widget _experienceTextField() {
    return CustomTextField(
      hint: AppStrings.enterExperience,
      divider: false,
      prefxicon: AssetPath.homeTimeIcon,
      label: false,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      controller: experienceController,
      validator: (value) => value?.validateEmpty(AppStrings.experience),
    );
  }

  Widget _aboutYouTextField() {
    return CustomTextField(
      hint: AppStrings.enterAboutYou,
      divider: false,
      prefxicon: AssetPath.aboutIcon,
      label: false,
      borderRadius: 10.r,
      lines: 5,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength),
      ],
      controller: aboutYouController,
      validator: (value) => value?.validateEmpty(AppStrings.aboutYou),
    );
  }

  Widget _addressTextField() {
    return CustomTextField(
      hint: AppStrings.enterAddress,
      divider: false,
      prefxicon: AssetPath.locationIcon,
      label: false,
      borderRadius: 10.r,
      lines: 3,
      controller: addressController,
      validator: (value) => value?.validateEmpty(AppStrings.address),
    );
  }

  Widget _emailTextField() {
    return CustomTextField(
      hint: AppStrings.enterUserEmail,
      divider: false,
      prefxicon: AssetPath.emailIcon,
      label: false,

      keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.emailMaxLength)
      ],
      controller: emailController,
      validator: (value) => value?.validateEmail,
      // error_text: error_email,
    );
  }

  Widget _signUpButton({required BuildContext context}) {
    return Obx(
      () => CustomButton(
        text: AppStrings.createAccount,
        isLoading: AuthController.i.isRegisterLoading.value,
        onclick: () async {
          if (!signUpKey.currentState!.validate()) return;

          FocusScope.of(context).unfocus();

          final institutionNames = <String>[];
          final certificationTitles = <String>[];
          final certificationImages = <File>[];

          for (final cert in certificates) {
            institutionNames.add(
              (cert["institute"]! as TextEditingController).text.trim(),
            );
            certificationTitles.add(
              (cert["title"]! as TextEditingController).text.trim(),
            );
            final imageFile = cert["pictureFile"] as File?;
            if (imageFile != null) {
              certificationImages.add(imageFile);
            }
          }

          if (certificationImages.length != certificates.length) {
            AppDialogs.showToast(
              message: AppStrings.uploadCertificatePicture,
            );
            return;
          }

          final experience = int.tryParse(experienceController.text.trim());
          if (experience == null) {
            AppDialogs.showToast(message: AppStrings.enterExperience);
            return;
          }

          final phone = phoneController.text.trim();

          final success = await AuthController.i.registerProvider(
            context,
            params: RegisterProviderParams(
              fullName: fullNameController.text.trim(),
              email: emailController.text.trim(),
              mobileNumber: phone.isEmpty ? null : phone,
              languageId: SignUpFieldMapper.languageIdFromLabel(languageValue),
              gender: SignUpFieldMapper.genderCode(genderValue),
              password: passwordController.text,
              address: addressController.text.trim(),
              aboutUs: aboutYouController.text.trim(),
              experience: experience,
              profileImage: _profileImage,
              institutionNames: institutionNames,
              certificationTitles: certificationTitles,
              certificationImages: certificationImages,
            ),
          );

          if (success && context.mounted) {
            emailController.clear();
            passwordController.clear();
            confirmPasswordController.clear();
          }
        },
      ),
    );
  }
}
