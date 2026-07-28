import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/verification/routing_arguments/otp_verification_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/asset_path.dart';import 'package:ezhandy_user/widgets/logo_and_backgrounds/app_logo.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';

class VerificationSelectionForm extends StatefulWidget {
  String? type;
  VerificationSelectionForm({this.type, super.key});

  @override
  State<VerificationSelectionForm> createState() =>
      _VerificationSelectionFormState();
}

class _VerificationSelectionFormState extends State<VerificationSelectionForm> {
  /// Form Key
  final GlobalKey<FormState> verificationFormKey = GlobalKey<FormState>();

  /// Text Editing Controllers
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Non-scrollable content (e.g., logo)
          AppLogo(scale: 3.5.sp),
          15.verticalSpace,
          signInTextWidget(),
          5.verticalSpace,
          CustomText(
              text: AppStrings.pleaseEnterYourEmailToContinue,
              is_alignLeft: false),

          25.verticalSpace,
          Form(
            key: verificationFormKey,
            child: Column(children: [
              CustomText(text: '${AppStrings.emailAddress}*'),
              10.verticalSpace,
              _emailTextField(),
              SizedBox(height: 30.h),
              //----------------Get Code Button----------------
              buttonWidget(context),
            ]),
          ),
        ],
      ),
    );
  }

  CustomText signInTextWidget() {
    return CustomText(
      text: AppStrings.forgotYourPassword,
      is_alignLeft: false,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    );
  }

  // Align dividerWidget() {
  Widget _emailTextField() {
    return CustomTextField(
      label: false,
      divider: false,
      hint: AppStrings.enterEmailAddress,
      prefxicon: AssetPath.emailIcon,
      inputFormatters: [LengthLimitingTextInputFormatter(35)],
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      validator: (value) => value?.validateEmail,
    );
  }

  Widget buttonWidget(context) {
    return Obx(
      () => CustomButton(
        text: AppStrings.continuee,
        isLoading: AuthController.i.isForgotPasswordLoading.value,
        onclick: () async {
          final isValid = verificationFormKey.currentState!.validate();
          if (!isValid) return;

          verificationFormKey.currentState!.save();
          FocusScope.of(context).unfocus();

          final success = await AuthController.i.forgotPassword(
            email: emailController.text,
          );
          if (!success || !context.mounted) return;

          AppDialogs.showToast(message: AppStrings.otpSendedToYourEmail);
          AppNavigation.navigateTo(
            context,
            AppRoutes.otpVerificationScreenRoute,
            arguments: OtpVerificationRoutingArgument(
              type: widget.type,
              text: emailController.text.trim(),
              emailAndPhone: OtpCodeType.email.name,
            ),
          );
        },
      ),
    );
  }
}