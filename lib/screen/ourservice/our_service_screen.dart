import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/widgets/home_header.dart';
import 'package:onecharge/screen/home/widgets/home_services.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/screen/home/vehicle_selection_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OurServiceScreen extends StatefulWidget {
  const OurServiceScreen({super.key});

  @override
  State<OurServiceScreen> createState() => _OurServiceScreenState();
}

class _OurServiceScreenState extends State<OurServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String currentAddress = "Fetching location...";
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  int? _selectedLocationId;


  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final saved = await LocationStorage.getSelectedLocation();
    if (saved != null) {
      if (mounted) {
        setState(() {
          currentAddress = saved['address'];
          _currentLatitude = saved['lat'];
          _currentLongitude = saved['lng'];
          _selectedLocationId = saved['id'];
        });
      }
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        setState(() => currentAddress = "Location services disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          setState(() => currentAddress = "Location permission denied");
        return;
      }
    }

    try {
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
        if (place.subLocality?.isNotEmpty ?? false)
          addressParts.add(place.subLocality!);
        if (place.locality?.isNotEmpty ?? false)
          addressParts.add(place.locality!);

        setState(() {
          currentAddress = addressParts.isEmpty
              ? "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}"
              : addressParts.join(", ");
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }
    } catch (e) {
      if (mounted) setState(() => currentAddress = "Failed to get location");
    }
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: HomeHeader(
                  currentAddress: currentAddress,
                  searchController: _searchController,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  onLocationChanged: (LocationModel result) {
                    setState(() {
                      currentAddress = result.name.isNotEmpty
                          ? result.name
                          : result.address;
                      _currentLatitude = result.latitude;
                      _currentLongitude = result.longitude;
                      _selectedLocationId = result.id;
                    });
                  },
                ),
              ),

              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/home/map.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HomeServices(
                  searchQuery: _searchQuery,
                  onServiceSelected: (categoryName) =>
                      VehicleSelectionBottomSheet.show(
                    context,
                    category: categoryName,
                    currentAddress: currentAddress,
                    currentLatitude: _currentLatitude,
                    currentLongitude: _currentLongitude,
                    selectedLocationId: _selectedLocationId,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
