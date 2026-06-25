import 'dart:developer';
import 'dart:io';

import 'package:ezhandy_user/module/core/categories/controller/categories_controller.dart';
import 'package:ezhandy_user/module/core/products/controller/products_controller.dart';
import 'package:ezhandy_user/module/core/products/model/product_model.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/utils.dart';
import 'package:ezhandy_user/widgets/Container/add_more.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/validator_extensions.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class AddEditProduct extends StatefulWidget {
  final String type;
  final ProductModel? product;

  AddEditProduct({
    required this.type,
    this.product,
    super.key,
  });

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  static const int _maxImages = 5;

  final CategoriesController _categoriesController =
      Get.find<CategoriesController>();
  final ProductsController _productsController = Get.find<ProductsController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool keyboardVisible = false;
  final List<_ProductImageItem> imageItems = [];
  String? categoryValue;
  String? selectedCategoryId;

  bool get _isEditMode => widget.type == AddEditType.edit.name;

  @override
  void initState() {
    super.initState();
    _prefillProduct();
  }

  void _prefillProduct() {
    final product = widget.product;
    if (!_isEditMode || product == null) return;

    productNameController.text = product.title?.trim() ?? '';
    priceController.text = product.price?.trim() ?? '';
    descriptionController.text = product.description?.trim() ?? '';

    selectedCategoryId = product.category?.id?.trim();
    final cachedCategory =
        _categoriesController.getCategoryById(selectedCategoryId);
    if (cachedCategory != null) {
      categoryValue = cachedCategory.displayName;
    } else {
      final categoryTitle = product.category?.title?.trim();
      final categoryName = product.category?.name?.trim();
      categoryValue = (categoryTitle != null && categoryTitle.isNotEmpty)
          ? categoryTitle
          : categoryName;
    }

    final mainImage = product.mainImagePath?.trim();
    if (mainImage != null && mainImage.isNotEmpty) {
      imageItems.add(_ProductImageItem(networkUrl: mainImage));
    }

    for (final imageUrl in product.additionalImages) {
      final trimmed = imageUrl.trim();
      if (trimmed.isEmpty) continue;
      imageItems.add(_ProductImageItem(networkUrl: trimmed));
    }
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    log(keyboardVisible.toString());
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: _isEditMode ? AppStrings.editProduct : AppStrings.addProduct,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(children: [
                      //----------------Email Address Field----------------
                      20.verticalSpace,
                      CustomText(text: "Product Name" + "*"),
                      10.verticalSpace,
                      _productNameTextField(),
                      20.verticalSpace,

                      CustomText(text: AppStrings.category + "*"),
                      10.verticalSpace,
                      categoryDropDown(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.price + "*"),
                      10.verticalSpace,
                      _priceTextField(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.description + "*"),
                      10.verticalSpace,
                      _descriptionField(),
                      20.verticalSpace,
                      CustomText(text: AppStrings.uploadImage + "*"),
                      10.verticalSpace,
                      documentWidget(),
                      20.verticalSpace,

                      //----------------Get Code Button----------------
                    ]),
                  ),
                ),
              ),
              Visibility(
                  visible: !keyboardVisible, child: buttonWidget(context)),
              Visibility(visible: !keyboardVisible, child: 25.verticalSpace)
            ],
          ),
        ));
  }

  void _setCameraDocumentFile(File? file) {
    if (file == null) return;
    if (imageItems.length >= _maxImages) {
      AppDialogs.showToast(message: AppStrings.maximumFiveImagesAllowed);
      return;
    }

    setState(() {
      imageItems.add(_ProductImageItem(localFile: file));
    });
  }

  Widget uploadWidget(length) {
    return AddMore(
      text: length == 0 ? AppStrings.add : AppStrings.addMore,
      // image: AssetPath.plusCircleIcon,
      // size: size,
      height: 60.h, width: 105.w,
      ontap: () {
        AppDialogs.showImageSourceDialog(context,
            setFile: _setCameraDocumentFile);
      },
    );
    //  DottedBorder(
    //   borderType: BorderType.RRect,
    //   padding: EdgeInsets.all(15.sp),
    //   color: AppColors.borderColor,
    //   radius: Radius.circular(15.sp),
    //   strokeWidth: 1,
    //   child: Container(
    //     height: size?.h,
    //     width: size?.w,
    //     child: Column(
    //       children: [
    //         Image.asset(
    //           AssetPath.galleryIcon,
    //           scale: 3.sp,
    //           color: AppColors.borderColor,
    //         ),
    //         CustomText(
    //           is_alignLeft: false,
    //           text: AppStrings.addMore,
    //           color: AppColors.borderColor,
    //           fontsize: 10.sp,
    //         )
    //       ],
    //     ),
    //   ),
    // ),

    // );
  }

  Widget documentWidget() {
    return Container(
      height: 117.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return index == imageItems.length
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: uploadWidget(imageItems.length),
                )
              : _imageCard(
                  item: imageItems[index],
                  onRemoveTapped: () {
                    setState(() {
                      imageItems.removeAt(index);
                    });
                  },
                );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 5,
          );
        },
        itemCount: imageItems.length >= _maxImages
            ? imageItems.length
            : imageItems.length + 1,
      ),
    );
  }

  Widget _imageCard({
    required _ProductImageItem item,
    Function()? onRemoveTapped,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (item.localFile != null) {
              Utils.onTapViewImage(
                context: context,
                image: item.localFile!.path,
                mediaType: MediaPathType.file.name,
              );
              return;
            }

            Utils.onTapViewImage(
              context: context,
              image: item.networkUrl!,
              mediaType: MediaPathType.network.name,
            );
          },
          child: Container(
            height: 110.h,
            width: 110.w,
            margin: EdgeInsets.only(top: 5, right: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.orange),
              borderRadius: BorderRadius.circular(10.sp),
              image: item.localFile != null
                  ? DecorationImage(
                      image: FileImage(item.localFile!),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: NetworkImage(item.networkUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemoveTapped,
              child: Container(
                height: 20.h,
                width: 20.w,
                decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5.sp)
                    // shape: BoxShape.circle,
                    // border: Border.all(color: AppColors.white)
                    ),
                child: Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: 15.sp,
                ),
              ),
            ))
      ],
    );
  }

  Widget categoryDropDown() {
    return Obx(
      () => CustomDropDown2(
        dropDownWidth: .93.sw,
        dropDownData: _categoriesController.categoryDropdownLabels,
        dropDownHeight: 500.h,
        borderRadius: 10.r,
        hintText: AppStrings.selectCategory,
        dropdownValue: categoryValue,
        dropdownListColor: AppColors.white,
        borderColor: AppColors.greyBorder,
        hintTextColor: AppColors.black,
        onChanged: (value) {
          setState(() {
            categoryValue = value.toString();
            selectedCategoryId = _categoriesController
                .getCategoryByDisplayName(categoryValue)
                ?.id;
          });
        },
      ),
    );
  }

  String? _resolveCategoryId() {
    final selectedId = selectedCategoryId?.trim();
    if (selectedId != null && selectedId.isNotEmpty) {
      return selectedId;
    }

    return _categoriesController.getCategoryByDisplayName(categoryValue)?.id;
  }

  Widget _productNameTextField() {
    return CustomTextField(
      hint: "Enter Product Name",
      divider: false,
      // prefxicon: AssetPath.profileCircleIcon,
      label: false,
      // readOnly: true,
      // onTap: () {},
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.nameMaxLength)
      ],
      controller: productNameController,
      validator: (value) => value?.validateEmpty("Product Name"),
      // error_text: error_email,
    );
  }

  Widget _descriptionField() {
    return CustomTextField(
      hint: AppStrings.enterDescription,
      divider: false,
      // prefxicon: AssetPath.convertIcon,
      label: false,
      borderRadius: 10.r,
      lines: 5,
      // keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
      ],
      controller: descriptionController,
      validator: (value) => value?.validateEmpty(AppStrings.description),
      // error_text: error_email,
    );
  }

  Widget _priceTextField() {
    return CustomTextField(
        hint: AppStrings.enterPrice,
        divider: false,
        label: false,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        controller: priceController,
        validator: (value) => value?.validateEmpty(AppStrings.price)
        // error_text: error_email,
        );
  }

  Widget buttonWidget(context) {
    return Obx(
      () => CustomButton(
        text: _isEditMode ? AppStrings.save : AppStrings.add,
        isLoading: _productsController.isSubmittingProduct.value,
        onclick: _onSubmit,
      ),
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (imageItems.isEmpty) {
      AppDialogs.showToast(message: AppStrings.pleaseUploadProductImage);
      return;
    }

    final categoryId = _resolveCategoryId();
    if (categoryId == null || categoryId.isEmpty) {
      AppDialogs.showToast(message: AppStrings.selectCategory);
      return;
    }

    final newImages = imageItems
        .where((item) => item.localFile != null)
        .map((item) => item.localFile!)
        .toList();

    final title = productNameController.text.trim();
    final description = descriptionController.text.trim();
    final price = priceController.text.trim();

    final bool success;
    if (_isEditMode) {
      final productId = widget.product?.id;
      if (productId == null || productId.isEmpty) {
        AppDialogs.showToast(message: 'Unable to update product.');
        return;
      }

      success = await _productsController.editProduct(
        productId: productId,
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        images: newImages,
        isActive: widget.product?.isActive ?? true,
      );
    } else {
      if (newImages.isEmpty) {
        AppDialogs.showToast(message: AppStrings.pleaseUploadProductImage);
        return;
      }

      success = await _productsController.addProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        images: newImages,
      );
    }

    if (!success || !mounted) return;

    AppNavigation.navigatorPop(context);
    AppDialogs.showSuccessDialog(
      context,
      description: _isEditMode
          ? AppStrings.productHasBeenUpdatedSuccessfully
          : AppStrings.productHasBeenAddedSuccessfully,
      title: AppStrings.congratulation,
      btnTxt1: AppStrings.ok,
      onTap1: () {
        AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
      },
    );
  }
}

class _ProductImageItem {
  const _ProductImageItem({
    this.networkUrl,
    this.localFile,
  });

  final String? networkUrl;
  final File? localFile;
}
