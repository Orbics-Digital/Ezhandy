import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:ezhandy_user/utils/app_colors.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  /// Form Key
  final GlobalKey<FormState> rsesetpassKey = GlobalKey<FormState>();

  /// Text Editing Controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: rsesetpassKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
          child: Column(children: [
            //----------------Email Address Field----------------
            CustomText(text: AppStrings.oldPassword + "*"),
            10.verticalSpace,
            _oldPasswordTextField(),
            20.verticalSpace,
            CustomText(text: AppStrings.newPassword + "*"),
            10.verticalSpace,
            _passwordTextField(),
            20.verticalSpace,
            CustomText(text: AppStrings.confirmPassword + "*"),
            10.verticalSpace,
            _confirmPasswordTextField(),
            SizedBox(height: 30.h),
            //----------------Get Code Button----------------
            buttonWidget(context),
          ]),
        ),
      ),
    );
  }

  Widget _oldPasswordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.enterYourOldPassword,
        prefxicon: AssetPath.lockIcon,
        inputFormatters: [LengthLimitingTextInputFormatter(35)],
        sufixImage: Icon(
          FieldValidator.isHideoldpassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: AppColors.orange,
        ),
        obscureText: FieldValidator.isHideoldpassword,
        onclickSufix: () {
          setState(() {
            FieldValidator.oldPasswordHideIcon();
          });
        },
        controller: oldPasswordController,
        validator: (value) {
          return FieldValidator.validateLoginPassword(
              value!, AppStrings.oldPassword);
        });
  }

  Widget _passwordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.enterYourNewPassword,
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
          return FieldValidator.validateLoginPassword(
              value!, AppStrings.newPassword);
        });
  }

  Widget _confirmPasswordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.EnterYourConfirmPassword,
        prefxicon: AssetPath.lockIcon,
        // prefixRIghtPadding: 8.w,
        inputFormatters: [LengthLimitingTextInputFormatter(35)],
        sufixImage: Icon(
          FieldValidator.isHideconfirmpassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
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

  Widget buttonWidget(context) {
    return Obx(
      () => CustomButton(
        text: AppStrings.update,
        isLoading: AuthController.i.isChangePasswordLoading.value,
        onclick: () async {
          final isValid = rsesetpassKey.currentState!.validate();
          if (!isValid) return;

          rsesetpassKey.currentState!.save();
          FocusScope.of(context).unfocus();

          final success = await AuthController.i.changePassword(
            currentPassword: oldPasswordController.text,
            newPassword: passwordController.text,
          );
          if (!success || !context.mounted) return;

          oldPasswordController.clear();
          passwordController.clear();
          confirmPasswordController.clear();

          AppDialogs.showSuccessDialog(
            context,
            description: AppStrings.passwordHasBeenUpdated,
            title: AppStrings.congratulation,
            btnTxt1: AppStrings.ok,
            onTap1: () {
              AppNavigation.navigateToRemovingAll(
                context,
                AppRoutes.userProfileScreenRoute,
              );
            },
          );
        },
      ),
    );
  }
}
