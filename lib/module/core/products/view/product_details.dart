import 'package:carousel_slider/carousel_slider.dart';
import 'package:ezhandy_user/module/core/products/model/product_model.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _current = 0;

  ProductModel get product => widget.product;

  List<String> get imagePathList {
    final images = <String>[];
    final mainImage = product.mainImagePath?.trim();
    if (mainImage != null && mainImage.isNotEmpty) {
      images.add(mainImage);
    }

    for (final image in product.additionalImages) {
      final trimmed = image.trim();
      if (trimmed.isEmpty || images.contains(trimmed)) continue;
      images.add(trimmed);
    }

    return images;
  }

  String get _categoryLabel {
    final title = product.category?.title?.trim();
    if (title != null && title.isNotEmpty) return title;

    return DisplayHelper.displayValue(product.category?.name);
  }

  String _formatPrice(String? price) {
    final value = price?.trim();
    if (value == null || value.isEmpty) return '\$ 0.00';
    return '\$ $value';
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      extendBodyBehindAppBar: true,
      title: AppStrings.productDetails,
      titleColor: AppColors.white,
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      child: Column(
        children: [
          slider_container(),
          detailsContainerWidget(),
        ],
      ),
    );
  }

  Widget detailsContainerWidget() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      text: DisplayHelper.displayValue(product.title),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  CustomText(
                    text: _formatPrice(product.price),
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                    color: AppColors.orange,
                  ),
                ],
              ),
              10.verticalSpace,
              if ((product.category?.description?.trim().isNotEmpty ?? false))
                CustomText(
                  text: DisplayHelper.displayValue(product.category?.description),
                ),
              if ((product.category?.description?.trim().isNotEmpty ?? false))
                10.verticalSpace,
              CustomText(
                text: '${AppStrings.category}: $_categoryLabel',
              ),
              10.verticalSpace,
              CustomText(
                text: AppStrings.description,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              10.verticalSpace,
              CustomText(
                text: DisplayHelper.displayValue(product.description),
              ),
              20.verticalSpace,
              CustomText(
                text: 'Seller Details:',
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              const Divider(),
              detailsRow(
                image: AssetPath.profileCircleIcon,
                title: DisplayHelper.displayValue(product.owner?.fullName),
              ),
              10.verticalSpace,
              detailsRow(
                image: AssetPath.callIcon,
                title: DisplayHelper.displayValue(product.owner?.mobileNumber),
              ),
              10.verticalSpace,
              detailsRow(
                image: AssetPath.emailIcon,
                title: DisplayHelper.displayValue(product.owner?.email),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding detailsRow({required String image, required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 20.w,
            height: 20.h,
            color: AppColors.orange,
          ),
          10.horizontalSpace,
          Expanded(
            child: CustomText(
              text: title,
            ),
          ),
        ],
      ),
    );
  }

  Widget slider_container() {
    final images = imagePathList;

    return Stack(
      children: [
        images.isEmpty
            ? Container(
                height: 0.3.sh,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetPath.tempImage1),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  height: 0.3.sh,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                items: images.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.transparent,
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
        if (images.length > 1)
          Positioned(bottom: 10, right: 0, left: 0, child: slider_dots()),
      ],
    );
  }

  Widget slider_dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: imagePathList.asMap().entries.map((entry) {
        return Container(
          width: 20.0.w,
          height: 5.0.h,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: _current == entry.key
                  ? AppColors.transparent
                  : AppColors.white,
            ),
            borderRadius: BorderRadius.circular(5.sp),
            color: _current == entry.key ? AppColors.orange : AppColors.white,
          ),
        );
      }).toList(),
    );
  }
}
