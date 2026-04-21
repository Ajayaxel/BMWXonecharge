import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'package:onecharge/screen/home/widgets/carbon/carbon_banner.dart';
import 'package:onecharge/screen/home/widgets/service_notification.dart';
import 'package:onecharge/screen/home/widgets/feedback_bottom_sheet.dart';
import 'package:onecharge/screen/home/widgets/cancellation_bottom_sheet.dart';
import 'package:onecharge/core/mixins/location_handler_mixin.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/screen/settings/my_location_screen.dart';
import 'package:onecharge/screen/settings/settings_screen.dart';
import 'package:onecharge/screen/notification/notification_screen.dart';
import 'package:onecharge/screen/wallet/wallet_screen.dart';
import 'package:onecharge/core/storage/location_storage.dart';

import 'package:onecharge/screen/home/widgets/tracking_map_screen.dart';
import 'package:onecharge/logic/services/realtime_service.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_event.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:onecharge/core/storage/token_storage.dart';
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
import 'package:onecharge/logic/blocs/shop_category/shop_category_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_event.dart';
import 'package:onecharge/screen/home/widgets/home_service_groups.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_bloc.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_event.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_bloc.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_event.dart';
import 'package:onecharge/screen/home/widgets/home_product_groups.dart';
import 'package:onecharge/screen/home/widgets/vehicle_selection_bottom_sheet.dart';
import 'package:onecharge/widgets/banner_section.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_event.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_state.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/screens/combo_buy_screen.dart';

