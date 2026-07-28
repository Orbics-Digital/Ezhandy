import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/module/auth/verification/widget/verification_selection_form.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';

class VerificationSelection extends StatelessWidget {String? type;
   VerificationSelection({this.type,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      // appBarheight: 50.h,
      // title: AppStrings.forgotPassword,
      // is_registration: true,
      //----------------Form----------------
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: VerificationSelectionForm(type: type),
            ),
          );
        },
      ),
    );
  }
}
