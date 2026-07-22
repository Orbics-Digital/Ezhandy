// ignore_for_file: must_be_immutable
import 'dart:io';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/model/certificate_model.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';
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
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController aboutYouController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  String? genderValue;
  var genderList = ["Male", "Female"];

  String? languageValue;
  final languageList = const ["English", "Spanish", "French"];

  /// Certificate dynamic fields
  List<Map<String, dynamic>> certificates = [];

  bool keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _populateFromLoggedInUser();
  }

  void _populateFromLoggedInUser() {
    final user = AuthController.i.user.value;
    fullNameController.text = user?.fullName?.trim() ?? '';
    emailController.text = user?.email?.trim() ?? '';
    phoneController.text = user?.mobileNumber?.trim() ?? '';
    languageValue = _languageLabelFromUser(user);
    experienceController.text =
        user?.experience != null ? user!.experience.toString() : '';
    aboutYouController.text = user?.aboutUs?.trim() ?? '';
    addressController.text = user?.address?.trim() ?? '';
    genderValue = _genderLabelFromUser(user);
    _profileImageUrl = user?.profileImage?.trim();

    _populateCertificates(user?.certifications ?? const []);
    setState(() {});
  }

  String? _languageLabelFromUser(UserModel? user) {
    final title = user?.languageTitle?.trim();
    if (title != null && title.isNotEmpty) return title;

    switch (user?.languageId) {
      case 2:
        return 'Spanish';
      case 3:
        return 'French';
      case 1:
        return 'English';
      default:
        return null;
    }
  }

  String? _genderLabelFromUser(UserModel? user) {
    final title = user?.genderTitle?.trim();
    if (title != null && genderList.contains(title)) return title;

    switch (user?.gender?.trim().toUpperCase()) {
      case 'F':
      case 'FEMALE':
        return 'Female';
      case 'M':
      case 'MALE':
        return 'Male';
      default:
        return null;
    }
  }

  void _populateCertificates(List<CertificateModel> items) {
    _disposeCertificates();

    if (items.isEmpty) {
      addCertificate();
      return;
    }

    certificates = items.map((item) {
      final url = item.certificatePath?.trim();
      final hasUrl = url != null && url.isNotEmpty;

      return {
        'institute': TextEditingController(
          text: item.institutionName?.trim() ?? '',
        ),
        'title': TextEditingController(
          text: item.certificationTitle?.trim() ?? '',
        ),
        'picture': TextEditingController(
          text: hasUrl ? AppStrings.changeImage : '',
        ),
        'pictureFile': null,
        'pictureUrl': hasUrl ? url : null,
      };
    }).toList();
  }

  void _disposeCertificates() {
    for (final item in certificates) {
      (item['institute'] as TextEditingController?)?.dispose();
      (item['title'] as TextEditingController?)?.dispose();
      (item['picture'] as TextEditingController?)?.dispose();
    }
    certificates.clear();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    experienceController.dispose();
    aboutYouController.dispose();
    addressController.dispose();
    _disposeCertificates();
    super.dispose();
  }

  void addCertificate() {
    setState(() {
      certificates.add({
        'institute': TextEditingController(),
        'title': TextEditingController(),
        'picture': TextEditingController(),
        'pictureFile': null,
        'pictureUrl': null,
      });
    });
  }

  void removeCertificate(int index) {
    setState(() {
      final item = certificates.removeAt(index);
      (item['institute'] as TextEditingController?)?.dispose();
      (item['title'] as TextEditingController?)?.dispose();
      (item['picture'] as TextEditingController?)?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
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
                      languageDropDown(),
                      SizedBox(height: 0.02.sh),

                      /// Gender
                      CustomText(text: AppStrings.gender + "*"),
                      10.verticalSpace,
                      genderDropDown(),
                      SizedBox(height: 0.02.sh),

                      /// Experience
                      CustomText(text: AppStrings.experience + "*"),
                      10.verticalSpace,
                      _experienceTextField(),
                      SizedBox(height: 0.02.sh),

                      /// About You
                      CustomText(text: AppStrings.aboutYou + "*"),
                      10.verticalSpace,
                      _aboutYouTextField(),
                      SizedBox(height: 0.02.sh),

                      /// Address
                      CustomText(text: AppStrings.address + "*"),
                      10.verticalSpace,
                      _addressTextField(),
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
                          final item = certificates[index];
                          final pictureFile = item['pictureFile'] as File?;
                          final pictureUrl = item['pictureUrl'] as String?;

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
                              _instituteNameTextField(
                                item['institute']! as TextEditingController,
                              ),
                              15.verticalSpace,
                              CustomText(
                                  text: "${AppStrings.certificateTitle} *"),
                              10.verticalSpace,
                              _degreeTitleTextField(
                                item['title']! as TextEditingController,
                              ),
                              15.verticalSpace,
                              CustomText(
                                  text: "${AppStrings.certificatePicture} *"),
                              10.verticalSpace,
                              _uploadTextField(
                                item['picture']! as TextEditingController,
                                imageFile: pictureFile,
                                imageUrl: pictureUrl,
                                onFileSelected: (file) {
                                  certificates[index]['pictureFile'] = file;
                                  if (file != null) {
                                    certificates[index]['pictureUrl'] = null;
                                  }
                                },
                              ),
                              if (pictureFile != null) ...[
                                10.verticalSpace,
                                _certificateImagePreview(pictureFile),
                              ] else if (pictureUrl != null &&
                                  pictureUrl.isNotEmpty) ...[
                                10.verticalSpace,
                                _certificateNetworkImagePreview(pictureUrl),
                              ],
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
      profileImageUrl: _profileImageUrl,
      assetPath: AssetPath.tempImage1,
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

  Widget _experienceTextField() => CustomTextField(
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
        validator: (v) => v?.validateEmpty(AppStrings.experience),
      );

  Widget _aboutYouTextField() => CustomTextField(
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
        validator: (v) => v?.validateEmpty(AppStrings.aboutYou),
      );

  Widget _addressTextField() => CustomTextField(
        hint: AppStrings.enterAddress,
        divider: false,
        prefxicon: AssetPath.locationIcon,
        label: false,
        borderRadius: 10.r,
        lines: 3,
        controller: addressController,
        validator: (v) => v?.validateEmpty(AppStrings.address),
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

  Widget _uploadTextField(
    TextEditingController controller, {
    File? imageFile,
    String? imageUrl,
    required void Function(File? file) onFileSelected,
  }) {
    final hasImage = imageFile != null ||
        (imageUrl != null && imageUrl.trim().isNotEmpty);

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
            controller.text = file != null ? AppStrings.changeImage : '';
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

  Widget _certificateNetworkImagePreview(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 180.h,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          height: 180.h,
          width: double.infinity,
          color: AppColors.greyBorder,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.greyLight,
          ),
        ),
      ),
    );
  }

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
