import 'package:bot_toast/bot_toast.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoader {
  AppLoader._();

  static CancelFunc? _cancel;

  static void show() {
    hide();
    _cancel = BotToast.showCustomLoading(
      toastBuilder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
    );
  }

  static void hide() {
    _cancel?.call();
    _cancel = null;
  }
}