import 'package:onecharge/logic/blocs/service_banner/service_banner_bloc.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_event.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_state.dart';
import 'package:onecharge/models/service_banner_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with LocationHandlerMixin {
  static HomeScreenState? activeState;
  int selectedIndex = -1;
  String _currentServiceStage = 'none';
  double _serviceProgress = 0.0;
  Timer? _serviceTimer;
  Timer? _pollingTimer;
  RealtimeService? _realtimeService;
  Ticket? _currentTicket;
  bool _isConnectingRealtime = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;

  int _bannerCount = 0;

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_bannerCount > 0) {
        if (_currentPage < _bannerCount - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

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

  @override
  void initState() {
    super.initState();
    activeState = this;
    _pageController = PageController(initialPage: 0);
    _startCarouselTimer();
    loadSavedLocation();
    _loadUserName();
    _fetchInitialData();
    CarPlayService.setupHandler();

    // Initial CarPlay sync if categories are already loaded
    final initialCategoryState = context.read<IssueCategoryBloc>().state;
    if (initialCategoryState is IssueCategoryLoaded) {
      CarPlayService.updateServices(initialCategoryState.categories);
    }

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
      context.read<ShopCategoryBloc>().add(FetchShopCategories());
      context.read<ServiceGroupBloc>().add(const FetchServiceGroups());
      context.read<ProductGroupBloc>().add(FetchProductGroups());
      context.read<ComboOfferBloc>().add(FetchComboOffers());
      context.read<ServiceBannerBloc>().add(FetchServiceBanner());
    });
  }

  Future<void> _loadUserName() async {
    final name = await TokenStorage.readUserName();
    if (name != null) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    activeState = null;
    _serviceTimer?.cancel();
    _pollingTimer?.cancel();
    _realtimeService?.disconnect();
    _pageController.dispose();
    _carouselTimer?.cancel();
    searchController.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  void updateLocation(String address, double lat, double lng, {int? id}) {
    if (mounted) {
      // If address is null or empty, fallback to current location
      if (address.isEmpty || address == "Fetching location...") {
        getCurrentLocation();
        return;
      }
      setState(() {
        currentAddress = address;
        currentLatitude = lat;
        currentLongitude = lng;
        selectedLocationId = id;
      });
    }
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
      latitude: currentLatitude,
      longitude: currentLongitude,
      bookingType: "instant",
      scheduledAt: DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now().toUtc()),
      paymentMethod: "company", // Updated from "cod" as it was removed from API
    );

    if (mounted) {
      context.read<TicketBloc>().add(CreateTicketRequested(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationAdded) {
              showToast('Location added successfully');
            } else if (state is LocationsLoaded) {
              validateCurrentLocation(state.locations);

              if (state.selectedLocation != null) {
                final loc = state.selectedLocation!;
                setState(() {
                  currentAddress = loc.name.isNotEmpty ? loc.name : loc.address;
                  currentLatitude = loc.latitude;
                  currentLongitude = loc.longitude;
                  selectedLocationId = loc.id;
                });
              }
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
            } else if (state is TicketError) {
              String message = state.message;
              if (message.contains('errors:')) {
                final match = RegExp(r'\[(.*?)\]').firstMatch(message);
                if (match != null && match.groupCount >= 1) {
                  message = match.group(1) ?? message;
                }
              }
              final formattedMessage = message
                  .replaceFirst('Exception: ', '')
                  .replaceFirst('Failed to create ticket: ', '')
                  .split(' - ')
                  .last
                  .replaceAll('{success: false, message: ', '')
                  .split(',')[0]
                  .replaceAll('}', '');
              showToast(formattedMessage);
            } else if (state is DriverLocationLoaded) {
              if (state.driver != null && _currentTicket != null) {
                _updateStageFromTicket(
                  _currentTicket!.copyWith(driver: state.driver),
                );
              }
            }
          },
        ),
        BlocListener<IssueCategoryBloc, IssueCategoryState>(
          listener: (context, state) {
            if (state is IssueCategoryLoaded) {
              CarPlayService.updateServices(state.categories);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background backing for top overscroll
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Immersive Header & Carousel Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.62,
                    child: Stack(
                      children: [
                        // Auto-Scrolling Background Carousel
                        BlocBuilder<ServiceBannerBloc, ServiceBannerState>(
                          builder: (context, state) {
                            if (state is ServiceBannerLoaded) {
                              final banners = state.banners;
                              // Update banner count for timer safety
                              _bannerCount = banners.length;

                              if (banners.isEmpty) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text("No banners available"),
                                  ),
                                );
                              }
                              return PageView.builder(
                                controller: _pageController,
                                physics: const ClampingScrollPhysics(),
                                onPageChanged: (int page) {
                                  setState(() {
                                    _currentPage = page;
                                  });
                                },
                                itemCount: banners.length,
                                itemBuilder: (context, index) {
                                  return _buildCarouselItem(banners[index]);
                                },
                              );
                            }
                            return _buildBannerSkeleton();
                          },
                        ),

                        // Static UI overlay (Header & Search)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              // Custom Header Row
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen(),
                                        ),
                                      );
                                      if (result is LocationModel) {
                                        updateLocation(
                                          result.name.isNotEmpty
                                              ? result.name
                                              : result.address,
                                          result.latitude,
                                          result.longitude,
                                          id: result.id,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      child:
                                          BlocBuilder<
                                            ProfileBloc,
                                            ProfileState
                                          >(
                                            builder: (context, state) {
                                              String? imageUrl;
                                              if (state is ProfileLoaded) {
                                                imageUrl =
                                                    state.customer.profileImage;
                                              }
                                              return CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.white10,
                                                backgroundImage:
                                                    imageUrl != null &&
                                                        imageUrl.isNotEmpty
                                                    ? NetworkImage(imageUrl)
                                                    : null,
                                                child:
                                                    imageUrl == null ||
                                                        imageUrl.isEmpty
                                                    ? const Icon(
                                                        Icons.person_rounded,
                                                        color: Colors.white,
                                                        size: 24,
                                                      )
                                                    : null,
                                              );
                                            },
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  BlocBuilder<ProfileBloc, ProfileState>(
                                    builder: (context, state) {
                                      String firstName = "User";
                                      if (state is ProfileLoaded) {
                                        firstName = state.customer.name
                                            .split(' ')
                                            .first;
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            firstName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Lufga',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          GestureDetector(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push<
                                                    LocationModel
                                                  >(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MyLocationScreen(
                                                            isPicker: true,
                                                          ),
                                                    ),
                                                  );
                                              if (result != null) {
                                                context
                                                    .read<LocationBloc>()
                                                    .add(
                                                      SelectLocation(result),
                                                    );
                                                updateLocation(
                                                  result.name.isNotEmpty
                                                      ? result.name
                                                      : result.address,
                                                  result.latitude,
                                                  result.longitude,
                                                  id: result.id,
                                                );
                                                await LocationStorage.saveSelectedLocation(
                                                  address:
                                                      result.name.isNotEmpty
                                                      ? result.name
                                                      : result.address,
                                                  lat: result.latitude,
                                                  lng: result.longitude,
                                                  isManual: true,
                                                  id: result.id,
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.4,
                                                  child: Text(
                                                    currentAddress,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: 11,
                                                      fontFamily: 'Lufga',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const WalletScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificationScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Search Component
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value.toLowerCase();
                                    });
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lufga',
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Search your Service",
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'Lufga',
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: Colors.white70,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // services section
                          HomeServiceGroups(
                            searchQuery: searchQuery,
                            onServiceSelected: (categoryName, categoryId) {
                              VehicleSelectionBottomSheet.show(
                                context,
                                category: categoryName,
                                currentAddress: currentAddress,
                                currentLatitude: currentLatitude,
                                currentLongitude: currentLongitude,
                                selectedLocationId: selectedLocationId,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          //carbon emmision banner
                          BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              String? firstName;
                              if (state is ProfileLoaded) {
                                firstName = state.customer.name
                                    .split(' ')
                                    .first;
                              }
                              return CarbonBanner(userName: firstName);
                            },
                          ),
                          const SizedBox(height: 16),
                          //products section
                          HomeProductGroups(searchQuery: searchQuery),
                          const SizedBox(height: 20),
                          BlocBuilder<ComboOfferBloc, ComboOfferState>(
                            builder: (context, state) {
                              final offer =
                                  state is ComboOfferLoaded &&
                                      state.comboOffers.isNotEmpty
                                  ? state.comboOffers.firstWhere(
                                      (o) => o.id == 2,
                                      orElse: () => state.comboOffers.first,
                                    )
                                  : null;

                              return BannerSection(
                                image: offer != null
                                    ? offer.imageUrl
                                    : "https://static.vecteezy.com/system/resources/previews/059/007/249/non_2x/ev-charger-station-transparent-background-free-png.png",
                                title: offer != null
                                    ? offer.name
                                    : "Mega Deals on EV Accessories ⚡",
                                subtitle: offer != null
                                    ? offer.description
                                    : "Grab exclusive discounts on top-quality upgrades for your ride.",
                                buttonText: "Shop Deals",
                                comboPrice: offer?.comboPrice,
                                originalPrice: offer?.originalPrice,
                                onTap: () {
                                  if (offer != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ComboBuyScreen(
                                          offer: offer,
                                          initialAddress: currentAddress,
                                          initialLatitude: currentLatitude,
                                          initialLongitude: currentLongitude,
                                        ),
                                      ),
                                    );
                                  } else {
                                    showToast("Fetching latest deals...");
                                    context.read<ComboOfferBloc>().add(
                                      FetchComboOffers(),
                                    );
                                  }
                                },
                              );
                            },
                          ),

                          const SizedBox(
                            height: 100,
                          ), // Bottom padding for scrolling
                        ],
                      ),
                    ),
                  ),

                  // Floating Notification Overlay (PURELY REACTIVE)
                  if (_currentServiceStage != 'none')
                    ServiceNotificationOverlay(
                      stage: _currentServiceStage,
                      progress: _serviceProgress,
                      ticket: _currentTicket,
                      onDismiss: () {
                        showToast(
                          "Our customer support will contact you shortly",
                        );
                        setState(() {
                          _currentServiceStage = 'none';
                          _stopPolling();
                          _currentTicket = null;
                        });
                      },
                      onCancel: () async {
                        if (_currentTicket?.id == null) return;
                        final shouldClear = await showModalBottomSheet<bool>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => CancellationBottomSheet(
                            ticketId: _currentTicket!.id,
                          ),
                        );

                        if (shouldClear == true) {
                          setState(() {
                            _currentServiceStage = 'none';
                            _stopPolling();
                            _realtimeService?.disconnect();
                            _currentTicket = null;
                          });
                        }
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
                            if (showFeedback == true &&
                                _currentTicket != null) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(ServiceBanner banner) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(banner.bgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Dark top gradient for white header visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          // Coupon Content
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  banner.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                    overflow: TextOverflow.ellipsis,

                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 36),
                // Enhanced Visibility Voucher Bar with Glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.70,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "USECODE : ${banner.code}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lufga',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: banner.code),
                              );
                              showToast("Code copied to clipboard!");
                            },
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSkeleton() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Match the immersive background
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[200]!,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Skeleton for the column content at bottom: 60
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Title skeleton
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Voucher bar skeleton
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
