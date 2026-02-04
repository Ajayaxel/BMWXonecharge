import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/issue_reporting_bottom_sheet.dart';
import 'package:onecharge/screen/home/widgets/service_notification.dart';
import 'package:onecharge/screen/home/widgets/service_summary_bottom_sheet.dart';
import 'package:onecharge/screen/home/settings_screen.dart';
import 'package:onecharge/screen/home/tracking_map_screen.dart';
import 'package:onecharge/screen/vehicle/vehicle_selection.dart';
import 'package:onecharge/const/onebtn.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_bloc.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/models/vehicle_list_model.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/screen/notification/notification_screen.dart';
import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/screen/home/my_location_screen.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static HomeScreenState? activeState;
  int selectedIndex = -1;
  int selectedVehicleIndex = 0;
  List<VehicleListItem> vehicles = [];
  bool isLoadingVehicles = true;
  String currentAddress = "Fetching location...";
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  String _currentServiceStage = 'none';
  double _serviceProgress = 0.0;
  Timer? _serviceTimer;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Ticket? _currentTicket;
  String _userName = 'Mishal';

  @override
  void initState() {
    super.initState();
    activeState = this;
    _loadUserName();
    _getCurrentLocation();
    // Vehicles will be loaded via BLoC
    context.read<VehicleListBloc>().add(FetchVehicles());
  }

  Future<void> _loadUserName() async {
    final name = await TokenStorage.readUserName();
    if (name != null) {
      if (mounted) {
        setState(() {
          _userName = name.split(' ')[0];
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentAddress = "Location services disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentAddress = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentAddress = "Location permission permanently denied";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Construct a readable address
          List<String> addressParts = [];
          if (place.name != null && place.name!.isNotEmpty) {
            addressParts.add(place.name!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }

          currentAddress = addressParts.join(", ");
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          if (currentAddress.isEmpty) {
            currentAddress =
                "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          }
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = "Failed to get location";
      });
    }
  }

  @override
  void dispose() {
    activeState = null;
    _serviceTimer?.cancel();
    _searchController.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  OverlayEntry? _toastEntry;

  void showToast(String message) {
    _toastEntry?.remove();
    _toastEntry = null;

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        right: 20,
        left: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    _toastEntry = entry;
    overlayState.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_toastEntry == entry) {
        _toastEntry?.remove();
        _toastEntry = null;
      }
    });
  }

  void startServiceFlow({Ticket? ticket}) {
    setState(() {
      _currentServiceStage = 'finding';
      _serviceProgress = 0.0;
      _currentTicket = ticket;
    });

    _serviceTimer?.cancel();

    // Step 1: Finding (3s)
    _serviceTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _currentServiceStage = 'assigned';
      });

      // Start the 10-second fast progression synchronized with map
      _serviceTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (!mounted) return;

        setState(() {
          if (_serviceProgress < 1.0) {
            _serviceProgress += 0.01; // 1.0 total over 10 seconds

            if (_serviceProgress >= 0.3 && _currentServiceStage == 'assigned') {
              _currentServiceStage = 'reaching';
            }
            if (_serviceProgress >= 0.7 && _currentServiceStage == 'reaching') {
              _currentServiceStage = 'solving';
            }
          } else {
            _serviceProgress = 1.0;
            timer.cancel();

            // Wait 2 seconds at 'solving' then show 'resolved'
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _currentServiceStage = 'resolved';
                });
              }
            });
          }
        });
      });
    });
  }

  void _showVehicleSelectionBottomSheet(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BlocBuilder<VehicleListBloc, VehicleListState>(
          builder: (context, state) {
            if (state is VehicleListLoading) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildShimmerCarItem(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Shimmer.fromColors(
                      baseColor: const Color(0xffE0E0E0),
                      highlightColor: Colors.white,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }

            if (state is VehicleListError) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(20.00),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontFamily: 'Lufga'),
                    ),
                  ),
                ),
              );
            }

            final vehicleList = state is VehicleListLoaded
                ? state.vehicles
                : <VehicleListItem>[];

            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20.00),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vehicleList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No vehicles found. Please add a vehicle.',
                            style: TextStyle(fontFamily: 'Lufga'),
                          ),
                        )
                      else
                        ...List.generate(vehicleList.length, (index) {
                          final vehicle = vehicleList[index];
                          final isSelected = selectedVehicleIndex == index;
                          return GestureDetector(
                            onTap: () async {
                              setSheetState(() {
                                selectedVehicleIndex = index;
                              });
                              setState(() {});

                              // Save vehicle IDs to storage before opening Issue Reporting
                              await VehicleStorage.saveVehicleInfo(
                                name: vehicle.vehicleName,
                                number: vehicle.vehicleNumber,
                                image: vehicle.vehicleImage,
                                vehicleTypeId: vehicle.vehicleTypeId,
                                brandId: vehicle.brandId,
                                modelId: vehicle.modelId,
                              );

                              // Close current sheet and open Issue Reporting
                              if (!mounted) return;
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => IssueReportingBottomSheet(
                                  vehicleName: vehicle.vehicleName,
                                  vehiclePlate: vehicle.vehicleNumber,
                                  currentAddress: currentAddress,
                                  latitude: _currentLatitude,
                                  longitude: _currentLongitude,
                                  initialCategory: category,
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
                        }),
                      const SizedBox(height: 16),
                      // Add Vehicle Button
                      OneBtn(
                        text: "Add Vehicle",
                        onPressed: () {
                          // Close the bottom sheet
                          Navigator.pop(context);
                          // Navigate to Vehicle Selection screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleSelection(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCarItem({
    required String title,
    required String subtitle,
    String? imageUrl,
    bool isSelected = false,
  }) {
    Widget imageWidget;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        imageWidget = Image.network(
          imageUrl,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          width: 200,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 60, color: Colors.grey),
        );
      } else if (imageUrl.startsWith('assets/')) {
        imageWidget = Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          width: 200,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 60, color: Colors.grey),
        );
      } else {
        // Assuming the API returns relative paths, prepend base URL
        final fullImageUrl = 'https://app.onecharge.io/storage/$imageUrl';
        imageWidget = Image.network(
          fullImageUrl,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          width: 200,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 60, color: Colors.grey),
        );
      }
    } else {
      imageWidget = const SizedBox.shrink();
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerLeft,
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
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    fontFamily: 'Lufga',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned(right: 0, top: -20, bottom: -20, child: imageWidget),
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
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 5,
              bottom: 5,
              child: Container(
                width: 130,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationAdded) {
          showToast('Location added successfully');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Top Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  String name = _userName;
                                  if (state is AuthSuccess) {
                                    name = state.loginResponse.customer.name
                                        .split(' ')[0];
                                  }
                                  return Text(
                                    'Hi $name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Lufga',
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () async {
                                  final result =
                                      await Navigator.push<LocationModel>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyLocationScreen(
                                                isPicker: true,
                                              ),
                                        ),
                                      );
                                  if (result != null) {
                                    setState(() {
                                      currentAddress = result.address;
                                      _currentLatitude = result.latitude;
                                      _currentLongitude = result.longitude;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        currentAddress,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(
                                            0xFF1D1B20,
                                          ).withOpacity(0.6),
                                          fontFamily: 'Lufga',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xffF5F5F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_outlined,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search for any services',
                          hintStyle: TextStyle(
                            color: Color(0xffB8B9BD),
                            fontSize: 14,
                            fontFamily: 'Lufga',
                          ),
                          icon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Banner
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/home/bannerBG.png',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Save 30% off\nfirst 2 booking',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lufga',
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'USECODE 125MND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Services Grid
                    BlocBuilder<IssueCategoryBloc, IssueCategoryState>(
                      builder: (context, state) {
                        if (state is IssueCategoryLoading) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final double cardWidth =
                                  (constraints.maxWidth - 13) / 2;
                              return Wrap(
                                spacing: 13,
                                runSpacing: 13,
                                children: List.generate(6, (index) {
                                  return _buildShimmerServiceCard(cardWidth);
                                }),
                              );
                            },
                          );
                        } else if (state is IssueCategoryError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Couldn't load services",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lufga',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Please check your internet connection",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Lufga',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: 120,
                                  child: OneBtn(
                                    text: "Retry",
                                    onPressed: () {
                                      context.read<IssueCategoryBloc>().add(
                                        FetchIssueCategories(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is IssueCategoryLoaded) {
                          // Filter out 'Other' if it exists in the API list to avoid duplication
                          // Also filter out categories with null names
                          var categories = state.categories
                              .where(
                                (c) =>
                                    c.name != null &&
                                    c.name!.toLowerCase() != 'other',
                              )
                              .toList();

                          if (_searchQuery.isNotEmpty) {
                            categories = categories
                                .where(
                                  (c) => (c.name ?? '').toLowerCase().contains(
                                    _searchQuery,
                                  ),
                                )
                                .toList();
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final double cardWidth =
                                  (constraints.maxWidth - 13) / 2;
                              return Wrap(
                                spacing: 13,
                                runSpacing: 13,
                                children: [
                                  ...List.generate(categories.length, (index) {
                                    final category = categories[index];
                                    final categoryName =
                                        category.name ?? 'Unknown';
                                    return _buildServiceCard(
                                      index,
                                      categoryName,
                                      _getCategoryIcon(categoryName),
                                      cardWidth,
                                    );
                                  }),
                                  _buildServiceCard(
                                    categories.length,
                                    'Other',
                                    '',
                                    cardWidth,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (_currentServiceStage != 'none')
                ServiceNotificationOverlay(
                  stage: _currentServiceStage,
                  progress: _serviceProgress,
                  ticket: _currentTicket,
                  onDismiss: () {
                    showToast("Our customer support will contact you shortly");
                    setState(() {
                      _currentServiceStage = 'none';
                      _serviceTimer?.cancel();
                      _currentTicket = null;
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackingMapScreen(
                          stage: _currentServiceStage,
                          progress: _serviceProgress,
                        ),
                      ),
                    );
                  },
                  onSolved: () {
                    final ticketId = _currentTicket?.id;
                    setState(() {
                      _currentServiceStage = 'none';
                      _serviceTimer?.cancel();
                      _currentTicket = null;
                    });
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          ServiceSummaryBottomSheet(ticketId: ticketId),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    // Prioritize charging/station to distinguish from low battery
    if (lowerName.contains('station') || lowerName.contains('charge')) {
      return 'assets/home/chargingsation.png';
    }
    if (lowerName.contains('battery')) return 'assets/home/lowbattery.png';
    if (lowerName.contains('mechanical') || lowerName.contains('engine')) {
      return 'assets/home/mechanicalisuue.png';
    }
    if (lowerName.contains('tire') || lowerName.contains('tyre')) {
      return 'assets/home/falttyre.png';
    }
    if (lowerName.contains('tow') || lowerName.contains('pickup')) {
      return 'assets/home/pickupreqiure.png';
    }
    return '';
  }

  Widget _buildServiceCard(
    int index,
    String title,
    String imagePath,
    double width,
  ) {
    bool isSelected = selectedIndex == index;
    bool isOther = title == 'Other';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        _showVehicleSelectionBottomSheet(title);
      },
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            if (!isOther)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                    height: 1.2,
                  ),
                ),
              ),
            if (!isOther && imagePath.isNotEmpty)
              (title.contains('Tow') || title.contains('Pickup'))
                  ? Positioned(
                      right: -10,
                      top: 40,
                      bottom: 0,
                      child: Image.asset(
                        imagePath,
                        width: 110,
                        fit: BoxFit.contain,
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : null,
                        colorBlendMode: isSelected ? BlendMode.modulate : null,
                      ),
                    )
                  : Positioned.fill(
                      top: 30,
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          width: title.contains('Station') ? 60 : 120,
                          height: title.contains('Station') ? 90 : 80,
                          fit: BoxFit.contain,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : null,
                          colorBlendMode: isSelected
                              ? BlendMode.modulate
                              : null,
                        ),
                      ),
                    ),
            if (isOther)
              Center(
                child: Text(
                  'Other',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerServiceCard(double width) {
    return Shimmer.fromColors(
      baseColor: const Color(0xffE0E0E0),
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
