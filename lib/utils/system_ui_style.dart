import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSystemUi {
  AppSystemUi._();

  static const darkContent = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const lightContent = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static void applyDarkContent() {
    SystemChrome.setSystemUIOverlayStyle(darkContent);
  }

  static void applyLightContent() {
    SystemChrome.setSystemUIOverlayStyle(lightContent);
  }
}
