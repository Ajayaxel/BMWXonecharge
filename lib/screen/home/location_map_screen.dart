import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_place/google_place.dart';
import 'dart:async';

class LocationMapScreen extends StatefulWidget {
  final String initialAddress;
  const LocationMapScreen({super.key, required this.initialAddress});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  String _selectedAddress = "";
  String _mainText = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _showAddressDetailsForm = false;

  // Detail controllers
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();

  // Autocomplete variables
  GooglePlace? _googlePlace;
  List<AutocompletePrediction> _predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
    // Replace with your actual API key
    _googlePlace = GooglePlace("AIzaSyCyWXFiBQAQ6qBpb3Mq_YKta4Y_dI5c4X0");
    _initializeLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _houseController.dispose();
    _roadController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        _autoCompleteSearch(value);
      } else {
        setState(() {
          _predictions = [];
        });
      }
    });
  }

  void _autoCompleteSearch(String value) async {
    var result = await _googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        _predictions = result.predictions!;
      });
    }
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialAddress.isNotEmpty &&
          widget.initialAddress != "Fetching location..." &&
          widget.initialAddress != "Location services disabled" &&
          widget.initialAddress != "Location permission denied") {
        List<geo.Location> locations = await geo.locationFromAddress(
          widget.initialAddress,
        );
        if (locations.isNotEmpty) {
          setState(() {
            _selectedLocation = LatLng(
              locations[0].latitude,
              locations[0].longitude,
            );
            _isLoading = false;
          });
          _updateAddressDetails(_selectedLocation!);
          return;
        }
      }

      // Fallback to current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _updateAddressDetails(_selectedLocation!);
    } catch (e) {
      // Final fallback to a default location if everything fails
      setState(() {
        _selectedLocation = const LatLng(25.2048, 55.2708); // Dubai
        _isLoading = false;
      });
      _updateAddressDetails(_selectedLocation!);
    }
  }

  Future<void> _updateAddressDetails(LatLng position) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        setState(() {
          _mainText = place.name ?? place.street ?? "Selected Location";

          List<String> parts = [];
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            parts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty)
            parts.add(place.locality!);
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            parts.add(place.administrativeArea!);
          if (place.country != null && place.country!.isNotEmpty)
            parts.add(place.country!);

          _selectedAddress = parts.join(", ");
          if (_selectedAddress.isEmpty) {
            _selectedAddress =
                "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
  }

  Future<void> _onSearch() async {
    if (_searchController.text.isEmpty) return;

    try {
      List<geo.Location> locations = await geo.locationFromAddress(
        _searchController.text,
      );
      if (locations.isNotEmpty) {
        LatLng newPos = LatLng(locations[0].latitude, locations[0].longitude);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
        setState(() {
          _selectedLocation = newPos;
          _predictions = []; // Clear suggestions
        });
        _updateAddressDetails(newPos);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  void _onPredictionSelected(AutocompletePrediction prediction) async {
    _searchController.text = prediction.description!;
    setState(() {
      _predictions = [];
    });

    try {
      List<geo.Location> locations = await geo.locationFromAddress(
        prediction.description!,
      );
      if (locations.isNotEmpty) {
        LatLng newPos = LatLng(locations[0].latitude, locations[0].longitude);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
        setState(() {
          _selectedLocation = newPos;
        });
        _updateAddressDetails(newPos);
      }
    } catch (e) {
      debugPrint("Error selecting prediction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black))
          else if (_selectedLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng position) async {
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newLatLng(position));
                setState(() {
                  _selectedLocation = position;
                  _predictions = []; // Clear suggestions when map is tapped
                });
                _updateAddressDetails(position);
              },
              onCameraMove: (position) {
                setState(() {
                  _selectedLocation = position.target;
                });
              },
              onCameraIdle: () {
                _updateAddressDetails(_selectedLocation!);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),

          // Center Marker Pin
          if (!_isLoading)
            const IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Icon(Icons.location_on, color: Colors.black, size: 45),
                ),
              ),
            ),

          // Search Bar & Suggestions
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_showAddressDetailsForm) {
                          setState(() {
                            _showAddressDetailsForm = false;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _onSearch,
                              child: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                onSubmitted: (_) => _onSearch(),
                                decoration: const InputDecoration(
                                  hintText: "Search an area...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Lufga',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _predictions = [];
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Suggestions List
                if (_predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          title: Text(
                            prediction.description!,
                            style: const TextStyle(
                              fontFamily: 'Lufga',
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _onPredictionSelected(prediction),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Details Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _mainText.isEmpty ? "Selected Location" : _mainText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Lufga',
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  if (_showAddressDetailsForm) ...[
                    _buildDetailTextField(
                      _houseController,
                      "House / flat/ office",
                    ),
                    const SizedBox(height: 12),
                    _buildDetailTextField(_roadController, "Road / Area"),
                    const SizedBox(height: 12),
                    _buildDetailTextField(
                      _directionController,
                      "Direction To Reach",
                      maxLines: 3,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_showAddressDetailsForm) {
                          setState(() {
                            _showAddressDetailsForm = true;
                          });
                        } else {
                          // Combine full address
                          String fullAddress = _selectedAddress;
                          if (_houseController.text.isNotEmpty) {
                            fullAddress =
                                "${_houseController.text}, $fullAddress";
                          }
                          Navigator.pop(context, fullAddress);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _showAddressDetailsForm
                            ? "Save Address Details"
                            : "Confirm & Proceed",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lufga',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontFamily: 'Lufga',
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
