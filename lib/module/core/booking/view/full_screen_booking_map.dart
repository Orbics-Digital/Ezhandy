import 'package:ezhandy_user/module/core/booking/routing_arguments/full_screen_map_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/map/booking_location_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FullScreenBookingMapScreen extends StatelessWidget {
  final FullScreenMapRoutingArgument? arguments;

  const FullScreenBookingMapScreen({
    super.key,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            BookingLocationMap(
              destinationLatitude: arguments?.destinationLatitude,
              destinationLongitude: arguments?.destinationLongitude,
              address: arguments?.address,
              fullScreen: true,
              recenterHeroTag: 'booking_map_recenter_full',
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: Material(
                color: AppColors.orange,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      AssetPath.backIcon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
