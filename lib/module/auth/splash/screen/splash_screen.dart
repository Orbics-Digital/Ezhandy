import 'dart:async';

import 'package:ezhandy_user/core/notification/firebase_messaging_service.dart';
import 'package:ezhandy_user/core/socket/socket_service.dart';
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/verification/routing_arguments/otp_verification_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/app_logo.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezhandy_user/utils/system_ui_style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _initSharedPreference() async {
    // await SharedPreference().sharedPreference;
  }

  @override
  void initState() {
    _initSharedPreference();
    registeredNotificationListener();
    socketConnect();
    AppSystemUi.applyLightContent();
    Timer(const Duration(seconds: 4), () => _onComplete());
    super.initState();
  }

  void socketConnect() {
    if (AuthController.i.user.value != null) {
      SocketService.i.connect();
    }
  }

  void registeredNotificationListener() {
    final messaging = FirebaseMessagingService.instance;
    messaging.initializeNotificationSettings();
    messaging.terminateTapNotification();
    messaging.foregroundNotification();
    messaging.backgroundTapNotification();
  }

  Future<void> _onComplete() async {
    AppSystemUi.applyDarkContent();
    final user = AuthController.i.user.value;
    if (user == null) {
      AppNavigation.navigateToRemovingAll(context, AppRoutes.loginScreenRoute);
      return;
    }

    if (!user.isEmailVerified) {
      await SessionStorage.i.clear();
      AuthController.i.user.value = null;
      if (!mounted) return;
      AppNavigation.navigateToRemovingAll(
        context,
        AppRoutes.otpVerificationScreenRoute,
        arguments: OtpVerificationRoutingArgument(
          type: OtpType.signup.name,
          text: user.email?.trim() ?? '',
          emailAndPhone: OtpCodeType.email.name,
        ),
      );
      return;
    }

    final destination = !user.isSubscription
        ? AppRoutes.subscriptionScreenRoute
        : AppRoutes.mainMenuScreenRoute;
    AppNavigation.navigateToRemovingAll(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightContent,
      sized: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: 1.sw,
          height: 1.sh,
          decoration: const BoxDecoration(
              color: AppColors.black
              // image: DecorationImage(
              //     image: AssetImage(AssetPath.splashImage), fit: BoxFit.cover)
              ),
          child: logoWidget(),
        ),
      ),
    );
  }

  Widget logoWidget() {
    return Entry.scale(
        duration: Duration(seconds: 3),
        child: AppLogo(assetPath: AssetPath.splashLogoImage, scale: 3.5.sp));
  }
}
