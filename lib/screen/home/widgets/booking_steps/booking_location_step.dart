import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:onecharge/screen/settings/my_location_screen.dart';
import '../../../../logic/blocs/location/location_bloc.dart';
import '../../../../logic/blocs/location/location_state.dart';
import '../../../../models/location_model.dart';
import '../../../../const/onebtn.dart';

class BookingLocationStep extends StatefulWidget {
  final double latitude;
  final double longitude;
  final LocationModel? selectedLocation;
  final String currentAddress;
  final String selectedLocationType;
  final VoidCallback onLocationPickerTap;
  final Function(LocationModel) onLocationSelected;
  final Function(String) onLocationTypeChanged;
  final Function(String floor, String number, String type) onNext;

  const BookingLocationStep({
    super.key,
    required this.latitude,
    required this.longitude,
    this.selectedLocation,
    required this.currentAddress,
    required this.selectedLocationType,
    required this.onLocationPickerTap,
    required this.onLocationSelected,
    required this.onLocationTypeChanged,
    required this.onNext,
  });

  @override
  State<BookingLocationStep> createState() => _BookingLocationStepState();
}

class _BookingLocationStepState extends State<BookingLocationStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  final TextEditingController _parkingNumberController =
      TextEditingController();
  final TextEditingController _parkingFloorController = TextEditingController();
  bool _isOutside = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 8,
      ), // Made it slow by setting a long duration
    )..repeat();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _parkingNumberController.dispose();
    _parkingFloorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lottie Animation Background
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.38,
          child: Lottie.asset(
            "assets/issue/Dlivery Map.json",
            controller: _lottieController,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _lottieController.duration = composition.duration * 2;
              _lottieController.repeat();
            },
          ),
        ),

        // Draggable Sheet
        DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xffF8F9FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      // Draggable Handle
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: BlocBuilder<LocationBloc, LocationState>(
                          builder: (context, state) {
                            List<LocationModel> locations = [];
                            if (state is LocationsLoaded) {
                              locations = state.locations;
                            }

                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                100,
                              ),
                              itemCount: locations.isEmpty
                                  ? 3
                                  : locations.length,
                              itemBuilder: (context, index) {
                                final location = locations.isNotEmpty
                                    ? locations[index]
                                    : null;
                                return _buildLocationItem(
                                  title:
                                      location?.name ??
                                      (index == 0
                                          ? "Home"
                                          : index == 1
                                          ? "Work"
                                          : "Favorite"),
                                  address:
                                      location?.address ??
                                      "we're, Floor B1, Unit eweqwe, ewee, Palay...",
                                  isSelected:
                                      widget.selectedLocation == location ||
                                      (widget.selectedLocation == null &&
                                          index == 0),
                                  onTap: () {
                                    if (location != null) {
                                      widget.onLocationSelected(location);
                                    }
                                  },
                                  parkingNumberController:
                                      _parkingNumberController,
                                  parkingFloorController:
                                      _parkingFloorController,
                                  isOutside: _isOutside,
                                  onToggleOutside: (val) {
                                    setState(() {
                                      _isOutside = val;
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Fixed Footer
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OneBtn(
                              onPressed: () {
                                final floor = _parkingFloorController.text
                                    .trim();
                                final number = _parkingNumberController.text
                                    .trim();

                                if (floor.isEmpty) {
                                  HomeScreenState.activeState?.showToast(
                                    "Please enter Parking Floor",
                                  );
                                  return;
                                }
                                if (number.isEmpty) {
                                  HomeScreenState.activeState?.showToast(
                                    "Please enter Parking Number",
                                  );
                                  return;
                                }

                                widget.onNext(
                                  floor,
                                  number,
                                  _isOutside ? "Outside" : "Inside",
                                );
                              },
                              text: "Chose Location",
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              height: 56,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MyLocationScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required String title,
    required String address,
    bool isSelected = false,
    required VoidCallback onTap,
    required TextEditingController parkingNumberController,
    required TextEditingController parkingFloorController,
    required bool isOutside,
    required Function(bool) onToggleOutside,
  }) {
    IconData displayIcon = Icons.home_rounded;
    if (title.toLowerCase().contains("work")) {
      displayIcon = Icons.work_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.06 : 0.02),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isSelected ? Icons.location_on_rounded : displayIcon,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Lufga',
                          color: const Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallTextField(
                      label: "Parking Floor",
                      controller: parkingFloorController,
                      hint: "e.g. B1",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallTextField(
                      label: "Parking Number",
                      controller: parkingNumberController,
                      hint: "e.g. 102",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Parking Type",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildLargeToggle(
                value: isOutside,
                onChanged: onToggleOutside,
                leftLabel: "Inside",
                rightLabel: "Outside",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLargeToggle({
    required bool value,
    required Function(bool) onChanged,
    required String leftLabel,
    required String rightLabel,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: leftLabel,
            isSelected: !value,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            label: rightLabel,
            isSelected: value,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade100,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lufga',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
