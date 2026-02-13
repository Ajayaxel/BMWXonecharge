import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:onecharge/logic/blocs/brand/brand_bloc.dart';
import 'package:onecharge/logic/blocs/brand/brand_state.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_state.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_bloc.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_state.dart';
import 'package:onecharge/models/vehicle_model.dart';
import 'package:onecharge/models/charging_type_model.dart';
import 'package:onecharge/models/add_vehicle_model.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_bloc.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_event.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_state.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/utils/toast_utils.dart';

class VehicleSelection extends StatefulWidget {
  const VehicleSelection({super.key});

  @override
  State<VehicleSelection> createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends State<VehicleSelection> {
  String? selectedBrand = 'BMW';
  String selectedVehicleType = 'Sedan';
  VehicleModel? selectedVehicle; // Track selected vehicle
  final TextEditingController searchController = TextEditingController();

  final List<String> vehicleTypes = ['Sedan', 'SUV'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              "Select your vehicle",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    "skip",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild to update filtered vehicles
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Vehicles',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brands Label
                      const Text(
                        'Brands',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand Grid
                      BlocBuilder<BrandBloc, BrandState>(
                        builder: (context, state) {
                          if (state is BrandLoading) {
                            return SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 77,
                                            height: 77,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            width: 50,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (state is BrandError) {
                            return SizedBox(
                              height: 110,
                              child: Center(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          } else if (state is BrandLoaded) {
                            final brands = state.brands;
                            return SizedBox(
                              height: 110,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 15,
                                      mainAxisExtent: 80,
                                    ),
                                itemCount: brands.length,
                                itemBuilder: (context, index) {
                                  final brand = brands[index];
                                  final isSelected =
                                      selectedBrand == brand.name;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedBrand = brand.name;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Brand Logo Avatar
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Container(
                                            width: 77,
                                            height: 77,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFF5F5F5),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.network(
                                                brand.image,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      // Fallback to icon if image not found
                                                      return Icon(
                                                        Icons.directions_car,
                                                        size: 40,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        // Brand Name
                                        Text(
                                          brand.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vehicles Label
                      const Text(
                        "Vehicles",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Vehicle Type Filters
                      Row(
                        children: vehicleTypes.map((type) {
                          final isSelected = selectedVehicleType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = type;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type == 'Sedan'
                                          ? Icons.directions_car
                                          : Icons.directions_car,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle List with Smooth Animation
                      BlocBuilder<VehicleModelBloc, VehicleModelState>(
                        builder: (context, state) {
                          List<VehicleModel> filteredModels = [];

                          if (state is VehicleModelLoaded) {
                            filteredModels = state.models.where((model) {
                              // Filter by brand
                              bool matchesBrand =
                                  selectedBrand == null ||
                                  model.brand?.name == selectedBrand;

                              // Filter by search query
                              bool matchesSearch =
                                  searchController.text.isEmpty ||
                                  model.name.toLowerCase().contains(
                                    searchController.text.toLowerCase(),
                                  );

                              // Filter by vehicle type (Sedan/SUV)
                              bool matchesType = false;
                              if (model.vehicleCategory != null) {
                                // Compare backend category with selected type (case-insensitive)
                                matchesType =
                                    model.vehicleCategory!.name.toLowerCase() ==
                                    selectedVehicleType.toLowerCase();
                              }

                              return matchesBrand &&
                                  matchesSearch &&
                                  matchesType;
                            }).toList();
                          }

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0.0, 0.1),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                            child: (state is VehicleModelLoading)
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Column(
                                      children: List.generate(3, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              height: 141,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                : (state is VehicleModelError)
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  )
                                : filteredModels.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No vehicles available",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    key: ValueKey<String>(
                                      selectedVehicleType +
                                          (selectedBrand ?? "all") +
                                          searchController.text,
                                    ),
                                    children: filteredModels.map((vehicle) {
                                      final isSelected =
                                          selectedVehicle == vehicle;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedVehicle = vehicle;
                                            });
                                            _showVehicleNumberBottomSheet();
                                          },
                                          child: Container(
                                            height: 141,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.transparent,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                // Vehicle Name
                                                Positioned(
                                                  left: 20,
                                                  top: 20,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        vehicle.name.split(
                                                          ' ',
                                                        )[0],
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      if (vehicle.name
                                                              .split(' ')
                                                              .length >
                                                          1)
                                                        Text(
                                                          vehicle.name
                                                              .split(' ')
                                                              .sublist(1)
                                                              .join(' '),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),

                                                // Vehicle Image
                                                Positioned(
                                                  right: 0,
                                                  bottom: 5,
                                                  top: 5,
                                                  child:
                                                      vehicle.image.startsWith(
                                                        'http',
                                                      )
                                                      ? Image.network(
                                                          vehicle.image,
                                                          fit: BoxFit.contain,
                                                          height: 142,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .directions_car,
                                                                    size: 80,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                  ),
                                                                );
                                                              },
                                                        )
                                                      : Image.asset(
                                                          vehicle.image,
                                                          fit: BoxFit.contain,
                                                          height: 142,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .directions_car,
                                                                    size: 80,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                  ),
                                                                );
                                                              },
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleNumberBottomSheet() {
    final TextEditingController vehicleNumberController =
        TextEditingController();

    ChargingType? selectedChargingType;
    String selectedCountry = 'United Arab Emirates (UAE)';
    String? selectedEmirate;
    String? selectedPlateCode;

    final Map<String, List<String>> emirateData = {
      // ✅ Abu Dhabi (1–20 + 50)
      'Abu Dhabi': [for (int i = 1; i <= 20; i++) i.toString(), '50'],

      // ✅ Dubai (A–Z + AA–ZZ)
      'Dubai': [
        ...List.generate(26, (i) => String.fromCharCode(65 + i)), // A–Z
        ...List.generate(
          26,
          (i) => String.fromCharCode(65 + i) + String.fromCharCode(65 + i),
        ), // AA–ZZ
      ],

      // ✅ Sharjah (1–4)
      'Sharjah': ['1', '2', '3', '4'],

      // ✅ Ajman (A–Z)
      'Ajman': List.generate(26, (i) => String.fromCharCode(65 + i)),

      // ✅ Fujairah (A–Z)
      'Fujairah': List.generate(26, (i) => String.fromCharCode(65 + i)),

      // ✅ Ras Al Khaimah (A–Z)
      'Ras Al Khaimah': List.generate(26, (i) => String.fromCharCode(65 + i)),

      // ✅ Umm Al Quwain (A–Z)
      'Umm Al Quwain': List.generate(26, (i) => String.fromCharCode(65 + i)),
    };

    bool isValidUaePlate(String number) {
      final RegExp regex = RegExp(r'^\d{1,5}$'); // 1–5 digits only
      return regex.hasMatch(number);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    const Text(
                      "Vehicle Plate Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Country Dropdown (UAE Default)
                    const Text(
                      "Country",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedCountry,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Emirate and Plate Code Selection
                    Row(
                      children: [
                        // Emirate Dropdown
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Emirate",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(canvasColor: Colors.white),
                                child: DropdownButtonFormField<String>(
                                  value: selectedEmirate,
                                  decoration: InputDecoration(
                                    hintText: "Select",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  items: emirateData.keys.map((String emirate) {
                                    return DropdownMenuItem<String>(
                                      value: emirate,
                                      child: Text(
                                        emirate,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      selectedEmirate = value;
                                      selectedPlateCode =
                                          null; // Reset plate code
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Plate Code Dropdown
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Code",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(canvasColor: Colors.white),
                                child: DropdownButtonFormField<String>(
                                  value: selectedPlateCode,
                                  disabledHint: const Text("..."),
                                  decoration: InputDecoration(
                                    hintText: "Code",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  items: selectedEmirate == null
                                      ? []
                                      : emirateData[selectedEmirate!]!.map((
                                          String code,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: code,
                                            child: Text(
                                              code,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  onChanged: selectedEmirate == null
                                      ? null
                                      : (value) {
                                          setModalState(() {
                                            selectedPlateCode = value;
                                          });
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Plate Number Input Field
                    const Text(
                      "Plate Number",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vehicleNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter digits",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Charging Type Dropdown
                    const Text(
                      "Charging Type",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<ChargingTypeBloc, ChargingTypeState>(
                      builder: (context, state) {
                        if (state is ChargingTypeLoading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                          );
                        } else if (state is ChargingTypeError) {
                          return Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Error loading charging types',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        } else if (state is ChargingTypeLoaded) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(canvasColor: Colors.white),
                              child: DropdownButtonFormField<ChargingType>(
                                value: selectedChargingType,
                                decoration: InputDecoration(
                                  hintText: "Select Charging Type",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                dropdownColor: Colors.white,
                                focusColor: Colors.white,
                                items: state.chargingTypes.map((chargingType) {
                                  return DropdownMenuItem<ChargingType>(
                                    value: chargingType,
                                    child: Text(
                                      chargingType.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (ChargingType? newValue) {
                                  setModalState(() {
                                    selectedChargingType = newValue;
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                isExpanded: true,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 12),

                    // Prompt text with selected vehicle name
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: "Enter your "),
                          TextSpan(
                            text: selectedVehicle?.name ?? "vehicle",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " registration number."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    BlocListener<AddVehicleBloc, AddVehicleState>(
                      listener: (context, state) {
                        if (state is AddVehicleError) {
                          ToastUtils.showToast(
                            context,
                            state.message,
                            isError: true,
                          );
                        } else if (state is AddVehicleSuccess) {
                          Navigator.of(context).pop(); // Close input sheet

                          // Use the values from the current state to pass full plate number
                          final fullNumber =
                              "$selectedEmirate $selectedPlateCode ${vehicleNumberController.text.trim()}";

                          _showFinalSuccessBottomSheet(
                            fullNumber,
                            state.response,
                          );
                        }
                      },
                      child: BlocBuilder<AddVehicleBloc, AddVehicleState>(
                        builder: (context, addVehicleState) {
                          return OneBtn(
                            text: addVehicleState is AddVehicleLoading
                                ? "Submitting..."
                                : "Submit",
                            onPressed: addVehicleState is AddVehicleLoading
                                ? null
                                : () {
                                    if (selectedEmirate == null) {
                                      ToastUtils.showToast(
                                        context,
                                        'Please select an Emirate.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (selectedPlateCode == null) {
                                      ToastUtils.showToast(
                                        context,
                                        'Please select a Plate Code.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    final plateNumber = vehicleNumberController
                                        .text
                                        .trim();
                                    if (plateNumber.isEmpty) {
                                      ToastUtils.showToast(
                                        context,
                                        'Please enter your plate number.',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (!isValidUaePlate(plateNumber)) {
                                      ToastUtils.showToast(
                                        context,
                                        'Invalid UAE plate number (1–5 digits only).',
                                        isError: true,
                                      );
                                      return;
                                    }
                                    if (selectedChargingType == null) {
                                      ToastUtils.showToast(
                                        context,
                                        'Please select a charging type.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    // Combined vehicle number format: "Emirate Code Number"
                                    final combinedVehicleNumber =
                                        "$selectedEmirate $selectedPlateCode $plateNumber";

                                    // Validate selected vehicle
                                    final currentVehicle = selectedVehicle;
                                    if (currentVehicle == null) {
                                      ToastUtils.showToast(
                                        context,
                                        'Please select a vehicle.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    // Get vehicle type ID and brand ID from selected brand
                                    final brandState = context
                                        .read<BrandBloc>()
                                        .state;
                                    int vehicleTypeId = 1;
                                    int brandId = currentVehicle.brandId;

                                    if (brandState is BrandLoaded &&
                                        brandState.brands.isNotEmpty) {
                                      try {
                                        final selectedBrandData = brandState
                                            .brands
                                            .firstWhere(
                                              (brand) =>
                                                  brand.name == selectedBrand,
                                            );
                                        vehicleTypeId =
                                            selectedBrandData.vehicleTypeId;
                                        brandId = selectedBrandData.id;
                                      } catch (e) {
                                        final firstBrand =
                                            brandState.brands.first;
                                        vehicleTypeId =
                                            firstBrand.vehicleTypeId;
                                        brandId = firstBrand.id;
                                      }
                                    }

                                    // Create add vehicle request
                                    final request = AddVehicleRequest(
                                      vehicleTypeId: vehicleTypeId,
                                      brandId: brandId,
                                      modelId: currentVehicle.id,
                                      chargingTypeId: selectedChargingType!.id,
                                      vehicleNumber: combinedVehicleNumber,
                                    );

                                    // Dispatch add vehicle event
                                    context.read<AddVehicleBloc>().add(
                                      AddVehicleRequested(request),
                                    );
                                  },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom message
                    const Center(
                      child: Text(
                        "Just once! Register your vehicle now, and we'll remember it for you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFinalSuccessBottomSheet(
    String vehicleNumber,
    AddVehicleResponse response,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                const Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // Success message
                Text(
                  response.message.isNotEmpty
                      ? response.message
                      : "Vehicle number successfully added!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(height: 24),

                // Green checkmark icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),

                const SizedBox(height: 32),

                // Continue Button
                OneBtn(
                  text: "Continue",
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close success sheet

                    // Save vehicle info to storage with all IDs
                    await VehicleStorage.saveVehicleInfo(
                      name: selectedVehicle?.name ?? 'My Vehicle',
                      number: vehicleNumber,
                      image: selectedVehicle?.image,
                      vehicleTypeId: response.data.vehicleTypeId,
                      brandId: response.data.brandId,
                      modelId: response.data.modelId,
                    );

                    // Navigate to HomeScreen and remove all previous routes
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
