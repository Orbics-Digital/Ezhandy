import 'dart:async';

import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingLocationMap extends StatefulWidget {
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? address;
  final bool fullScreen;
  final VoidCallback? onTap;
  final String recenterHeroTag;

  const BookingLocationMap({
    super.key,
    this.destinationLatitude,
    this.destinationLongitude,
    this.address,
    this.fullScreen = false,
    this.onTap,
    this.recenterHeroTag = 'booking_map_recenter',
  });

  @override
  State<BookingLocationMap> createState() => _BookingLocationMapState();
}

class _BookingLocationMapState extends State<BookingLocationMap> {
  GoogleMapController? _mapController;
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

  bool get _gesturesEnabled => widget.fullScreen || widget.onTap == null;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
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

    if (isFirstFix) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToMarkers(force: true);
      });
    }
  }

  Future<void> _fitMapToMarkers({bool force = false}) async {
    final controller = _mapController;
    if (controller == null) return;
    if (_hasFittedCamera && !force) return;

    final points = <LatLng>[
      if (_currentLocation != null) _currentLocation!,
      if (_destinationLocation != null) _destinationLocation!,
    ];

    if (points.isEmpty) return;

    _hasFittedCamera = true;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48,
      ),
    );
  }

  Future<void> _recenterOnCurrentLocation() async {
    if (_currentLocation == null || _mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 15),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: widget.address?.trim().isNotEmpty == true
                ? widget.address!.trim()
                : null,
          ),
        ),
      );
    }

    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }

    return markers;
  }

  LatLng _initialCenter() {
    return _currentLocation ?? _destinationLocation ?? const LatLng(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidDestination &&
        _currentLocation == null &&
        !_isLoadingLocation) {
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

    final mapContent = Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialCenter(),
            zoom: 15,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: _gesturesEnabled,
          zoomGesturesEnabled: _gesturesEnabled,
          tiltGesturesEnabled: _gesturesEnabled,
          onMapCreated: (controller) {
            _mapController = controller;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitMapToMarkers();
            });
          },
          onTap: widget.onTap == null ? null : (_) => widget.onTap?.call(),
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
          top: widget.fullScreen
              ? (MediaQuery.paddingOf(context).top + 12.h)
              : 12.h,
          right: 12.w,
          child: FloatingActionButton.small(
            heroTag: widget.recenterHeroTag,
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
    );

    final sizedMap = widget.fullScreen
        ? SizedBox.expand(child: mapContent)
        : ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: SizedBox(
              height: 220.h,
              width: double.infinity,
              child: mapContent,
            ),
          );

    if (widget.onTap == null) return sizedMap;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: sizedMap,
    );
  }
}
