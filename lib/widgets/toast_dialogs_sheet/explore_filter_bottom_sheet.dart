import 'package:ezhandy_user/module/core/categories/controller/categories_controller.dart';
import 'package:ezhandy_user/module/core/products/controller/products_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:ezhandy_user/widgets/toast_dialogs_sheet/custom_bottom_sheet.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final CategoriesController _categoriesController =
      Get.find<CategoriesController>();
  final ProductsController _productsController = Get.find<ProductsController>();

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? categoryValue;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    selectedCategoryId = _productsController.filterCategoryId.value;
    final category =
        _categoriesController.getCategoryById(selectedCategoryId);
    if (category != null) {
      categoryValue = category.displayName;
    }

    final minPrice = _productsController.filterMinPrice.value;
    final maxPrice = _productsController.filterMaxPrice.value;
    if (minPrice != null) {
      _minPriceController.text = _formatPriceInput(minPrice);
    }
    if (maxPrice != null) {
      _maxPriceController.text = _formatPriceInput(maxPrice);
    }
  }

  String _formatPriceInput(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomBottomSheet(
        isPadding: true,
        isTopPadding: true,
        title: AppStrings.searchFilter,
        height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.75.sh : 0.45.sh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 1.5),
            10.verticalSpace,
            CustomText(
              text: AppStrings.category,
              fontSize: 16.sp,
            ),
            10.verticalSpace,
            categoryDropDown(),
            10.verticalSpace,
            CustomText(
              text: AppStrings.priceRange,
              fontSize: 16.sp,
            ),
            10.verticalSpace,
            Row(
              children: [
                Expanded(child: minTextField()),
                20.horizontalSpace,
                Expanded(child: maxTextField()),
              ],
            ),
            20.verticalSpace,
            MediaQuery.of(context).viewInsets.bottom > 0
                ? const SizedBox.shrink()
                : btnWidget(),
          ],
        ),
      ),
    );
  }

  Widget categoryDropDown() {
    return Obx(
      () => CustomDropDown2(
        dropDownHeight: 220.h,
        dropDownWidth: .93.sw,
        dropDownData: _categoriesController.categoryDropdownLabels,
        borderRadius: 10.r,
        isPrefix: false,
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

  Widget minTextField() {
    return CustomTextField(
      borderRadius: 8.r,
      divider: false,
      label: false,
      hint: AppStrings.min,
      controller: _minPriceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
    );
  }

  Widget maxTextField() {
    return CustomTextField(
      borderRadius: 8.r,
      divider: false,
      label: false,
      hint: AppStrings.max,
      controller: _maxPriceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
    );
  }

  double? _parsePriceField(TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  void _onReset() {
    _productsController.resetFilters();
    AppNavigation.navigatorPop(context);
  }

  void _onApply() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    final minPrice = _parsePriceField(_minPriceController);
    final maxPrice = _parsePriceField(_maxPriceController);

    if (minText.isNotEmpty && minPrice == null) {
      AppDialogs.showToast(message: AppStrings.enterPrice);
      return;
    }

    if (maxText.isNotEmpty && maxPrice == null) {
      AppDialogs.showToast(message: AppStrings.enterPrice);
      return;
    }

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      AppDialogs.showToast(message: AppStrings.invalidPriceRange);
      return;
    }

    _productsController.applyFilters(
      categoryId: selectedCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    AppNavigation.navigatorPop(context);
  }

  Widget btnWidget() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onclick: _onReset,
            text: "Reset",
            color: AppColors.red,
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: CustomButton(
            onclick: _onApply,
            text: AppStrings.apply,
          ),
        ),
      ],
    );
  }
}
