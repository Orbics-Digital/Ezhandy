import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExtraTimeDialog extends StatefulWidget {
  const ExtraTimeDialog({
    super.key,
    this.title,
    this.btnTxt1,
    this.btnTxt2,
    this.image,
    this.barrierDismissible = true,
    this.onTap1,
    this.onTap2,
  });

  final void Function(String amount, String notes)? onTap1;
  final VoidCallback? onTap2;
  final String? title;
  final String? btnTxt1;
  final String? btnTxt2;
  final String? image;
  final bool barrierDismissible;

  @override
  State<ExtraTimeDialog> createState() => _ExtraTimeDialogState();
}

class _ExtraTimeDialogState extends State<ExtraTimeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
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
                child: Form(
                  key: _formKey,
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
                      CustomText(text: AppStrings.amount),
                      10.verticalSpace,
                      CustomTextField(
                        hint: AppStrings.enterAmount,
                        divider: false,
                        label: false,
                        borderRadius: 10.r,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                          LengthLimitingTextInputFormatter(8),
                        ],
                        controller: _amountController,
                        validator: (value) =>
                            value?.validateEmpty(AppStrings.amount),
                      ),
                      15.verticalSpace,
                      CustomText(text: AppStrings.notes),
                      10.verticalSpace,
                      CustomTextField(
                        hint: AppStrings.enterNotes,
                        divider: false,
                        label: false,
                        borderRadius: 10.r,
                        lines: 4,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            Constants.descriptionMaxLength,
                          ),
                        ],
                        controller: _notesController,
                        validator: (value) =>
                            value?.validateEmpty(AppStrings.notes),
                      ),
                      30.verticalSpace,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              borderRadius: 35.r,
                              text: widget.btnTxt1 ?? AppStrings.submit,
                              onclick: () {
                                if (!_formKey.currentState!.validate()) return;
                                widget.onTap1?.call(
                                  _amountController.text.trim(),
                                  _notesController.text.trim(),
                                );
                              },
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: CustomButton(
                              borderRadius: 35.r,
                              text: widget.btnTxt2 ?? AppStrings.cancel,
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
      ),
    );
  }
}
