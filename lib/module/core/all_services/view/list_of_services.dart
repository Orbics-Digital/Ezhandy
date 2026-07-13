import 'package:ezhandy_user/module/core/all_services/controller/provider_services_controller.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ListOfServices extends StatefulWidget {
  const ListOfServices({super.key});

  @override
  State<ListOfServices> createState() => _ListOfServicesState();
}

class _ListOfServicesState extends State<ListOfServices> {
  final ProviderServicesController _controller = ProviderServicesController.i;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.fetchProviderServices();
    _searchController.addListener(() {
      _controller.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.listOfServices,
      appBarheight: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            searchTextField(),
            10.verticalSpace,
            Expanded(
              child: Obx(() {
                final services = _controller.filteredProviderServices;
                final isLoading = _controller.isProviderServicesLoading.value;

                if (isLoading && _controller.providerServices.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.orange,
                    ),
                  );
                }

                if (services.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: _controller.refreshProviderServices,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        EmptyMessage(
                          message: _controller.searchQuery.value.trim().isEmpty
                              ? AppStrings.noServicesFound
                              : AppStrings.noResultsFound,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshProviderServices,
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: AppPadding.padding25),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return singleContainer(
                        service: service,
                        onTap: () {
                          AppNavigation.navigateTo(
                            context,
                            AppRoutes.serviceDetailsScreenRoute,
                            arguments: ServiceRoutingArgument(
                              service: service,
                              serviceName: service.title,
                              serviceTypeId: service.serviceTypeId,
                              type: service.isQuickService
                                  ? ServiceType.instant.name
                                  : ServiceType.schedule.name,
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return 20.verticalSpace;
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget singleContainer({
    required ProviderServiceModel service,
    required VoidCallback onTap,
  }) {
    final imageUrl = service.imageUrl?.trim() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: .3.sh,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.greyBorder.withOpacity(0.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  AssetPath.tempCleaningImage,
                  fit: BoxFit.cover,
                ),
              )
            else
              Image.asset(
                AssetPath.tempCleaningImage,
                fit: BoxFit.cover,
              ),
            Column(
              children: [
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35.r),
                          bottomLeft: Radius.circular(35.r),
                        ),
                      ),
                      child: CustomText(
                        text: service.displayVisitCharges,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                detailsContainer(service),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailsContainer(ProviderServiceModel service) {
    final iconUrl = service.serviceTypeIconUrl;

    return Padding(
      padding: EdgeInsets.all(AppPadding.padding12),
      child: CustomContainer(
        child: Row(
          children: [
            _serviceTypeIcon(iconUrl),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: service.title ?? '-'),
                  5.verticalSpace,
                  CustomText(
                    text: service.description ?? '-',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceTypeIcon(String iconUrl) {
    if (iconUrl.isEmpty) {
      return CircleAvatar(
        radius: 30.r,
        backgroundColor: AppColors.white,
        backgroundImage: const AssetImage(AssetPath.cleaningIcon),
      );
    }

    return CircleAvatar(
      radius: 30.r,
      backgroundColor: AppColors.white,
      child: ClipOval(
        child: Image.network(
          iconUrl,
          width: 60.r,
          height: 60.r,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            AssetPath.cleaningIcon,
            width: 60.r,
            height: 60.r,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget searchTextField() {
    return CustomTextField(
      label: false,
      prefxicon: AssetPath.searchIcon,
      hint: AppStrings.searchAnything,
      controller: _searchController,
      inputFormatters: [LengthLimitingTextInputFormatter(35)],
    );
  }
}
