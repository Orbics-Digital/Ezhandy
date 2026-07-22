import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class CustomRejectDialog extends StatefulWidget {
  const CustomRejectDialog({
    super.key,
    this.title,
    this.btnTxt1,
    this.btnTxt2,
    this.image,
    this.barrierDismissible = false,
    required this.isDoneShow,
    this.onTap1,
    this.onTap2,
  });

  final void Function(String reason)? onTap1;
  final VoidCallback? onTap2;
  final String? title;
  final String? btnTxt1;
  final String? btnTxt2;
  final String? image;
  final bool isDoneShow;
  final bool barrierDismissible;

  @override
  State<CustomRejectDialog> createState() => _CustomRejectDialogState();
}

class _CustomRejectDialogState extends State<CustomRejectDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom - 32.h;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        left: AppPadding.padding18,
        right: AppPadding.padding18,
        bottom: viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Align(
        alignment: Alignment.center,
        child: Material(
          color: AppColors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      widget.image ?? AssetPath.checkIcon,
                      scale: 4.sp,
                    ),
                    if (widget.title != null) ...[
                      10.verticalSpace,
                      CustomText(
                        text: widget.title,
                        textDecoration: TextDecoration.none,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                        is_alignLeft: false,
                      ),
                      10.verticalSpace,
                    ],
                    CustomText(
                      text: 'Write Reason',
                      textDecoration: TextDecoration.none,
                    ),
                    10.verticalSpace,
                    CustomTextField(
                      hint: 'Write here',
                      divider: false,
                      label: false,
                      borderRadius: 10.r,
                      lines: 5,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          Constants.descriptionMaxLength,
                        ),
                      ],
                      controller: _reasonController,
                      validator: (value) =>
                          value?.validateEmpty(AppStrings.message),
                    ),
                    30.verticalSpace,
                    if (!widget.isDoneShow)
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              borderRadius: 35.r,
                              text: widget.btnTxt1 ?? '',
                              onclick: () {
                                widget.onTap1
                                    ?.call(_reasonController.text.trim());
                              },
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: CustomButton(
                              borderRadius: 35.r,
                              text: widget.btnTxt2 ?? '',
                              onclick: widget.onTap2,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
