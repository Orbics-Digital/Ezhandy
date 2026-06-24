import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/contact_us/data/contact_us_repository.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactUsController extends GetxController {
  final ContactUsRepository _repository = ContactUsRepository();

  final RxBool isSubmitting = false.obs;

  Future<bool> submitQuery(
    BuildContext context, {
    required String subject,
    required String message,
  }) async {
    if (isSubmitting.value) return false;

    isSubmitting.value = true;
    try {
      await _repository.submitQuery(
        subject: subject.trim(),
        message: message.trim(),
      );

      if (context.mounted) {
        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.yourMessageHasBeenSubmittedSuccessfully,
          title: AppStrings.congratulation,
          btnTxt1: AppStrings.ok,
          onTap1: () {
            AppNavigation.navigatorPopUntil(
              context,
              AppRoutes.mainMenuScreenRoute,
            );
          },
        );
      }
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
