import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const EmptyMessage({
    super.key,
    required this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CustomText(
          text: message,
          is_alignLeft: false,
          color: AppColors.grey,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
