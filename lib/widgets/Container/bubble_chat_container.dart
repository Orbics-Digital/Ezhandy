import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/utils.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ChatBubble extends StatelessWidget {
  final String text, name;
  final bool isSender;
  final String? profileImage;
  final String? imagePath;

  const ChatBubble({
    required this.text,
    required this.name,
    required this.isSender,
    this.profileImage,
    this.imagePath,
    Key? key,
  }) : super(key: key);

  String? get _displayImage {
    final image = profileImage?.trim();
    if (image == null || image.isEmpty) return null;
    return image;
  }

  bool get _hasMessageImage {
    final path = imagePath?.trim();
    return path != null && path.isNotEmpty;
  }

  Widget _messageContent(BuildContext context) {
    if (!_hasMessageImage) {
      return CustomText(
        text: text,
        color: AppColors.grey,
      );
    }

    final path = imagePath!.trim();
    final isNetwork =
        path.startsWith('http://') || path.startsWith('https://');

    return GestureDetector(
      onTap: () => Utils.onTapViewImage(
        context: context,
        image: path,
        mediaType: isNetwork
            ? MediaPathType.network.name
            : MediaPathType.file.name,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: isNetwork
            ? Image.network(
                path,
                width: 200.w,
                height: 150.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _imageLoadingPlaceholder();
                },
              )
            : Image.file(
                File(path),
                width: 200.w,
                height: 150.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageErrorPlaceholder(),
              ),
      ),
    );
  }

  Widget _imageLoadingPlaceholder() {
    return Container(
      width: 200.w,
      height: 150.h,
      color: AppColors.grey.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: AppColors.orange,
        strokeWidth: 2,
      ),
    );
  }

  Widget _imageErrorPlaceholder() {
    return Container(
      width: 200.w,
      height: 150.h,
      color: AppColors.grey.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isSender) UserImageWidget(image: _displayImage),
        if (isSender) 10.horizontalSpace,
        Container(
          width: 250.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topRight: isSender ? Radius.circular(16) : Radius.circular(0),
              topLeft: isSender ? Radius.circular(0) : Radius.circular(16),
            ),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: name,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              4.verticalSpace,
              _messageContent(context),
            ],
          ),
        ),
        if (!isSender) 10.horizontalSpace,
        if (!isSender) UserImageWidget(image: _displayImage),
      ],
    );
  }
}
