import 'dart:developer';
import 'dart:io';

import 'package:ezhandy_user/module/core/categories/controller/categories_controller.dart';
import 'package:ezhandy_user/module/core/products/controller/products_controller.dart';
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
  String type;
  AddEditProduct({required this.type, super.key});

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
  final List<File> documentList = [];
  String? categoryValue;

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
        title: AddEditType.add.name == widget.type
            ? AppStrings.addProduct
            : AppStrings.editProduct,
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

  _setCameraDocumentFile(File? file) {
    if (file == null) return;
    if (documentList.length >= _maxImages) {
      AppDialogs.showToast(message: AppStrings.maximumFiveImagesAllowed);
      return;
    }

    setState(() {
      documentList.add(file);
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
          return index == documentList.length
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: uploadWidget(documentList.length),
                )
              : _imageCard(
                  image: documentList[index].path,
                  onRemoveTapped: () {
                    setState(() {
                      documentList.removeAt(index);
                    });
                  },
                );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 5,
          );
        },
        itemCount: documentList.length >= _maxImages
            ? documentList.length
            : documentList.length + 1,
      ),
    );
  }

  Widget _imageCard({required String image, Function()? onRemoveTapped}) {
    print(image);
    print(image.split('.').last.toString() + " Pdf Print");
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Utils.onTapViewImage(
              context: context,
              image: image,
              //mediaType: MediaPathType.network.name,
              mediaType: MediaPathType.file.name,
            );
          },
          child: Container(
            height: 110.h,
            width: 110.w,
            margin: EdgeInsets.only(top: 5, right: 5),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.orange),
                borderRadius: BorderRadius.circular(10.sp),
                image: DecorationImage(
                    image: FileImage(File(image)), fit: BoxFit.cover)),
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
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.selectCategory;
          }
          return null;
        },
      ),
    );
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
        text: AddEditType.add.name == widget.type
            ? AppStrings.add
            : AppStrings.save,
        isLoading: _productsController.isSubmittingProduct.value,
        onclick: _onSubmit,
      ),
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (AddEditType.add.name != widget.type) {
      AppNavigation.navigatorPop(context);
      AppDialogs.showSuccessDialog(
        context,
        description: AppStrings.productHasBeenUpdatedSuccessfully,
        title: AppStrings.congratulation,
        btnTxt1: AppStrings.ok,
        onTap1: () {
          AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
        },
      );
      return;
    }

    if (documentList.isEmpty) {
      AppDialogs.showToast(message: AppStrings.pleaseUploadProductImage);
      return;
    }

    final category =
        _categoriesController.getCategoryByDisplayName(categoryValue);
    if (category?.id == null) {
      AppDialogs.showToast(message: AppStrings.selectCategory);
      return;
    }

    final success = await _productsController.addProduct(
      title: productNameController.text.trim(),
      description: descriptionController.text.trim(),
      price: priceController.text.trim(),
      categoryId: category!.id!,
      images: List<File>.from(documentList),
    );

    if (!success || !mounted) return;

    AppNavigation.navigatorPop(context);
    AppDialogs.showSuccessDialog(
      context,
      description: AppStrings.productHasBeenAddedSuccessfully,
      title: AppStrings.congratulation,
      btnTxt1: AppStrings.ok,
      onTap1: () {
        AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
      },
    );
  }
}
