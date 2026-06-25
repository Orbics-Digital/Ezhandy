import 'package:ezhandy_user/module/core/products/controller/products_controller.dart';
import 'package:ezhandy_user/module/core/products/model/product_model.dart';
import 'package:ezhandy_user/module/core/products/routing_arguments/add_edit_product_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_shadows.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_bottom_sheet.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace>
    with SingleTickerProviderStateMixin {
  final ProductsController _controller = Get.find<ProductsController>();
  final TextEditingController _searchController = TextEditingController();
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        appBarheight: 50.h,
        title: AppStrings.marketPlace,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: addButtonWidget(context),
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
            child: DefaultTabController(
                length: 2,
                child: Column(children: [
                  15.verticalSpace,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.greyBorder.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          color: AppColors.orange,
                        ),
                        unselectedLabelColor: AppColors.black,
                        onTap: (val) {
                          if (val == 1) {
                            _controller.fetchMyProducts();
                          }
                          setState(() {
                            controller.index = val;
                          });
                        },
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                        ),
                        labelColor: AppColors.white,
                        controller: controller,
                        tabs: const [
                          Tab(
                            text: AppStrings.products,
                          ),
                          Tab(
                            text: AppStrings.myProducts,
                          ),
                        ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        productsWidget(),
                        myProductsWidget(),
                      ],
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ),
                  25.verticalSpace
                ]))));
  }

  Visibility addButtonWidget(BuildContext context) {
    return Visibility(
        visible: controller.index == 1,
        child: GestureDetector(
            onTap: () {
              AppNavigation.navigateTo(
                  context, AppRoutes.addEditProductScreenRoute,
                  arguments: AddEditProductRoutingArgument(
                      type: AddEditType.add.name));
            },
            child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    boxShadow: AppShadows.shadow2,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 50.sp,
                ))));
  }

  Widget productsWidget() {
    return Column(
      children: [
        searchTextField(),
        10.verticalSpace,
        CustomText(text: AppStrings.products, fontWeight: FontWeight.bold),
        10.verticalSpace,
        Expanded(
          child: Obx(
            () {
              final items = _controller.filteredProducts;
              final isLoading = _controller.isLoading.value;

              if (isLoading && items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                );
              }

              if (!isLoading && items.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshProducts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      EmptyMessage(message: AppStrings.noProductsFound),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _controller.refreshProducts,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final product = items[index];
                    return _productGridItem(product);
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget myProductsWidget() {
    return Column(
      children: [
        searchTextField(),
        10.verticalSpace,
        CustomText(text: AppStrings.products, fontWeight: FontWeight.bold),
        10.verticalSpace,
        Expanded(
          child: Obx(
            () {
              final items = _controller.filteredMyProducts;
              final isLoading = _controller.isMyProductsLoading.value;

              if (isLoading && items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                );
              }

              if (!isLoading && items.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshMyProducts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      EmptyMessage(message: AppStrings.noProductsFound),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _controller.refreshMyProducts,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  padding: const EdgeInsets.only(bottom: AppPadding.padding50),
                  itemBuilder: (BuildContext ctxt, int index) {
                    return _myProductListItem(items[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 10.h,
                    );
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _productGridItem(ProductModel product) {
    return CustomContainer(
      onTap: () {
        AppNavigation.navigateTo(context, AppRoutes.productDetailScreenRoute);
      },
      isPadding: false,
      child: Column(
        children: [
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
              image: _productImageDecoration(product.mainImagePath),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                3.verticalSpace,
                CustomText(
                  text: DisplayHelper.displayValue(product.title),
                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                2.verticalSpace,
                CustomText(
                  text: _formatPrice(product.price),
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _myProductListItem(ProductModel product) {
    return CustomContainer(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: _productImageDecoration(product.mainImagePath),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.verticalSpace,
                CustomText(
                  text: DisplayHelper.displayValue(product.title),
                  fontWeight: FontWeight.bold,
                ),
                CustomText(text: _formatPrice(product.price)),
                CustomText(
                  text: DisplayHelper.displayValue(product.description),
                  fontSize: 12.sp,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDeleteProduct(product),
            child: CircleAvatar(
                backgroundColor: AppColors.orange,
                radius: 10.r,
                child: Image.asset(
                  AssetPath.deleteIcon,
                  width: 10.w,
                  height: 10.h,
                )),
          ),
          10.horizontalSpace,
          GestureDetector(
            onTap: () {
              AppNavigation.navigateTo(
                  context, AppRoutes.addEditProductScreenRoute,
                  arguments: AddEditProductRoutingArgument(
                      type: AddEditType.edit.name));
            },
            child: CircleAvatar(
                backgroundColor: AppColors.orange,
                radius: 10.r,
                child: Image.asset(
                  AssetPath.editIcon,
                  width: 10.w,
                  height: 10.h,
                )),
          ),
        ],
      ),
    );
  }

  DecorationImage _productImageDecoration(String? imageUrl) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      );
    }

    return DecorationImage(
      image: AssetImage(AssetPath.tempImage1),
      fit: BoxFit.cover,
    );
  }

  String _formatPrice(String? price) {
    final value = price?.trim();
    if (value == null || value.isEmpty) return '\$ 0.00';
    return '\$ $value';
  }

  void _confirmDeleteProduct(ProductModel product) {
    AppDialogs.showSuccessDialog(
      context,
      description: "Are you sure you want to delete this product?",
      isDoneShow: false,
      image: AssetPath.deleteWithCircleIcon,
      btnTxt1: AppStrings.yes,
      btnTxt2: AppStrings.no,
      onTap1: () async {
        AppNavigation.navigatorPop(context);
        final productId = product.id;
        if (productId == null || productId.isEmpty) return;

        final success = await _controller.deleteProduct(productId);
        if (!success || !mounted) return;

        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.productHasBeenDeletedSuccessfully,
          title: AppStrings.congratulation,
          btnTxt1: AppStrings.ok,
          onTap1: () {
            AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
          },
        );
      },
      onTap2: () {
        AppNavigation.navigatorPop(Constants.navigatorKey.currentContext!);
      },
    );
  }

  Widget searchTextField() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            fontColor: AppColors.black,
            divider: false,
            label: false,
            prefxicon: AssetPath.searchIcon,
            prefixIconColor: AppColors.greyBorder,
            hint: AppStrings.searchAnything,
            hintColor: AppColors.greyBorder,
            controller: _searchController,
            onchange: _controller.setSearchQuery,
            inputFormatters: [LengthLimitingTextInputFormatter(35)],
          ),
        ),
        10.horizontalSpace,
        CustomContainer(
            onTap: () {
              AppBottomSheet.showFilterSheet(context: context);
            },
            isPadding: false,
            bgColor: AppColors.orange,
            child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: Image.asset(
                  AssetPath.filterIcon,
                  width: 25.w,
                  height: 25.h,
                )))
      ],
    );
  }
}
