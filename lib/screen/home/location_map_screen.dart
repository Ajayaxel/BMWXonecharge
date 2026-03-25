import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_place/google_place.dart';
import 'dart:async';
import 'package:onecharge/models/location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
import 'package:onecharge/models/location_config_model.dart';

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
  final TextEditingController _towerController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  String _selectedAddressType = "Home";
  String _selectedHomeType = "Villa";
  String _selectedFloorCategory = "G";
  List<String> _floorCategories = ["B", "GF", "M", "G"];
  Map<String, List<String>> _floorMap = {
    "B": List.generate(12, (index) => "B${index + 1}"),
    "GF": ["GF"],
    "M": ["M"],
    "G": List.generate(12, (index) => "G${index + 1}"),
  };
  String _selectedFloorValue = "G1";
  LocationConfigResponse? _locationConfig;

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
    context.read<LocationBloc>().add(FetchLocationConfig());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _houseController.dispose();
    _towerController.dispose();
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

  void _updateDynamicData() {
    if (_locationConfig == null) return;

    final at = _locationConfig!.data.addressTypes.firstWhere(
      (at) => at.name == _selectedAddressType,
      orElse: () => _locationConfig!.data.addressTypes[0],
    );

    if (at.propertyTypes.isNotEmpty) {
      final pt = at.propertyTypes.firstWhere(
        (pt) => pt.name == _selectedHomeType,
        orElse: () => at.propertyTypes[0],
      );
      _selectedHomeType = pt.name;

      _floorCategories = pt.floorTypes.map((ft) => ft.code).toList();
      _floorMap = {
        for (var ft in pt.floorTypes)
          ft.code: ft.floorNumbers.map((fn) => fn.label).toList()
      };

      if (_floorCategories.isNotEmpty) {
        if (!_floorCategories.contains(_selectedFloorCategory)) {
          _selectedFloorCategory = _floorCategories[0];
          final floors = _floorMap[_selectedFloorCategory] ?? [];
          if (floors.isNotEmpty) {
            _selectedFloorValue = floors[0];
          }
        }
      }
    } else {
      _selectedHomeType = "";
      _floorCategories = [];
      _floorMap = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationConfigLoaded) {
                setState(() {
                  _locationConfig = state.config;
                  if (_locationConfig!.data.addressTypes.isNotEmpty) {
                    _selectedAddressType =
                        _locationConfig!.data.addressTypes[0].name;
                    _updateDynamicData();
                  }
                });
              }
            },
            child: Stack(
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
                FocusScope.of(context).unfocus();
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.8,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                    _buildAddressTypeChips(),
                    const SizedBox(height: 20),
                    if (_selectedHomeType.isNotEmpty) ...[
                      if (_floorCategories.isNotEmpty) ...[
                        _buildDetailTextField(
                          _towerController,
                          "Tower / Building Name",
                        ),
                        const SizedBox(height: 12),
                        _buildFloorDropdown(),
                        const SizedBox(height: 12),
                        _buildDetailTextField(
                          _houseController,
                          "Apartment Number",
                        ),
                      ] else ...[
                        _buildDetailTextField(
                          _houseController,
                          "$_selectedHomeType Number or Name",
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
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
                          int? addressTypeId;
                          int? propertyTypeId;
                          int? floorTypeId;
                          int? floorNumberId;

                          if (_locationConfig != null) {
                            try {
                              final at = _locationConfig!.data.addressTypes
                                  .firstWhere(
                                (element) =>
                                    element.name == _selectedAddressType,
                                orElse: () =>
                                    _locationConfig!.data.addressTypes[0],
                              );
                              addressTypeId = at.id;

                              if (at.propertyTypes.isNotEmpty) {
                                final pt = at.propertyTypes.firstWhere(
                                  (element) =>
                                      element.name == _selectedHomeType,
                                  orElse: () => at.propertyTypes[0],
                                );
                                propertyTypeId = pt.id;

                                if (pt.floorTypes.isNotEmpty) {
                                  final ft = pt.floorTypes.firstWhere(
                                    (element) =>
                                        element.code == _selectedFloorCategory,
                                    orElse: () => pt.floorTypes[0],
                                  );
                                  floorTypeId = ft.id;

                                  if (ft.floorNumbers.isNotEmpty) {
                                    final fn = ft.floorNumbers.firstWhere(
                                      (element) =>
                                          element.label == _selectedFloorValue,
                                      orElse: () => ft.floorNumbers[0],
                                    );
                                    floorNumberId = fn.id;
                                  }
                                }
                              }
                            } catch (e) {
                              debugPrint("Error finding IDs: $e");
                            }
                          }

                          // Build a more detailed address string for the 'address' field
                          List<String> addressParts = [];
                          if (_towerController.text.isNotEmpty) {
                            addressParts.add(_towerController.text);
                          }
                          if (_selectedHomeType == "Apartment" &&
                              _selectedFloorValue.isNotEmpty) {
                            addressParts.add("Floor $_selectedFloorValue");
                          }
                          if (_houseController.text.isNotEmpty) {
                            addressParts.add(
                              "${_selectedHomeType == "Apartment" ? "Unit" : _selectedHomeType} ${_houseController.text}",
                            );
                          }
                          if (_roadController.text.isNotEmpty) {
                            addressParts.add(_roadController.text);
                          }
                          addressParts.add(_selectedAddress);

                          final location = LocationModel(
                            name: _selectedAddressType,
                            address: addressParts.join(", "),
                            latitude: _selectedLocation?.latitude ?? 0.0,
                            longitude: _selectedLocation?.longitude ?? 0.0,
                            addressTypeId: addressTypeId,
                            propertyTypeId: propertyTypeId,
                            floorTypeId: floorTypeId,
                            floorNumberId: floorNumberId,
                            towerBuildingName: _towerController.text,
                            roadArea: _roadController.text,
                            directionToReach: _directionController.text,
                            additionalInfo: "", // Can be mapped to something else if needed
                            isDefault: false,
                          );

                          Navigator.pop(context, location);
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
),
);
}

  Widget _buildAddressTypeChips() {
    if (_locationConfig == null) {
      return const SizedBox.shrink();
    }

    final currentAddressType = _locationConfig!.data.addressTypes.firstWhere(
      (at) => at.name == _selectedAddressType,
      orElse: () => _locationConfig!.data.addressTypes[0],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Save address as",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lufga',
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _locationConfig!.data.addressTypes.map((at) {
              IconData icon;
              switch (at.name) {
                case 'Home':
                  icon = Icons.home_outlined;
                  break;
                case 'Work':
                  icon = Icons.work_outline;
                  break;
                default:
                  icon = Icons.location_on_outlined;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildTypeChip(at.name, icon),
              );
            }).toList(),
          ),
        ),
        if (currentAddressType.propertyTypes.isNotEmpty) ...[
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: currentAddressType.propertyTypes.map((pt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildHomeTypeChip(pt.name),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHomeTypeChip(String type) {
    bool isSelected = _selectedHomeType == type;
    Color activeColor = Colors.black;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHomeType = type;
          _updateDynamicData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Lufga',
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon) {
    bool isSelected = _selectedAddressType == type;
    Color activeColor = Colors.black;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressType = type;
          _updateDynamicData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : const Color(0xFF374151),
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Lufga',
                color: isSelected ? activeColor : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorDropdown() {
    List<String> currentFloors = _floorMap[_selectedFloorCategory] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Floor",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lufga',
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        // Category Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _floorCategories.map((cat) {
              bool isSelected = _selectedFloorCategory == cat;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFloorCategory = cat;
                    _selectedFloorValue = _floorMap[cat]![0];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (currentFloors.length > 1) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFloorValue,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF9CA3AF)),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Lufga',
                  fontSize: 14,
                ),
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 300,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFloorValue = newValue!;
                  });
                },
                items: currentFloors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lufga',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
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
