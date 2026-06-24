import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/contact_us/controller/contact_us_controller.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ContactUs extends StatefulWidget {
  ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final ContactUsController _controller;

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ContactUsController());
    final user = AuthController.i.user.value;
    if (user != null) {
      final name = user.fullName?.trim();
      if (name != null && name.isNotEmpty) {
        userNameController.text = name;
      }
      final email = user.email?.trim();
      if (email != null && email.isNotEmpty) {
        emailController.text = email;
      }
    }
  }

  @override
  void dispose() {
    Get.delete<ContactUsController>();
    userNameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.contactUs,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(children: [
                      //----------------Email Address Field----------------
                      20.verticalSpace,
                      CustomText(
                          text: AppStrings
                              .pleaseLetUsKnowHowWeCanImproveYourExperience),
                      20.verticalSpace,
                      CustomText(text: AppStrings.username + "*"),
                      10.verticalSpace,
                      _userNameTextField(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.emailAddress + "*"),
                      10.verticalSpace,
                      _emailTextField(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.subject + "*"),
                      10.verticalSpace,
                      _subjectField(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.message + "*"),
                      10.verticalSpace,
                      _messageField(),
                      20.verticalSpace,
                      //----------------Get Code Button----------------
                    ]),
                  ),
                ),
              ),
              buttonWidget(context),
              25.verticalSpace,
            ],
          ),
        ));
  }

  Widget _userNameTextField() {
    return CustomTextField(
      hint: AppStrings.enterUserName,
      divider: false,
      prefxicon: AssetPath.profileCircleIcon,
      label: false,
      // readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: userNameController,
      validator: (value) => value?.validateEmpty(AppStrings.username),
      // error_text: error_email,
    );
  }

  Widget _messageField() {
    return CustomTextField(
      hint: AppStrings.enterMessage,
      divider: false,
      // prefxicon: AssetPath.convertIcon,
      label: false,
      borderRadius: 10.r,
      lines: 5,
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
      ],
      controller: messageController,
      validator: (value) => value?.validateEmpty(AppStrings.message),
      // error_text: error_email,
    );
  }


  Widget _subjectField() {
    return CustomTextField(
      hint: AppStrings.enterSubject,
      divider: false,
      prefxicon: AssetPath.convertIcon,
      label: false,

      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: subjectController,
      validator: (value) => value?.validateEmpty(AppStrings.subject),
      // error_text: error_email,
    );
  }

  Widget _emailTextField() {
    return CustomTextField(
      hint: AppStrings.emailAddress,
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

  Widget buttonWidget(context) {
    return Obx(
      () => CustomButton(
        text: AppStrings.submit,
        isLoading: _controller.isSubmitting.value,
        onclick: () async {
          FocusScope.of(context).unfocus();
          final isValid = formKey.currentState!.validate();
          if (!isValid) {
            return;
          }
          formKey.currentState!.save();

          final success = await _controller.submitQuery(
            context,
            subject: subjectController.text,
            message: messageController.text,
          );

          if (success) {
            subjectController.clear();
            messageController.clear();
          }
        },
      ),
    );
  }
}
