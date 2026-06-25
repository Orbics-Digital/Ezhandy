import 'package:ezhandy_user/module/core/categories/controller/categories_controller.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:ezhandy_user/widgets/toast_dialogs_sheet/custom_bottom_sheet.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:csc_picker/csc_picker.dart';

// ignore: must_be_immutable
class FilterBottomSheet extends StatefulWidget {
  FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final CategoriesController _categoriesController =
      Get.find<CategoriesController>();

  String? countryValue;
  String? stateValue;
  String? cityValue;

  String? errorCity = '';
  String? errorCountry = '';
  String? errorState = '';

  String? categoryValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomBottomSheet(
        isPadding: true,
        isTopPadding: true,
        // isGradient: true,
        // showBar: true,
        // showCross: true,
        title: AppStrings.searchFilter,
        // titleColor: AppColors.white,
        height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.95.sh : 0.65.sh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(thickness: 1.5),
            10.verticalSpace,
            CustomText(
              text: AppStrings.category,
              // color: AppColors.white,
              fontSize: 16.sp,
            ),
            10.verticalSpace,
            categoryDropDown(),
            10.verticalSpace,
            cscPickerField(),
            10.verticalSpace,
            CustomText(
                text: AppStrings.priceRange,
                // color: AppColors.white,
                fontSize: 16.sp),
            10.verticalSpace,
            Row(
              children: [
                Expanded(child: minTextField()),
                20.horizontalSpace,
                Expanded(child: maxTextField())
              ],
            ),
            20.verticalSpace,
            .03.sh.verticalSpace,
            MediaQuery.of(context).viewInsets.bottom > 0
                ? SizedBox.shrink()
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

  Widget minTextField() {
    return CustomTextField(
      borderRadius: 8.r,
      // fillColor: AppColors.white,
      // fontColor: AppColors.black,
      // hintColor: AppColors.blueDark,
      // // prefixIconColor: AppColors.fontColor,
      // borderColor: AppColors.greyBorder,
      divider: false,
      label: false,
      // prefxicon: AssetPath.searchIcon,

      hint: AppStrings.min,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ],
      // controller: firstNameController,
    );
  }

  Widget maxTextField() {
    return CustomTextField(
      borderRadius: 8.r,
      // fillColor: AppColors.white,
      // fontColor: AppColors.black,
      // prefixIconColor: AppColors.fontColor,
      // borderColor: AppColors.greyBorder,
      divider: false,
      label: false,
      // prefxicon: AssetPath.searchIcon,

      hint: AppStrings.max,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ],
      // controller: firstNameController,
    );
  }

  Widget btnWidget() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            // /boxShadow: AppShadows.shadow2,
            onclick: () {
              // setState(() {
              //   requestSent = !requestSent;
              // });
              // validateGender(genderValue);
              // validateCountry(countryValue);
              // // validateCity(cityValue);
              // // validateState(stateValue);
              // if (FormKey.currentState!.validate()) {
              AppNavigation.navigatorPop(context);
              // HomeController.i.selectedTab.value = 1;
              // }
            },
            text: "Reset",
            color: AppColors.red,
          ),
        ),
     10.horizontalSpace,
        Expanded(
          child: CustomButton(
            // /boxShadow: AppShadows.shadow2,
            onclick: () {
              // setState(() {
              //   requestSent = !requestSent;
              // });
              // validateGender(genderValue);
              // validateCountry(countryValue);
              // // validateCity(cityValue);
              // // validateState(stateValue);
              // if (FormKey.currentState!.validate()) {
              AppNavigation.navigatorPop(context);
              // HomeController.i.selectedTab.value = 1;
              // }
            },
            text: AppStrings.apply,
          ),
        ),
     
      ],
    );
  }

  Widget cscPickerField() {
    return CSCPicker(
layout: Layout.vertical,
      isCountryShow:false,
      ///Enable disable state dropdown [OPTIONAL PARAMETER]
      showStates: true,

      /// Enable disable city drop down [OPTIONAL PARAMETER]
      showCities: true,

      ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
      flagState: CountryFlag.DISABLE,

      ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
      dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          color: AppColors.transparent,
          border: Border.all(color: AppColors.greyBorder, width: 1)),

      ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
      disabledDropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          color: AppColors.transparent,
          border: Border.all(color: AppColors.greyBorder, width: 1)),

      ///placeholders for dropdown search field
      countrySearchPlaceholder: "Country",
      stateSearchPlaceholder: "State",
      citySearchPlaceholder: "City",

      ///labels for dropdown
      countryDropdownLabel: "Country",
      stateDropdownLabel: "Select State",
      cityDropdownLabel: "Select City",

      ///Default Country
      ///defaultCountry: CscCountry.India,
      // /Default Country
      defaultCountry: CscCountry.United_States,

      ///Disable country dropdown (Note: use it with default country)
      disableCountry: true,

      ///Country Filter [OPTIONAL PARAMETER]
      // countryFilter: [
      //   CscCountry.India,
      //   CscCountry.United_States,
      //   CscCountry.Canada
      // ],

      ///Disable country dropdown (Note: use it with default country)
      //disableCountry: true,

      ///selected item style [OPTIONAL PARAMETER]
      selectedItemStyle: TextStyle(
        color: AppColors.black,
        fontSize: 14,
      ),
      iconColor: AppColors.transparent,

      ///DropdownDialog Heading style [OPTIONAL PARAMETER]
      dropdownHeadingStyle: TextStyle(
          color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),

      ///DropdownDialog Item style [OPTIONAL PARAMETER]
      dropdownItemStyle: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),

      ///Dialog box radius [OPTIONAL PARAMETER]
      dropdownDialogRadius: 10.0,

      ///Search bar radius [OPTIONAL PARAMETER]
      searchBarRadius: 10.0,
      error_text_country: errorCountry,
      // error_text_city: errorCity,
      error_text_state: errorState,

      ///triggers once country selected in dropdown
      onCountryChanged: (value) {
        setState(() {
          ///store value in country variable
          countryValue = value;
        });
      },

      ///triggers once state selected in dropdown
      onStateChanged: (value) {
        setState(() {
          ///store value in state variable
          stateValue = value;
        });
      },

      ///triggers once city selected in dropdown
      onCityChanged: (value) {
        setState(() {
          ///store value in city variable
          cityValue = value;
        });
      },
    );
  }
}
