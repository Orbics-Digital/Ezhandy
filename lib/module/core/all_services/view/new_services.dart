import 'package:ezhandy_user/module/core/all_services/routing_arguments/service_routing_arguments.dart';
import 'package:ezhandy_user/module/core/service_types/controller/service_types_controller.dart';
import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
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

class NewServices extends StatefulWidget {
  const NewServices({super.key});

  @override
  State<NewServices> createState() => _NewServicesState();
}

class _NewServicesState extends State<NewServices> {
  final ServiceTypesController _serviceTypesController =
      Get.find<ServiceTypesController>();
  final TextEditingController _searchController = TextEditingController();

  String? selectedServiceTypeId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectFirstServiceTypeIfNeeded();
    ever(_serviceTypesController.serviceTypes, (_) {
      if (!mounted) return;
      setState(_selectFirstServiceTypeIfNeeded);
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectFirstServiceTypeIfNeeded() {
    if (selectedServiceTypeId != null) return;

    final types = _serviceTypesController.serviceTypes;
    if (types.isEmpty) return;

    selectedServiceTypeId = types.first.id;
  }

  List<ServiceTypeModel> _filteredServiceTypes() {
    final query = _searchQuery.trim().toLowerCase();
    final types = _serviceTypesController.serviceTypes;

    if (query.isEmpty) return types;

    return types.where((type) {
      final name = type.displayName.toLowerCase();
      final description = type.description?.toLowerCase() ?? '';
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.newServices,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            searchTextField(),
            Expanded(
              child: Obx(() {
                final serviceTypes = _filteredServiceTypes();

                if (serviceTypes.isEmpty) {
                  return EmptyMessage(
                    message: _searchQuery.trim().isEmpty
                        ? AppStrings.noServiceTypesFound
                        : AppStrings.noResultsFound,
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.only(
                    top: AppPadding.padding20,
                    bottom: AppPadding.padding25,
                  ),
                  shrinkWrap: true,
                  itemCount: serviceTypes.length,
                  itemBuilder: (context, index) {
                    final serviceType = serviceTypes[index];
                    final isSelected =
                        selectedServiceTypeId == serviceType.id;

                    return CustomContainer(
                      onTap: () {
                        setState(() {
                          selectedServiceTypeId = serviceType.id;
                        });
                      },
                      child: Row(
                        children: [
                          _serviceTypeIcon(serviceType),
                          10.horizontalSpace,
                          Expanded(
                            child: CustomText(text: serviceType.displayName),
                          ),
                          Visibility(
                            visible: isSelected,
                            child: const Icon(
                              Icons.check_circle_sharp,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return 10.verticalSpace;
                  },
                );
              }),
            ),
            _nextButton(),
          ],
        ),
      ),
    );
  }

  Widget _serviceTypeIcon(ServiceTypeModel serviceType) {
    final iconUrl = serviceType.iconImagePath?.trim();
    if (iconUrl == null || iconUrl.isEmpty) {
      return Image.asset(
        AssetPath.cleaningIcon,
        width: 40.w,
        height: 40.h,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        iconUrl,
        width: 40.w,
        height: 40.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          AssetPath.cleaningIcon,
          width: 40.w,
          height: 40.h,
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

  Widget _nextButton() {
    return CustomButton(
      text: AppStrings.next,
      onclick: () {
        final selectedServiceType =
            _serviceTypesController.getServiceTypeById(selectedServiceTypeId);

        if (selectedServiceType == null) {
          AppDialogs.showToast(message: AppStrings.noServiceTypesFound);
          return;
        }

        AppNavigation.navigateReplacementNamed(
          context,
          AppRoutes.addEditServiceScreenRoute,
          arguments: ServiceRoutingArgument(
            serviceName: selectedServiceType.displayName,
            serviceTypeId: selectedServiceType.id,
            type: AddEditType.add.name,
          ),
        );
      },
    );
  }
}
