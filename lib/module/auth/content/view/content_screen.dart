// ignore_for_file: must_be_immutable

import 'package:ezhandy_user/module/auth/content/controller/pages_controller.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContentScreen extends StatefulWidget {
  String? title;
  String? type;

  ContentScreen({super.key, this.title, this.type});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final PagesController _controller = PagesController.i;

  @override
  void initState() {
    super.initState();
    final slug = PagesController.slugFromContentType(widget.type);
    if (slug != null) {
      _controller.fetchPage(slug);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: widget.title,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: contentWidget(),
      ),
    );
  }

  Widget contentWidget() {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      final page = _controller.currentPage.value;
      final htmlContent = page?.content?.trim() ?? '';

      if (isLoading && page == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }

      if (htmlContent.isEmpty) {
        return const EmptyMessage(message: AppStrings.noResultsFound);
      }

      return SingleChildScrollView(
        child: Html(
          data: htmlContent,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(14.sp),
              color: AppColors.black,
            ),
            'p': Style(
              margin: Margins.only(bottom: 10.h),
              lineHeight: const LineHeight(1.5),
            ),
            'h1': Style(
              fontSize: FontSize(20.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 12.h, top: 8.h),
            ),
            'h2': Style(
              fontSize: FontSize(18.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 10.h, top: 8.h),
            ),
            'h3': Style(
              fontSize: FontSize(16.sp),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 8.h, top: 6.h),
            ),
            'ul': Style(
              margin: Margins.only(bottom: 10.h),
              padding: HtmlPaddings.only(left: 18.w),
            ),
            'ol': Style(
              margin: Margins.only(bottom: 10.h),
              padding: HtmlPaddings.only(left: 18.w),
            ),
            'li': Style(
              margin: Margins.only(bottom: 6.h),
            ),
            'a': Style(
              color: AppColors.orange,
              textDecoration: TextDecoration.underline,
            ),
          },
        ),
      );
    });
  }
}
