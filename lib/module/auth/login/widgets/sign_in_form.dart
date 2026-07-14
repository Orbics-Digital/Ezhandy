// ignore_for_file: must_be_immutable
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/verification/routing_arguments/otp_verification_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/app_logo.dart';
import 'package:ezhandy_user/widgets/switch/animated_switch.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/rich_text_widget.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInForm extends StatefulWidget {
  bool keyboardVisible;
  SignInForm({required this.keyboardVisible, super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  String? error_email;

  /// Form Key
  final GlobalKey<FormState> signInKey = GlobalKey<FormState>();

  /// Text Editing Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final credentials = await SessionStorage.i.loadRememberedCredentials();
    if (!mounted || credentials == null) return;

    setState(() {
      rememberMe = true;
      emailController.text = credentials.email;
      passwordController.text = credentials.password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.padding16,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: widget.keyboardVisible ? 16 : 25,
        ),
        child: Column(
          children: [
            AppLogo(scale: 3.5.sp),
            15.verticalSpace,
            signInTextWidget(),
            5.verticalSpace,
            CustomText(
              text: AppStrings.accountDetails,
              is_alignLeft: false,
            ),
            25.verticalSpace,
            Form(
              key: signInKey,
              child: Column(
                children: [
                  CustomText(text: AppStrings.email),
                  10.verticalSpace,
                  _emailTextField(),
                  SizedBox(height: 0.02.sh),
                  CustomText(text: AppStrings.password),
                  10.verticalSpace,
                  _passwordTextField(),
                  SizedBox(height: 0.02.sh),
                  _rememberMeForgetPasswordRow(context: context),
                  SizedBox(height: 0.04.sh),
                  _signInButton(context: context),
                  SizedBox(height: 0.02.sh),
                ],
              ),
            ),
            Visibility(
              visible: !widget.keyboardVisible,
              child: dontHaveAnAccountWidget(),
            ),
          ],
        ),
      ),
    );
  }

  // Row otherMethodsWidget() {
  //   return Row(
  //     children: [
  //       Expanded(
  //           child: CustomContainer(
  //               height: 50.h,
  //               child: Image.asset(AssetPath.googleIcon, scale: 3.r))),
  //       10.horizontalSpace,
  //       Platform.isAndroid
  //           ? SizedBox.shrink()
  //           : Expanded(
  //               child: CustomContainer(
  //                   height: 50.h,
  //                   child: Image.asset(AssetPath.appleIcon, scale: 3.r))),
  //     ],
  //   );
  // }

  CustomText signInTextWidget() {
    return CustomText(
      text: AppStrings.welcomeBack,
      is_alignLeft: false,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    );
  }

  // CustomText orWidget() {
  //   return CustomText(
  //     text: AppStrings.orContinueWith,
  //     is_alignLeft: false,
  //     // color: AppColors.white,
  //   );
  // }

  Widget _passwordTextField() {
    return CustomTextField(
        divider: false,
        label: false,
        hint: AppStrings.password,
        prefxicon: AssetPath.lockIcon,
        inputFormatters: [LengthLimitingTextInputFormatter(35)],
        obscureText: FieldValidator.isHidepassword,
        sufixImage: Icon(
          FieldValidator.isHidepassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: AppColors.orange,
        ),
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

  Widget dontHaveAnAccountWidget() {
    return RichTextWidget(
        text: AppStrings.dontHaveAnAccount,
        subText: AppStrings.signUp,
        onSubTextPress: () {
          FocusScope.of(context).unfocus();
          AppNavigation.navigateTo(context, AppRoutes.signupScreenRoute);
          // Get.toNamed(Paths.SIGNUP_SCREEN_ROUTE);
        });
  }

  Widget _rememberMeForgetPasswordRow({BuildContext? context}) {
    return Row(
      children: [
        AnimatedSwitch(
          isSwitched: rememberMe,
          onCallBack: (value) {
            setState(() => rememberMe = value);
          },
        ),
        10.w.horizontalSpace,
        CustomText(
          text: AppStrings.rememberMe,
          // fontSize: 14.0.sp,
          is_alignLeft: false,
          // color: AppColors.white,
          // align: Alignment.centerRight,
        ),
        Spacer(),
        _forgetPassword(context),
      ],
    );
  }

  GestureDetector _forgetPassword(BuildContext? context) {
    return GestureDetector(
      onTap: (() {
        emailController.clear();
        passwordController.clear();
        signInKey.currentState?.reset();
        FocusScope.of(context!).unfocus();
        AppNavigation.navigateTo(
            context, AppRoutes.verificationSelectionScreenRoute,
            arguments:
                OtpVerificationRoutingArgument(type: OtpType.forget.name));
      }),
      child: CustomText(
        text: '${AppStrings.forgotYourPassword}?',
        // fontSize: 14.0.sp,
        is_alignLeft: false,
        color: AppColors.orange,
        textDecoration: TextDecoration.underline,
        // align: Alignment.centerRight,
      ),
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

  Widget _signInButton({required BuildContext context}) {
    return Obx(
      () => CustomButton(
        text: AppStrings.signIn,
        isLoading: AuthController.i.isLoginLoading.value,
        onclick: () async {
          FocusScope.of(context).unfocus();
          if (!signInKey.currentState!.validate()) return;

          final success = await AuthController.i.signIn(
            context,
            email: emailController.text,
            password: passwordController.text,
          );

          if (success) {
            if (rememberMe) {
              await SessionStorage.i.saveRememberedCredentials(
                email: emailController.text,
                password: passwordController.text,
              );
            } else {
              await SessionStorage.i.clearRememberedCredentials();
            }
          }
        },
      ),
    );
  }
}
