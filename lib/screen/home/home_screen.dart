import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/issue_reporting_bottom_sheet.dart';
import 'package:onecharge/screen/home/widgets/service_notification.dart';
import 'package:onecharge/screen/home/widgets/feedback_bottom_sheet.dart';
import 'package:onecharge/screen/home/settings_screen.dart';
import 'package:onecharge/screen/home/tracking_map_screen.dart';
import 'package:onecharge/logic/services/realtime_service.dart';
import 'package:onecharge/screen/vehicle/vehicle_selection.dart';
import 'package:onecharge/const/onebtn.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_event.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_state.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';
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
import 'package:onecharge/logic/blocs/profile/profile_bloc.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';
import 'package:onecharge/core/carplay/carplay_service.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/logic/blocs/brand/brand_event.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_event.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_event.dart';
import 'package:onecharge/logic/blocs/profile/profile_event.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/brand/brand_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_model/vehicle_model_bloc.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_bloc.dart';

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
  Timer? _pollingTimer;
  RealtimeService? _realtimeService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Ticket? _currentTicket;
  bool _isConnectingRealtime = false;

  /// Returns true if the driver's last location update is within the last
  /// [maxAgeMinutes] minutes (default: 30), meaning it is fresh enough to use.
  /// This prevents us from using stale/hardcoded coordinates stored days ago.
  bool _isLocationFresh(String? lastUpdatedAt, {int maxAgeMinutes = 30}) {
    if (lastUpdatedAt == null || lastUpdatedAt.isEmpty) return false;
    try {
      final lastUpdated = DateTime.parse(lastUpdatedAt).toUtc();
      final now = DateTime.now().toUtc();
      final ageMinutes = now.difference(lastUpdated).inMinutes;
      print(
        '⏱️ [HomeScreen] Driver location age: $ageMinutes minutes (max: $maxAgeMinutes)',
      );
      return ageMinutes <= maxAgeMinutes;
    } catch (e) {
      print(
        '⚠️ [HomeScreen] Failed to parse last_location_updated_at: $lastUpdatedAt',
      );
      return false;
    }
  }

  void _initRealtimeService(int customerId, {Ticket? ticket}) async {
    print(
      '🔌 [HomeScreen] Initializing RealtimeService for Customer ID: $customerId',
    );
    if (_isConnectingRealtime) {
      developer.log(
        '⏭️ [HomeScreen] Skipping duplicate realtime init',
        name: 'HomeScreen',
      );
      print(
        '⏭️ [HomeScreen] Realtime connection already in progress, skipping.',
      );
      return;
    }
    _isConnectingRealtime = true;
    try {
      final token = await TokenStorage.readToken();
      if (token == null) {
        print('❌ [HomeScreen] Token is null, cannot start RealtimeService');
        return;
      }

      print('🔌 [HomeScreen] Disconnecting old RealtimeService instance...');
      _realtimeService?.disconnect();

      _realtimeService = RealtimeService(
        customerId: customerId,
        token: token,
        onTicketOffered: (data) {
          if (mounted) {
            print('🎫 [RealtimeService CALLBACK] Ticket Offered: $data');
            // Only go to 'finding' if we aren't already further ahead
            if (_currentServiceStage == 'none' ||
                _currentServiceStage == 'finding') {
              setState(() {
                _currentServiceStage = 'finding';
              });
              print('🎯 [HomeScreen] Stage updated to: finding');
            }
          }
        },
        onTicketAssigned: (data) {
          if (mounted) {
            print('🚗 [RealtimeService CALLBACK] Ticket Assigned data: $data');
            if (data is Map<String, dynamic>) {
              // Use lat/lng ONLY if last_location_updated_at is within 30 minutes.
              // This prevents stale/hardcoded database coordinates from appearing on the map.
              final String? lastUpdatedAt = data['last_location_updated_at']
                  ?.toString();
              final bool locationFresh = _isLocationFresh(lastUpdatedAt);

              String? driverLat;
              String? driverLng;
              if (locationFresh) {
                driverLat = data['latitude']?.toString();
                driverLng = data['longitude']?.toString();
                print(
                  '✅ [HomeScreen] Driver assigned with fresh location: lat=$driverLat, lng=$driverLng',
                );
              } else {
                print(
                  '🚫 [HomeScreen] Driver assigned but location is stale ($lastUpdatedAt) — waiting for real-time GPS.',
                );
              }

              final driver = TicketDriver(
                id: data['driver_id'],
                name: data['driver_name'],
                image: data['driver_image'],
                latitude: driverLat,
                longitude: driverLng,
              );

              if (locationFresh && driverLat != null) {
                context.read<TicketBloc>().add(UpdateDriverLocation(driver));
              }

              setState(() {
                _currentServiceStage = 'reaching';
                if (_currentTicket != null) {
                  _currentTicket = _currentTicket!.copyWith(
                    status: 'assigned',
                    driver: driver,
                  );
                  context.read<TicketBloc>().add(
                    UpdateTicketDetails(_currentTicket!),
                  );
                } else if (data['ticket_id'] != null) {
                  print(
                    'ℹ️ [HomeScreen] No ticket object, received assigned for Ticket ID: ${data['ticket_id']}',
                  );
                }
              });
            } else {
              setState(() => _currentServiceStage = 'reaching');
            }
          }
        },
        onTicketStatusChanged: (data) {
          if (mounted && data is Map<String, dynamic>) {
            final String status = data['status']?.toString() ?? '';
            final int? ticketId = data['ticket_id'] is int
                ? data['ticket_id']
                : int.tryParse(data['ticket_id']?.toString() ?? '');

            print(
              '📋 [RealtimeService] Status Changed: $status for Ticket #$ticketId',
            );

            // Use lat/lng from status_changed event ONLY if the location is fresh.
            // (e.g. status_changed for 'assigned' carries driver location, but it
            //  might be a stale DB value stored days ago — check the timestamp!)
            final String? lastUpdatedAt = data['last_location_updated_at']
                ?.toString();
            final bool locationFresh = _isLocationFresh(lastUpdatedAt);

            if ((status == 'assigned' || status == 'reaching') &&
                data['driver_id'] != null &&
                _currentTicket != null) {
              final existingDriver = _currentTicket!.driver;

              String? newLat;
              String? newLng;
              if (locationFresh) {
                newLat = data['latitude']?.toString();
                newLng = data['longitude']?.toString();
                print(
                  '✅ [HomeScreen] Using fresh driver location from status_changed: lat=$newLat, lng=$newLng',
                );
              } else {
                // Keep any real GPS we already received; don't overwrite with stale data
                newLat = existingDriver?.latitude;
                newLng = existingDriver?.longitude;
                print(
                  '🚫 [HomeScreen] Ignoring stale location in status_changed ($lastUpdatedAt), keeping existing GPS.',
                );
              }

              final updatedDriver = TicketDriver(
                id: data['driver_id'],
                name: data['driver_name'] ?? existingDriver?.name,
                image: data['driver_image'] ?? existingDriver?.image,
                latitude: newLat,
                longitude: newLng,
              );
              final updatedTicket = _currentTicket!.copyWith(
                status: status,
                driver: updatedDriver,
              );
              _currentTicket = updatedTicket;
              context.read<TicketBloc>().add(
                UpdateTicketDetails(updatedTicket),
              );

              // If we have fresh location, push it to the map immediately
              if (locationFresh && newLat != null) {
                context.read<TicketBloc>().add(
                  UpdateDriverLocation(updatedDriver),
                );
              }
            } else if (_currentTicket != null && ticketId != null) {
              final updatedTicket = _currentTicket!.copyWith(status: status);
              context.read<TicketBloc>().add(
                UpdateTicketDetails(updatedTicket),
              );
            }

            setState(() {
              if (status == 'assigned' || status == 'reaching') {
                _currentServiceStage = 'reaching';
                _serviceProgress = 0.5;
              } else if (status == 'in_progress' ||
                  status == 'solving' ||
                  status == 'at_location') {
                _currentServiceStage = 'solving';
                _serviceProgress = 1.0;
              } else if (status == 'completed' || status == 'resolved') {
                _currentServiceStage = 'resolved';
                _stopPolling();
                _realtimeService?.disconnect();
              } else if (status == 'cancelled' || status == 'rejected') {
                _currentServiceStage = 'none';
                _stopPolling();
                _realtimeService?.disconnect();
                _currentTicket = null;
              } else {
                if (_currentTicket != null) {
                  _currentTicket = _currentTicket!.copyWith(status: status);
                }
              }
            });
          }
        },
        onDriverLocationUpdated: (data) {
          if (mounted && data is Map<String, dynamic>) {
            print('📍 [RealtimeService] Driver Location Updated: $data');
            // Support multiple key formats for driver lat/lng
            final String? lat =
                (data['latitude'] ??
                        data['driver_latitude'] ??
                        data['driver']?['latitude'])
                    ?.toString();
            final String? lng =
                (data['longitude'] ??
                        data['driver_longitude'] ??
                        data['driver']?['longitude'])
                    ?.toString();
            print(
              '📍 [HomeScreen] Driver real-time location: lat=$lat, lng=$lng',
            );
            final driver = TicketDriver(
              id: data['driver_id'],
              name: data['driver_name'],
              latitude: lat,
              longitude: lng,
            );
            context.read<TicketBloc>().add(UpdateDriverLocation(driver));
          }
        },
      );

      await _realtimeService!.connectAndSubscribe();
    } catch (e) {
      developer.log(
        '⚠️ [HomeScreen] Real-time service failed to start: $e',
        name: 'HomeScreen',
      );
    } finally {
      _isConnectingRealtime = false;
    }
  }

  String _userName = 'Mishal';

  @override
  void initState() {
    super.initState();
    activeState = this;
    _loadUserName();
    _getCurrentLocation();
    _fetchInitialData();
    CarPlayService.setupHandler();
  }

  void _fetchInitialData() {
    // These calls are now moved here from main.dart to prevent startup burst
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VehicleListBloc>().add(const FetchVehicles());
      context.read<BrandBloc>().add(FetchBrands());
      context.read<VehicleModelBloc>().add(FetchVehicleModels());
      context.read<IssueCategoryBloc>().add(FetchIssueCategories());
      context.read<ChargingTypeBloc>().add(FetchChargingTypes());
      context.read<ProfileBloc>().add(FetchProfile());
      context.read<LocationBloc>().add(FetchLocations());
    });
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
    _pollingTimer?.cancel();
    _realtimeService?.disconnect();
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
    print(
      '🎬 [HomeScreen] startServiceFlow called. Ticket provided: ${ticket != null}',
    );
    // Stop any existing polling
    _pollingTimer?.cancel();

    // Determine initial stage based on ticket status
    String initialStage = 'finding';
    if (ticket != null) {
      final status = ticket.status?.toLowerCase().trim();
      print(
        '📱 [HomeScreen] Starting flow for Ticket ID: ${ticket.id} (${ticket.ticketId}), Status: $status',
      );

      // Only jump to reaching if explicitly assigned or already in progress
      if (status == 'assigned' ||
          status == 'reaching' ||
          status == 'at_location') {
        initialStage = 'reaching';
        print('🚀 [HomeScreen] Initial stage: reaching (Status: $status)');
      } else {
        initialStage = 'finding';
        print('⏳ [HomeScreen] Initial stage: finding (Status: $status)');
      }
    } else {
      print(
        '⏳ [HomeScreen] No ticket object yet (likely post-payment). Defaulting stage to finding.',
      );
      initialStage = 'finding';
    }

    setState(() {
      _currentServiceStage = initialStage;
      _serviceProgress = 0.0;

      _currentTicket = ticket;
    });

    // Start Real-time WebSocket Service
    if (ticket != null) {
      // ⚠️ Do NOT push ticket.driver's lat/lng here — it is the last stored DB value
      // which may be stale (e.g. hardcoded San Francisco). Real-time GPS position
      // will arrive via driver.location.updated socket events. We only set the
      // driver's identity (name, id, image) so the UI card shows correctly.
      if (ticket.driver != null && mounted) {
        final driverIdentityOnly = TicketDriver(
          id: ticket.driver!.id,
          name: ticket.driver!.name,
          image: ticket.driver!.image,
          phone: ticket.driver!.phone,
          latitude: null, // intentionally null — wait for real-time GPS
          longitude: null, // intentionally null — wait for real-time GPS
        );
        context.read<TicketBloc>().add(
          UpdateDriverLocation(driverIdentityOnly),
        );
      }

      _initRealtimeService(ticket.customerId, ticket: ticket);
    } else {
      // If ticket is null, we try to get customer ID from ProfileBloc state
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        print(
          '👤 [HomeScreen] Found Customer ID from Profile: ${profileState.customer.id}',
        );
        _initRealtimeService(profileState.customer.id);
      } else {
        print(
          '⚠️ [HomeScreen] Cannot start RealtimeService: Profile not loaded and no ticket provided.',
        );
      }
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _updateStageFromTicket(Ticket ticket) {
    if (!mounted) return;

    setState(() {
      _currentTicket = ticket;
      final status = ticket.status?.toLowerCase().trim();

      // Priority 1: Check for completion or resolution ONLY
      if (status == 'completed' || status == 'resolved') {
        _realtimeService?.disconnect();
        _currentServiceStage = 'resolved'; // Show the Submit Feedback banner
        _stopPolling();
        developer.log(
          '🏁 [HomeScreen] Flow finished via status: $status',
          name: 'HomeScreen',
        );
        return;
      }

      if (status == 'cancelled' || status == 'rejected') {
        _realtimeService?.disconnect();
        _currentServiceStage = 'none';
        _stopPolling();
        developer.log(
          '❌ [HomeScreen] Flow finished via status: $status',
          name: 'HomeScreen',
        );
        return;
      }

      // Priority 2: Stage transitions based on status
      if (status == 'assigned' || status == 'reaching') {
        _serviceProgress = 0.5;
        // Only advance to reaching if we aren't already further ahead
        if (_currentServiceStage == 'finding' ||
            _currentServiceStage == 'none') {
          _currentServiceStage = 'reaching';
          print('🚀 [HomeScreen] Advanced to reaching stage (Status: $status)');
        }
      }

      if (status == 'solving' ||
          status == 'in_progress' ||
          status == 'at_location' ||
          status == 'reached') {
        _currentServiceStage = 'solving';
        _serviceProgress = 1.0;
        print('🛠️ [HomeScreen] Stage: solving (Status: $status)');
      }
    });
  }

  void handleCarPlayBooking(String categoryName) async {
    // 1. Get vehicle info
    final vehicleTypeId = await VehicleStorage.getVehicleTypeId();
    final brandId = await VehicleStorage.getBrandId();
    final modelId = await VehicleStorage.getModelId();
    final vehiclePlate = await VehicleStorage.getVehicleNumber() ?? "";

    if (vehicleTypeId == null || brandId == null || modelId == null) {
      showToast("Please select a vehicle in the app first");
      return;
    }

    // 2. Get category ID
    final categoryState = context.read<IssueCategoryBloc>().state;
    int? categoryId;
    if (categoryState is IssueCategoryLoaded) {
      final category = categoryState.categories.firstWhere(
        (c) =>
            c.name?.toLowerCase().contains(categoryName.toLowerCase()) ?? false,
        orElse: () => categoryState.categories.first,
      );
      categoryId = category.id;
    }

    // 3. Dispatch event
    final request = CreateTicketRequest(
      issueCategoryId: categoryId ?? 1,
      vehicleTypeId: vehicleTypeId,
      brandId: brandId,
      modelId: modelId,
      numberPlate: vehiclePlate,
      location: currentAddress,
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      bookingType: "instant",
      scheduledAt: DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now().toUtc()),
      paymentMethod: "cod", // Default for CarPlay for now
    );

    if (mounted) {
      context.read<TicketBloc>().add(CreateTicketRequested(request));
    }
  }

  void _showVehicleSelectionBottomSheet(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (state is VehicleListLoading) {
                    final skeletonCount =
                        (state.totalCount > 0 ? state.totalCount : 3).clamp(
                          1,
                          5,
                        );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        ...List.generate(
                          skeletonCount,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildShimmerCarItem(),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is VehicleListError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(fontFamily: 'Lufga'),
                        ),
                      ),
                    );
                  }

                  final vehicleList = state is VehicleListLoaded
                      ? state.vehicles
                      : <VehicleListItem>[];

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
                        padding: EdgeInsets.only(bottom: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicleList.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicleList[index];
                          final isSelected = selectedVehicleIndex == index;
                          return GestureDetector(
                            onTap: () async {
                              setListState(() {
                                selectedVehicleIndex = index;
                              });

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
                              if (!context.mounted) return;
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
                              padding: EdgeInsets.only(
                                bottom: index == vehicleList.length - 1
                                    ? 0
                                    : 12,
                              ),
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
              const SizedBox(height: 8),
              // Add Vehicle Button
              OneBtn(
                text: "Add Vehicle",
                onPressed: () async {
                  final homeContext = this.context;
                  // Close the bottom sheet
                  Navigator.pop(context);
                  // Navigate to Vehicle Selection screen
                  await Navigator.push(
                    homeContext,
                    MaterialPageRoute(
                      builder: (context) => const VehicleSelection(),
                    ),
                  );
                  // Refresh the vehicle list after returning
                  if (homeContext.mounted) {
                    homeContext.read<VehicleListBloc>().add(
                      const FetchVehicles(forceRefresh: true),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
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
    final String imgPath = imageUrl?.trim() ?? '';

    if (imgPath.isNotEmpty) {
      if (imgPath.startsWith('http')) {
        imageWidget = Image.network(
          imgPath,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 50, color: Colors.grey),
        );
      } else if (imgPath.startsWith('assets/')) {
        imageWidget = Image.asset(
          imgPath,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 50, color: Colors.grey),
        );
      } else {
        imageWidget = Image.network(
          imgPath,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 50, color: Colors.grey),
        );
      }
    } else {
      imageWidget = const Icon(
        Icons.directions_car,
        size: 50,
        color: Colors.grey,
      );
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
          Positioned(right: 0, top: 0, bottom: 0, child: imageWidget),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationAdded) {
              showToast('Location added successfully');
            }
          },
        ),
        BlocListener<TicketBloc, TicketState>(
          listener: (context, state) {
            if (state is TicketSuccess) {
              final requiresPayment =
                  state.response.data?.paymentRequired == true &&
                  state.response.data?.paymentUrl != null;

              if (!requiresPayment) {
                startServiceFlow(ticket: state.response.data?.ticket);
                showToast("Booking Successful!");
                CarPlayService.showBookingSuccess(
                  latitude: double.tryParse(
                    state.response.data?.ticket?.latitude ?? '',
                  ),
                  longitude: double.tryParse(
                    state.response.data?.ticket?.longitude ?? '',
                  ),
                );
              }
            } else if (state is TicketDetailSuccess) {
              _updateStageFromTicket(state.ticket);
            } else if (state is DriverLocationLoaded) {
              if (state.driver != null && _currentTicket != null) {
                _updateStageFromTicket(
                  _currentTicket!.copyWith(driver: state.driver),
                );
              }
            } else if (state is TicketError) {
              showToast("Error: ${state.message}");
            }
          },
        ),
      ],
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
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                            if (result is LocationModel) {
                              setState(() {
                                currentAddress = result.name.isNotEmpty
                                    ? result.name
                                    : result.address;
                                _currentLatitude = result.latitude;
                                _currentLongitude = result.longitude;
                              });
                            }
                          },
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              String? imageUrl;
                              if (state is ProfileLoaded) {
                                imageUrl = state.customer.profileImage;
                              } else if (state is ProfileUpdated) {
                                imageUrl = state.customer.profileImage;
                              } else if (state is ProfileUpdating) {
                                imageUrl = state.currentCustomer.profileImage;
                              }
                              return CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                  imageUrl ??
                                      'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                ),
                              );
                            },
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
                                  if (state is Authenticated) {
                                    name = state.user.name.split(' ')[0];
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
                                      currentAddress = result.name.isNotEmpty
                                          ? result.name
                                          : result.address;
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
              // Floating Notification Overlay (PURELY REACTIVE)
              if (_currentServiceStage != 'none')
                ServiceNotificationOverlay(
                  stage: _currentServiceStage,
                  progress: _serviceProgress,
                  ticket: _currentTicket,
                  onDismiss: () {
                    showToast("Our customer support will contact you shortly");
                    setState(() {
                      _currentServiceStage = 'none';
                      _stopPolling();
                      _currentTicket = null;
                    });
                  },
                  onSolved: () {
                    final tId = _currentTicket?.id;
                    setState(() {
                      _currentServiceStage = 'none';
                      _stopPolling();
                      _currentTicket = null;
                    });
                    if (tId != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            FeedbackBottomSheet(ticketId: tId),
                      );
                    }
                  },
                  onTap: () {
                    if (_currentTicket != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackingMapScreen(
                            ticket: _currentTicket!,
                            stage: _currentServiceStage,
                            progress: _serviceProgress,
                          ),
                        ),
                      ).then((showFeedback) {
                        if (showFeedback == true && _currentTicket != null) {
                          final tId = _currentTicket?.id;
                          setState(() {
                            _currentServiceStage = 'none';
                            _stopPolling();
                            _currentTicket = null;
                          });
                          if (tId != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  FeedbackBottomSheet(ticketId: tId),
                            );
                          }
                        }
                      });
                    }
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
