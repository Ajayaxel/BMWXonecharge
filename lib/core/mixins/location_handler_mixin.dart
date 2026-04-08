import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:onecharge/models/location_model.dart';


mixin LocationHandlerMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String currentAddress = "Fetching location...";
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;
  int? selectedLocationId;
  bool _isLocationProcessing = false;

  Future<void> loadSavedLocation() async {
    final saved = await LocationStorage.getSelectedLocation();
    if (saved != null) {
      if (mounted) {
        setState(() {
          currentAddress = saved['address'];
          currentLatitude = saved['lat'];
          currentLongitude = saved['lng'];
          selectedLocationId = saved['id'];
        });
      }
    } else {
      await getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    if (_isLocationProcessing) return;
    _isLocationProcessing = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => currentAddress = "Location services disabled");
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => currentAddress = "Location permission denied");
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => currentAddress = "Location permission permanently denied");
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        if (place.name?.isNotEmpty ?? false) addressParts.add(place.name!);
        if (place.subLocality?.isNotEmpty ?? false) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty ?? false) {
          addressParts.add(place.locality!);
        }

        setState(() {
          currentAddress = addressParts.isEmpty
              ? "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}"
              : addressParts.join(", ");
          currentLatitude = position.latitude;
          currentLongitude = position.longitude;
          selectedLocationId = null; // Reset ID for GPS location

          // Save current GPS location as non-manual by default
          LocationStorage.saveSelectedLocation(
            address: currentAddress,
            lat: currentLatitude,
            lng: currentLongitude,
            isManual: false,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => currentAddress = "Failed to get location");
      }
    } finally {
      _isLocationProcessing = false;
    }
  }

  void validateCurrentLocation(List<LocationModel> locations) async {
    if (selectedLocationId != null) {
      final exists = locations.any((loc) => loc.id == selectedLocationId);
      if (!exists) {
        // Current location was deleted, fallback to GPS
        await LocationStorage.clearSelectedLocation();
        if (mounted) {
          setState(() {
            selectedLocationId = null;
          });
          await getCurrentLocation();
        }
      }
    }
  }

  void disposeLocation() {
    searchController.dispose();
  }
}
