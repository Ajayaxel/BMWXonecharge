import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onecharge/screen/home/widgets/home_header.dart';
import 'package:onecharge/screen/home/widgets/home_services.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/screen/home/widgets/vehicle_selection_bottom_sheet.dart';
import 'package:onecharge/core/mixins/location_handler_mixin.dart';

class OurServiceScreen extends StatefulWidget {
  const OurServiceScreen({super.key});

  @override
  State<OurServiceScreen> createState() => _OurServiceScreenState();
}

class _OurServiceScreenState extends State<OurServiceScreen>
    with LocationHandlerMixin {
  @override
  void initState() {
    super.initState();
    loadSavedLocation();
  }

  @override
  void dispose() {
    disposeLocation();
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: HomeHeader(
                  currentAddress: currentAddress,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                  onLocationChanged: (LocationModel result) {
                    setState(() {
                      currentAddress = result.name.isNotEmpty
                          ? result.name
                          : result.address;
                      currentLatitude = result.latitude;
                      currentLongitude = result.longitude;
                      selectedLocationId = result.id;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// LEFT CONTENT
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Our Services",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 6),

                            Text(
                              "Stuck on the road? Get instant tyre and battery assistance.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
   
                            SizedBox(height: 10),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Explore",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT ANIMATION
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Lottie.asset(
                            'assets/home/charger.json',
                            height: 120,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HomeServices(
                  searchQuery: searchQuery,
                  onServiceSelected: (categoryName) =>
                      VehicleSelectionBottomSheet.show(
                        context,
                        category: categoryName,
                        currentAddress: currentAddress,
                        currentLatitude: currentLatitude,
                        currentLongitude: currentLongitude,
                        selectedLocationId: selectedLocationId,
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
