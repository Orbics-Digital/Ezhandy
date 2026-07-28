import 'dart:async';

import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class BookingLocationMap extends StatefulWidget {
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? address;

  const BookingLocationMap({
    super.key,
    this.destinationLatitude,
    this.destinationLongitude,
    this.address,
  });

  @override
  State<BookingLocationMap> createState() => _BookingLocationMapState();
}

class _BookingLocationMapState extends State<BookingLocationMap> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;
  String? _locationError;
  bool _isLoadingLocation = true;
  bool _hasFittedCamera = false;

  bool get _hasValidDestination =>
      widget.destinationLatitude != null &&
      widget.destinationLongitude != null &&
      widget.destinationLatitude!.abs() <= 90 &&
      widget.destinationLongitude!.abs() <= 180;

  LatLng? get _destinationLocation {
    if (!_hasValidDestination) return null;
    return LatLng(widget.destinationLatitude!, widget.destinationLongitude!);
  }

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationError('Location services are disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _setLocationError('Location permission denied');
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _setLocationError('Location permission permanently denied');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _updateCurrentLocation(position);
    } catch (_) {
      _setLocationError('Unable to fetch current location');
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      _updateCurrentLocation,
      onError: (_) {
        if (_currentLocation == null) {
          _setLocationError('Unable to track current location');
        }
      },
    );
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _locationError = message;
      _isLoadingLocation = false;
    });
  }

  void _updateCurrentLocation(Position position) {
    if (!mounted) return;

    final updatedLocation = LatLng(position.latitude, position.longitude);
    final isFirstFix = _currentLocation == null;

    setState(() {
      _currentLocation = updatedLocation;
      _locationError = null;
      _isLoadingLocation = false;
    });

    if (isFirstFix && !_hasFittedCamera) {
      _hasFittedCamera = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToMarkers(animate: false);
      });
    }
  }

  void _fitMapToMarkers({bool animate = true}) {
    final points = <LatLng>[
      if (_currentLocation != null) _currentLocation!,
      if (_destinationLocation != null) _destinationLocation!,
    ];

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(
        points.first,
        15,
      );
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(48.w),
        maxZoom: 16,
      ),
    );
  }

  void _recenterOnCurrentLocation() {
    if (_currentLocation == null) return;
    _mapController.move(_currentLocation!, 15);
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_destinationLocation != null) {
      markers.add(
        Marker(
          point: _destinationLocation!,
          width: 40.w,
          height: 40.h,
          child: Icon(
            Icons.location_on,
            color: AppColors.orange,
            size: 40.sp,
          ),
        ),
      );
    }

    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 44.w,
          height: 44.h,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blueDark.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.my_location,
              color: AppColors.blueDark,
              size: 28.sp,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  LatLng _initialCenter() {
    return _currentLocation ??
        _destinationLocation ??
        const LatLng(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidDestination && _currentLocation == null && !_isLoadingLocation) {
      final trimmedAddress = widget.address?.trim();
      if (trimmedAddress != null && trimmedAddress.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppPadding.padding12),
          child: CustomText(
            text: trimmedAddress,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(AppPadding.padding12),
        child: CustomText(
          text: _locationError ?? 'Location not available',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final markers = _buildMarkers();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.sp),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter(),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pixelgenesys.ezhandy.provider',
                ),
                if (markers.isNotEmpty) MarkerLayer(markers: markers),
              ],
            ),
            if (_isLoadingLocation)
              Container(
                color: AppColors.white.withValues(alpha: 0.7),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: AppColors.orange),
              ),
            if (_locationError != null)
              Positioned(
                left: AppPadding.padding12,
                right: AppPadding.padding12,
                bottom: AppPadding.padding12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.padding12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(color: AppColors.greyBorder),
                  ),
                  child: CustomText(
                    text: _locationError!,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: FloatingActionButton.small(
                heroTag: 'booking_map_recenter',
                backgroundColor: AppColors.green,
                onPressed:
                    _currentLocation == null ? null : _recenterOnCurrentLocation,
                child: Icon(
                  Icons.my_location,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
