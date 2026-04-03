import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:onecharge/models/vehicle_list_model.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';
import 'package:onecharge/screen/home/issue_reporting_bottom_sheet.dart';
import 'package:onecharge/screen/vehicle/vehicle_selection.dart';
import 'package:onecharge/const/onebtn.dart';

class VehicleSelectionBottomSheet extends StatefulWidget {
  final String category;
  final String currentAddress;
  final double currentLatitude;
  final double currentLongitude;
  final int? selectedLocationId;

  const VehicleSelectionBottomSheet({
    super.key,
    required this.category,
    required this.currentAddress,
    required this.currentLatitude,
    required this.currentLongitude,
    this.selectedLocationId,
  });

  static Future<void> show(
    BuildContext context, {
    required String category,
    required String currentAddress,
    required double currentLatitude,
    required double currentLongitude,
    int? selectedLocationId,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return VehicleSelectionBottomSheet(
          category: category,
          currentAddress: currentAddress,
          currentLatitude: currentLatitude,
          currentLongitude: currentLongitude,
          selectedLocationId: selectedLocationId,
        );
      },
    );
  }

  @override
  State<VehicleSelectionBottomSheet> createState() =>
      _VehicleSelectionBottomSheetState();
}

class _VehicleSelectionBottomSheetState
    extends State<VehicleSelectionBottomSheet> {
  int selectedVehicleIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20.00),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<VehicleListBloc, VehicleListState>(
            builder: (context, state) {
              if (state is VehicleListLoading) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildShimmerCarItem(),
                    ),
                  ),
                );
              }

              final vehicleList =
                  state is VehicleListLoaded ? state.vehicles : <VehicleListItem>[];

              if (vehicleList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No vehicles found. Please add a vehicle.',
                    style: TextStyle(fontFamily: 'Lufga'),
                  ),
                );
              }

              return StatefulBuilder(
                builder: (context, setListState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicleList.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicleList[index];
                      final isSelected = selectedVehicleIndex == index;
                      return GestureDetector(
                        onTap: () async {
                          setListState(() => selectedVehicleIndex = index);
                          await VehicleStorage.saveVehicleInfo(
                            name: vehicle.vehicleName,
                            number: vehicle.vehicleNumber,
                            image: vehicle.vehicleImage,
                            vehicleTypeId: vehicle.vehicleTypeId,
                            brandId: vehicle.brandId,
                            modelId: vehicle.modelId,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => IssueReportingBottomSheet(
                              vehicleName: vehicle.vehicleName,
                              vehiclePlate: vehicle.vehicleNumber,
                              currentAddress: widget.currentAddress,
                              latitude: widget.currentLatitude,
                              longitude: widget.currentLongitude,
                              locationId: widget.selectedLocationId,
                              initialCategory: widget.category,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCarItem(
                            title: vehicle.vehicleName,
                            subtitle: vehicle.vehicleNumber,
                            imageUrl: vehicle.vehicleImage,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          OneBtn(
            text: "Add Vehicle",
            onPressed: () async {
              final parentContext = this.context;
              Navigator.pop(context);
              await Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const VehicleSelection(),
                ),
              );
              if (parentContext.mounted) {
                parentContext.read<VehicleListBloc>().add(
                  const FetchVehicles(forceRefresh: true),
                );
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCarItem({
    required String title,
    required String subtitle,
    String? imageUrl,
    bool isSelected = false,
  }) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              width: 80,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car),
            )
          else
            const Icon(Icons.directions_car, size: 40, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildShimmerCarItem() {
    return Shimmer.fromColors(
      baseColor: const Color(0xffE0E0E0),
      highlightColor: Colors.white,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
