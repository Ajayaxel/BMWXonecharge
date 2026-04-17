import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/screen/home/widgets/success_bottom_sheet.dart';
import 'package:onecharge/screen/payment/payment_webview_screen.dart';
import 'booking_steps/booking_location_step.dart';
import 'booking_steps/booking_service_step.dart';
import 'booking_steps/booking_slot_step.dart';
import 'booking_steps/booking_payment_step.dart';
import 'booking_steps/booking_options_sheet.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/screen/settings/my_location_screen.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/models/issue_category_model.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/core/storage/vehicle_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_bloc.dart';
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_event.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_bloc.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_event.dart';
import 'package:onecharge/logic/blocs/company_code/company_code_state.dart';

class IssueReportingScreen extends StatefulWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String vehicleImage;
  final String currentAddress;
  final double latitude;
  final double longitude;
  final int? locationId;
  final String? initialCategory;
  final DateTime? initialDateTime;

  const IssueReportingScreen({
    super.key,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.vehicleImage,
    required this.currentAddress,
    required this.latitude,
    required this.longitude,
    this.locationId,
    this.initialCategory,
    this.initialDateTime,
  });

  @override
  State<IssueReportingScreen> createState() => _IssueReportingScreenState();
}

class _IssueReportingScreenState extends State<IssueReportingScreen> {
  String _selectedCategory = "Low Battery";
  IssueCategory? _selectedCategoryObj;
  String _currentAddress = "";
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  int? _selectedLocationId;
  LocationModel? _selectedLocation;
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _slotController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  OverlayEntry? _toastEntry;
  final TextEditingController _parkingLocationController =
      TextEditingController();
  IssueSubType? _selectedChargeUnit;
  final ValueNotifier<String> _selectedPaymentMethodNotifier =
      ValueNotifier<String>("company");
  final TextEditingController _companyCodeController = TextEditingController();
  final TextEditingController _redeemCodeController = TextEditingController();
  String? _appliedRedeemCode;
  String _selectedLocationType = "Inside";
  String? _parkingFloor;
  String? _parkingNumber;
  String? _parkingType;
  bool _isInstantBooking = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!.replaceAll('\n', ' ');
    }

    if (widget.initialDateTime != null) {
      _selectedDateTime = widget.initialDateTime!;
    } else {
      DateTime now = DateTime.now();
      // Default to nearest slot from now
      int minutes = now.minute;
      if (minutes <= 30) {
        _selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          30,
        );
      } else {
        _selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
          00,
        );
      }
    }
    _currentAddress = widget.currentAddress;
    _currentLatitude = widget.latitude;
    _currentLongitude = widget.longitude;
    _selectedLocationId = widget.locationId;

    // _slotController.text =
    //     "${DateFormat('MMM dd').format(_selectedDateTime)}, ${DateFormat('hh:mm a').format(_selectedDateTime)}";

    // Only fetch current coordinates if we don't have them
    if (_currentLatitude == 0.0) {
      _getCurrentCoordinates();
    }

    // Reset blocs to clear previous state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CompanyCodeBloc>().add(ResetCompanyCode());
        context.read<RedeemCodeBloc>().add(ResetRedeemCode());
        context.read<LocationBloc>().add(FetchLocations());
      }
    });
  }

  Future<void> _getCurrentCoordinates() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      // Default to Dubai if location fails
      if (mounted) {
        setState(() {
          _currentLatitude = 25.2048;
          _currentLongitude = 55.2708;
        });
      }
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _slotController.dispose();
    _parkingLocationController.dispose();
    _redeemCodeController.dispose();
    _companyCodeController.dispose();
    _selectedPaymentMethodNotifier.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  void _showToast(String message) {
    _toastEntry?.remove();
    _toastEntry = null;

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40,
              ),
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
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_toastEntry == entry) {
        _toastEntry?.remove();
        _toastEntry = null;
      }
    });
  }

  String _formatErrorMessage(String error) {
    // If it's a validation error from API
    if (error.contains('errors:')) {
      try {
        // Extract errors object string
        final startIndex = error.indexOf('errors: {') + 8;
        final endIndex = error.lastIndexOf('}');
        if (startIndex > 7 && endIndex > startIndex) {
          String errorsPart = error.substring(startIndex, endIndex);
          // Look for [error message]
          final match = RegExp(r'\[(.*?)\]').firstMatch(errorsPart);
          if (match != null && match.groupCount >= 1) {
            return match.group(1) ?? "Validation failed";
          }
        }
      } catch (e) {
        // Fallback below
      }
    }

    // Clean up generic API error prefixes
    return error
        .replaceFirst('Exception: ', '')
        .replaceFirst('API Error: ', '')
        .split(' - ')
        .last
        .replaceAll('{success: false, message: ', '')
        .split(',')[0]
        .replaceAll('}', '');
  }

  Future<void> _pickMedia() async {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Select Source'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.gallery, isMulti: true);
              },
              child: const Text('Photo Gallery'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _handleVideoPick();
              },
              child: const Text('Video'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(ImageSource.gallery, isMulti: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _handleVideoPick();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
  }

  Future<void> _handleImagePick(
    ImageSource source, {
    bool isMulti = false,
  }) async {
    try {
      if (isMulti && source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 70,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(images.map((img) => File(img.path)));
          });
        }
      } else {
        final XFile? photo = await _picker.pickImage(
          source: source,
          imageQuality: 70,
        );
        if (photo != null) {
          setState(() {
            _selectedFiles.add(File(photo.path));
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _handleVideoPick() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedFiles.add(File(video.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }
  // Slot picker logic is now handled within BookingSlotStep widget.

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketSuccess) {
          _handleTicketSuccess(state);
        } else if (state is TicketError) {
          _showToast(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildStepper(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    BookingLocationStep(
                      latitude: _currentLatitude,
                      longitude: _currentLongitude,
                      currentAddress: _currentAddress,
                      selectedLocation: _selectedLocation,
                      selectedLocationType: _selectedLocationType,
                      onLocationPickerTap: _openLocationPicker,
                      onLocationSelected: (loc) =>
                          setState(() => _selectedLocation = loc),
                      onLocationTypeChanged: (val) =>
                          setState(() => _selectedLocationType = val),
                      onNext: (floor, number, type) {
                        setState(() {
                          _parkingFloor = floor;
                          _parkingNumber = number;
                          _parkingType = type;
                        });
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastLinearToSlowEaseIn,
                        );
                      },
                    ),
                    BlocBuilder<IssueCategoryBloc, IssueCategoryState>(
                      builder: (context, state) {
                        if (state is IssueCategoryLoading) {
                          return _buildStepContainer(
                            child: const _BookingServiceSkeleton(),
                          );
                        }

                        if (state is IssueCategoryLoaded &&
                            _selectedCategoryObj == null) {
                          final categories = state.categories
                              .where((c) => c.name != null)
                              .toList();
                          if (categories.isNotEmpty) {
                            final initialCat = widget.initialCategory != null
                                ? categories.firstWhere(
                                    (c) =>
                                        c.name?.toLowerCase() ==
                                        widget.initialCategory!
                                            .toLowerCase()
                                            .replaceAll('\n', ' '),
                                    orElse: () => categories.first,
                                  )
                                : categories.first;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _selectedCategoryObj = initialCat;
                                  _selectedCategory = initialCat.name ?? '';
                                  if (initialCat.subTypes.isNotEmpty) {
                                    _selectedChargeUnit =
                                        initialCat.subTypes.first;
                                  }
                                });
                              }
                            });
                          }
                        }

                        return _buildStepContainer(
                          child: BookingServiceStep(
                            selectedCategory: _selectedCategory,
                            selectedCategoryObj: _selectedCategoryObj,
                            selectedChargeUnit: _selectedChargeUnit,
                            issueController: _issueController,
                            selectedFiles: _selectedFiles,
                            onPickMedia: _pickMedia,
                            onRemoveFile: (idx) =>
                                setState(() => _selectedFiles.removeAt(idx)),
                            onServiceSelected: (unit) =>
                                setState(() => _selectedChargeUnit = unit),
                            onNext: () => _showBookingOptionsSheet(),
                            onBack: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastLinearToSlowEaseIn,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildStepContainer(
                      child: BookingSlotStep(
                        selectedDateTime: _selectedDateTime,
                        isSlotSelected: _slotController.text.isNotEmpty,
                        onDateTimeChanged: (dt) {
                          setState(() {
                            _selectedDateTime = dt;
                            _slotController.text =
                                "${DateFormat('MMM dd').format(dt)}, ${DateFormat('hh:mm a').format(dt)}";
                          });
                        },
                        onNext: () {
                          if (_slotController.text.isEmpty) {
                            _showToast("Please select a Slot");
                            return;
                          }
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastLinearToSlowEaseIn,
                          );
                        },
                        onBack: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastLinearToSlowEaseIn,
                        ),
                      ),
                    ),
                    _buildStepContainer(
                      child: BookingPaymentStep(
                        redeemCodeController: _redeemCodeController,
                        appliedRedeemCode: _appliedRedeemCode,
                        selectedPaymentMethodNotifier:
                            _selectedPaymentMethodNotifier,
                        companyCodeController: _companyCodeController,
                        onSubmit: () =>
                            _submitTicket(isInstant: _isInstantBooking),
                        onInstantBooking: () => _submitTicket(isInstant: true),
                        onBack: () {
                          if (_isInstantBooking) {
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastLinearToSlowEaseIn,
                            );
                          } else {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastLinearToSlowEaseIn,
                            );
                          }
                        },
                        showToast: _showToast,
                        formatErrorMessage: _formatErrorMessage,
                        vehicleName: widget.vehicleName,
                        vehiclePlate: widget.vehiclePlate,
                        vehicleImage: widget.vehicleImage,
                        address: _currentAddress,
                        serviceCategory: _selectedCategory,
                        chargeUnit: _selectedChargeUnit?.name,
                        selectedDateTime: _isInstantBooking
                            ? null
                            : _selectedDateTime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GoogleMapController? _mapControllerMock;

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentStep == 0) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Row(
              children: [
                _buildStepIndicator(0, "Location", displayNumber: 1),
                _buildStepLine(0),
                _buildStepIndicator(1, "Service", displayNumber: 2),
                _buildStepLine(1),
                if (!_isInstantBooking) ...[
                  _buildStepIndicator(2, "Slot", displayNumber: 3),
                  _buildStepLine(2),
                ],
                _buildStepIndicator(
                  3,
                  "Payment",
                  displayNumber: _isInstantBooking ? 3 : 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label, {
    required int displayNumber,
  }) {
    bool isActive = _currentStep == step;
    bool isCompleted = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? Colors.black : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isCompleted
                  ? Colors.black
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              "$displayNumber",
              style: TextStyle(
                color: isActive || isCompleted ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lufga',
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive || isCompleted
                ? Colors.black
                : Colors.grey.shade500,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Lufga',
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isCompleted ? Colors.black : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepContainer({required Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentStep),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }

  void _handleTicketSuccess(TicketSuccess state) {
    final requiresPayment =
        state.response.data?.paymentRequired == true &&
        state.response.data?.paymentUrl != null;
    if (requiresPayment) {
      final homeContext = HomeScreenState.activeState?.context;
      final paymentUrl = state.response.data!.paymentUrl!;
      final intentionId = state.response.data?.intentionId;

      Navigator.pop(context); // Close IssueReportingScreen

      if (homeContext != null) {
        Navigator.push(
          homeContext,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: paymentUrl,
              intentionId: intentionId,
            ),
          ),
        ).then((paymentSuccess) {
          if (paymentSuccess == true) {
            showModalBottomSheet(
              context: homeContext,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const SuccessBottomSheet(),
            );
          }
        });
      }
    } else {
      final breakdown = state.response.data?.paymentBreakdown;
      final invoice = state.response.data?.ticket?.invoice;
      final totalAmount = breakdown?.totalAmount ?? invoice?.totalAmount;
      final currency = breakdown?.currency ?? invoice?.currency ?? "AED";
      final String toastMsg = (totalAmount != null && totalAmount > 0)
          ? "Ticket created successfully! Total Amount: ${totalAmount.toStringAsFixed(2)} $currency"
          : "Ticket created successfully!";

      HomeScreenState.activeState?.showToast(toastMsg);
      HomeScreenState.activeState?.startServiceFlow(
        ticket: state.response.data?.ticket,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const MyLocationScreen(isPicker: true),
      ),
    );
    if (result != null) {
      setState(() {
        _currentAddress = result.name.isNotEmpty ? result.name : result.address;
        _currentLatitude = result.latitude;
        _currentLongitude = result.longitude;
      });
      // Persist manual selection
      await LocationStorage.saveSelectedLocation(
        address: _currentAddress,
        lat: _currentLatitude,
        lng: _currentLongitude,
        isManual: true,
        id: result.id,
      );
      // Update HomeScreen if it's visible
      HomeScreenState.activeState?.updateLocation(
        _currentAddress,
        _currentLatitude,
        _currentLongitude,
        id: result.id,
      );
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: const TextStyle(fontFamily: 'Lufga', fontSize: 14),
      ),
    );
  }

  Future<void> _submitTicket({required bool isInstant}) async {
    // Validation
    if (!isInstant && _slotController.text.isEmpty) {
      _showToast("Please select a Slot");
      return;
    }

    // New validation for "Pay By Company"
    if (_selectedPaymentMethodNotifier.value == "company") {
      final companyCodeState = context.read<CompanyCodeBloc>().state;
      if (companyCodeState is! CompanyCodeSuccess) {
        _showToast("Please enter company code or select other payment option");
        return;
      }
    }

    // Check if "Other" category requires description
    // Check if "Other" category requires description
    // if (_selectedCategoryObj?.id == 6) {
    //   if (_selectedFiles.isEmpty) {
    //     _showToast("Please upload issue images for 'Other' category");
    //     return;
    //   }
    // }

    // Validate submodel if category has subTypes
    if (_selectedCategoryObj != null &&
        _selectedCategoryObj!.subTypes.isNotEmpty &&
        _selectedChargeUnit == null) {
      _showToast("Please select a charge unit");
      return;
    }

    // Get vehicle IDs from storage
    final vehicleTypeId = await VehicleStorage.getVehicleTypeId();
    final brandId = await VehicleStorage.getBrandId();
    final modelId = await VehicleStorage.getModelId();

    // Validate that all required IDs are present
    if (vehicleTypeId == null || brandId == null || modelId == null) {
      _showToast(
        "Vehicle information is incomplete. Please select a vehicle again.",
      );
      return;
    }

    // ── Company Code ──────────────────────────────────────────────────────
    final companyCodeState = context.read<CompanyCodeBloc>().state;
    String? appliedCompanyCode;
    int? appliedCompanyCodeId;
    if (companyCodeState is CompanyCodeSuccess &&
        companyCodeState.response.data != null) {
      final ccData = companyCodeState.response.data!;
      appliedCompanyCode = ccData.code.isNotEmpty ? ccData.code : null;
      appliedCompanyCodeId = ccData.companyCodeId > 0
          ? ccData.companyCodeId
          : null;
    }

    // Create ticket request
    // ── Redeem Code ───────────────────────────────────────────────────────
    final String? redeemCode =
        (_appliedRedeemCode != null && _appliedRedeemCode!.isNotEmpty)
        ? _appliedRedeemCode
        : null;

    // ── Payment Method ────────────────────────────────────────────────────
    // Always send "online" as shown in the user's screenshots.
    // The presence of companyCode will determine if payment is required.
    final String paymentMethod = "online";

    final request = CreateTicketRequest(
      issueCategoryId: _selectedCategoryObj?.id ?? 1,
      issueCategorySubTypeId: _selectedChargeUnit?.id,
      vehicleTypeId: vehicleTypeId,
      brandId: brandId,
      modelId: modelId,
      numberPlate: widget.vehiclePlate,
      description: _issueController.text.trim().isNotEmpty
          ? _issueController.text.trim()
          : null,
      location: _currentAddress,
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      attachments: _selectedFiles.isNotEmpty ? _selectedFiles : null,
      redeemCode: redeemCode,
      companyCode: appliedCompanyCode,
      companyCodeId: appliedCompanyCodeId,
      paymentMethod: paymentMethod,
      bookingType: isInstant ? "instant" : "scheduled",
      scheduledAt: isInstant
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc())
          : DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime.toUtc()),
      parkingFloor: _parkingFloor,
      parkingNumber: _parkingNumber,
      parkingType: _parkingType,
    );

    // Dispatch create ticket event
    if (mounted) {
      context.read<TicketBloc>().add(CreateTicketRequested(request));
    }
  }

  void _showBookingOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BookingOptionsSheet(
        onInstantSelected: () {
          Navigator.pop(context);
          setState(() {
            _isInstantBooking = true;
          });
          _pageController.animateToPage(
            3, // Step 4 (Payment)
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastLinearToSlowEaseIn,
          );
        },
        onScheduledSelected: () {
          Navigator.pop(context);
          setState(() {
            _isInstantBooking = false;
          });
          _pageController.animateToPage(
            2, // Step 3 (Slot)
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastLinearToSlowEaseIn,
          );
        },
      ),
    );
  }
}

class _BookingServiceSkeleton extends StatelessWidget {
  const _BookingServiceSkeleton();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 360;
    final double crossSpacing = isSmallDevice ? 20.0 : 30.0;
    final double mainExtent = screenWidth > 600 ? 360 : 340;

    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: crossSpacing,
                      mainAxisSpacing: 20,
                      mainAxisExtent: mainExtent,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            width: 130,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: 100,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 70,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
