import 'dart:async';

import 'package:ezhandy_user/core/socket/socket_service.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
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
    // FirebaseMessagingService().initializeNotificationSettings();
    // print("registeredNotificationListener");
    // //Firebase Notification registered for app in background when it is terminated
    // FirebaseMessagingService().terminateTapNotification();

    // //Firebase Notification registered for foreground
    // FirebaseMessagingService().foregroundNotification();

    // //Firebase Notification registered for background
    // FirebaseMessagingService().backgroundTapNotification();
  }

  void _onComplete() {
    AppSystemUi.applyDarkContent();
    final user = AuthController.i.user.value;
    final String destination;
    if (user == null) {
      destination = AppRoutes.loginScreenRoute;
    } else if (!user.isSubscription) {
      destination = AppRoutes.subscriptionScreenRoute;
    } else {
      destination = AppRoutes.mainMenuScreenRoute;
    }
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

  // CustomButton buttonWidget() {
  //   return CustomButton(
  //     onclick: () {
  //       AppNavigation.navigateToRemovingAll(
  //           context, AppRoutes.selectUserScreenRoute);
  //     },
  //     text: AppStrings.getStarted,
  //     color: AppColors.white,
  //     textcolor: AppColors.purple,
  //   );
  // }

  // Widget descriptionWidget() {
  //   return CustomText(
  //     text: AppStrings.lorem5,
  //     color: AppColors.white,
  //     is_alignLeft: false,
  //   );
  // }

  Widget logoWidget() {
    return Entry.scale(
        duration: Duration(seconds: 3),
        child: AppLogo(assetPath: AssetPath.splashLogoImage, scale: 3.5.sp));
  }
}
