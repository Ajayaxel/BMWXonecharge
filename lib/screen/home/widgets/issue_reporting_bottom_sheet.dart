import 'package:flutter/material.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:io';
import 'package:onecharge/const/onebtn.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/screen/home/widgets/payment_bottom_sheet.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/screen/settings/my_location_screen.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
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
import 'package:onecharge/logic/blocs/redeem_code/redeem_code_state.dart';
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

    _slotController.text =
        "${DateFormat('MMM dd').format(_selectedDateTime)}, ${DateFormat('hh:mm a').format(_selectedDateTime)}";

    // Only fetch current coordinates if we don't have them
    if (_currentLatitude == 0.0) {
      _getCurrentCoordinates();
    }

    // Reset blocs to clear previous state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CompanyCodeBloc>().add(ResetCompanyCode());
        context.read<RedeemCodeBloc>().add(ResetRedeemCode());
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

  void _validateCurrentLocation(List<LocationModel> locations) async {
    if (_selectedLocationId != null) {
      final exists = locations.any((loc) => loc.id == _selectedLocationId);
      if (!exists) {
        // Current location was deleted, fallback to GPS
        await LocationStorage.clearSelectedLocation();
        if (mounted) {
          setState(() {
            _selectedLocationId = null;
          });
          // Also sync fallback to HomeScreen
          HomeScreenState.activeState?.updateLocation("", 0.0, 0.0);
          await _getCurrentCoordinates();
        }
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

  void _showSlotPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        DateTime localDateTime = _selectedDateTime;

        // Calculate initial offsets
        // Date Item Width: 65 (width) + 12 (margin-right) = 77
        final double dateInitialOffset = (localDateTime.day - 1) * 77.0;

        final List<String> tempSlots = List.generate(16, (i) {
          int totalMinutes = i * 90;
          int h = totalMinutes ~/ 60;
          int m = totalMinutes % 60;
          return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
        });
        final String activeTimeStr = DateFormat('HH:mm').format(localDateTime);
        // Find closest index if not exact
        int timeIndex = 0;
        int minDiff = 10000;
        final currentMinutes = localDateTime.hour * 60 + localDateTime.minute;
        for (int i = 0; i < tempSlots.length; i++) {
          final parts = tempSlots[i].split(':');
          final slotMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          final diff = (currentMinutes - slotMinutes).abs();
          if (diff < minDiff) {
            minDiff = diff;
            timeIndex = i;
          }
        }

        // Calculate dynamic row height based on screen width
        final double screenWidth = MediaQuery.of(context).size.width;
        final double gridContentWidth =
            screenWidth - 40; // 20 horizontal padding
        final double cellWidth = (gridContentWidth - 30) / 4; // 10 spacing x 3
        final double cellHeight = cellWidth / 2.2; // childAspectRatio: 2.2
        final double rowHeight = cellHeight + 10; // mainAxisSpacing: 10

        final double timeInitialOffset = (timeIndex ~/ 4) * rowHeight;

        final ScrollController dateScrollController = ScrollController(
          initialScrollOffset: dateInitialOffset,
        );
        final ScrollController timeGridController = ScrollController(
          initialScrollOffset: timeInitialOffset,
        );

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Add a timer to refresh every minute for "real-time" disabling
            // We can use a StreamBuilder with a recurring stream for simplicity if we don't want to manage a Timer object manually in a local StatefulBuilder
            return StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                DateTime now = snapshot.data ?? DateTime.now();
                DateTime activeDate = DateTime(
                  localDateTime.year,
                  localDateTime.month,
                  localDateTime.day,
                );
                String activeTime = DateFormat('HH:mm').format(localDateTime);

                List<String> timeSlots = List.generate(16, (i) {
                  int totalMinutes = i * 90;
                  int h = totalMinutes ~/ 60;
                  int m = totalMinutes % 60;
                  return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
                });

                bool isTimeDisabled(String timeStr) {
                  DateTime slotTime = DateTime(
                    activeDate.year,
                    activeDate.month,
                    activeDate.day,
                    int.parse(timeStr.split(':')[0]),
                    int.parse(timeStr.split(':')[1]),
                  );
                  return slotTime.isBefore(
                    now.subtract(const Duration(minutes: 5)),
                  );
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Schedule",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ],
                          ),
                          // Real-time Clock in Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 14,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('hh:mm:ss a').format(now),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lufga',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(activeDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lufga',
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    // Subtract 1 month
                                    localDateTime = DateTime(
                                      localDateTime.year,
                                      localDateTime.month - 1,
                                      localDateTime.day,
                                      localDateTime.hour,
                                      localDateTime.minute,
                                    );
                                  });
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    // Add 1 month
                                    localDateTime = DateTime(
                                      localDateTime.year,
                                      localDateTime.month + 1,
                                      localDateTime.day,
                                      localDateTime.hour,
                                      localDateTime.minute,
                                    );
                                  });
                                },
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 85,
                        child: ListView.builder(
                          controller: dateScrollController,
                          scrollDirection: Axis.horizontal,
                          // Show all days in the month
                          itemCount: DateTime(
                            activeDate.year,
                            activeDate.month + 1,
                            0,
                          ).day,
                          itemBuilder: (context, index) {
                            // Start from 1st of the selected month
                            DateTime d = DateTime(
                              activeDate.year,
                              activeDate.month,
                              index + 1,
                            );

                            bool isBeforeToday = d.isBefore(
                              DateTime(now.year, now.month, now.day),
                            );
                            bool isSel =
                                d.year == activeDate.year &&
                                d.month == activeDate.month &&
                                d.day == activeDate.day;

                            return GestureDetector(
                              onTap: isBeforeToday
                                  ? null
                                  : () {
                                      setModalState(() {
                                        localDateTime = DateTime(
                                          d.year,
                                          d.month,
                                          d.day,
                                          localDateTime.hour,
                                          localDateTime.minute,
                                        );
                                      });
                                    },
                              child: Container(
                                width: 65,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Opacity(
                                  opacity: isBeforeToday ? 0.4 : 1.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(d),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontFamily: 'Lufga',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        d.day.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Lufga',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Time",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lufga',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          controller: timeGridController,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.2,
                              ),
                          itemCount: timeSlots.length,
                          itemBuilder: (context, index) {
                            String time = timeSlots[index];
                            bool disabled = isTimeDisabled(time);
                            bool isSel = activeTime == time;
                            return GestureDetector(
                              onTap: disabled
                                  ? null
                                  : () {
                                      setModalState(() {
                                        List<String> p = time.split(':');
                                        localDateTime = DateTime(
                                          activeDate.year,
                                          activeDate.month,
                                          activeDate.day,
                                          int.parse(p[0]),
                                          int.parse(p[1]),
                                        );
                                      });
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Colors.white
                                      : (disabled
                                            ? Colors.grey[100]
                                            : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.black
                                        : const Color(0xFFE0E0E0),
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _formatTo12h(time),
                                    style: TextStyle(
                                      color: disabled
                                          ? Colors.grey[400]
                                          : Colors.black,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontFamily: 'Lufga',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "${DateFormat('EEE, d MMM').format(activeDate)} | ${_formatTo12h(activeTime).replaceAll(':', '.')} - ${_formatTo12h(_getEndTime(activeTime)).replaceAll(':', '.')}",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lufga',
                            ),
                          ),
                        ),
                      ),
                      OneBtn(
                        onPressed: () {
                          setState(() {
                            _selectedDateTime = localDateTime;
                            _slotController.text =
                                "${DateFormat('MMM dd').format(_selectedDateTime)}, ${DateFormat('hh:mm a').format(_selectedDateTime)}";
                          });
                          Navigator.pop(context);
                        },
                        text: "Schedule",
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

  String _formatTo12h(String time24h) {
    try {
      final parts = time24h.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      final dt = DateTime(2022, 1, 1, h, m);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return time24h;
    }
  }

  String _getEndTime(String startTime) {
    try {
      List<String> parts = startTime.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      m += 90;
      if (m >= 60) {
        h += m ~/ 60;
        m = m % 60;
      }
      if (h >= 24) {
        h = h % 24;
      }
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VehcleBanner(
                        vehicleName: widget.vehicleName,
                        vehiclePlate: widget.vehiclePlate,
                        vehicleImage: widget.vehicleImage,
                      ),

                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () => Navigator.pop(context),
                      //       child: const Icon(Icons.arrow_back_ios, size: 20),
                      //     ),
                      //     const SizedBox(width: 10),
                      //     Text(
                      //       "$_selectedCategory Booking",
                      //       style: const TextStyle(
                      //         fontSize: 22,
                      //         fontWeight: FontWeight.w700,
                      //         fontFamily: 'Lufga',
                      //         color: Colors.black,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories Horizontal Scroll
                            BlocBuilder<IssueCategoryBloc, IssueCategoryState>(
                              builder: (context, state) {
                                if (state is IssueCategoryLoaded) {
                                  final categories = state.categories
                                      .where((c) => c.name != null)
                                      .toList();

                                  // Set initial category if not set
                                  if (_selectedCategoryObj == null &&
                                      categories.isNotEmpty) {
                                    final initialCat =
                                        widget.initialCategory != null
                                        ? categories.firstWhere(
                                            (c) =>
                                                c.name?.toLowerCase() ==
                                                widget.initialCategory!
                                                    .toLowerCase()
                                                    .replaceAll('\n', ' '),
                                            orElse: () => categories.first,
                                          )
                                        : categories.first;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          setState(() {
                                            _selectedCategoryObj = initialCat;
                                            _selectedCategory =
                                                initialCat.name ?? '';
                                            if (initialCat
                                                .subTypes
                                                .isNotEmpty) {
                                              _selectedChargeUnit =
                                                  initialCat.subTypes.first;
                                            }
                                          });
                                        });
                                  }
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 5),

                            const Text(
                              "Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lufga',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openLocationPicker,
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _currentAddress,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF757575),
                                                  fontFamily: 'Lufga',
                                                  height: 1.3,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedLocationType = value;
                                      });
                                    },
                                    color: Colors.white,
                                    offset: const Offset(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          _buildPopupMenuItem('Inside'),
                                          _buildPopupMenuItem('Outside'),
                                          _buildPopupMenuItem('Road'),
                                        ],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                          topLeft: Radius.zero,
                                          bottomLeft: Radius.zero,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedLocationType,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Lufga',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!(_selectedCategory.toLowerCase().contains(
                                  'charging',
                                ) &&
                                _selectedCategory.toLowerCase().contains(
                                  'station',
                                ))) ...[
                              BlocBuilder<TicketBloc, TicketState>(
                                builder: (context, state) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: state is TicketLoading
                                          ? null
                                          : () =>
                                                _submitTicket(isInstant: true),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.black,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      child: state is TicketLoading
                                          ? const CupertinoActivityIndicator()
                                          : const Text(
                                              "Instant Booking",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Lufga',
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_selectedCategoryObj != null &&
                                _selectedCategoryObj!.subTypes.isNotEmpty) ...[
                              Text(
                                _selectedCategoryObj?.id == 6
                                    ? "Quick Services"
                                    : "Select charge Unit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lufga',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent: 170,
                                    ),
                                padding: EdgeInsets.zero,
                                itemCount:
                                    _selectedCategoryObj!.subTypes.length,
                                itemBuilder: (context, index) {
                                  final subType =
                                      _selectedCategoryObj!.subTypes[index];
                                  final isSelected =
                                      _selectedChargeUnit?.id == subType.id;
                                  return _buildChargeUnitCard(
                                    subType,
                                    isSelected,
                                  );
                                },
                              ),
                              // Show description field for "Other" category even if it has subTypes
                              if (_selectedCategoryObj?.id == 6) ...[
                                const SizedBox(height: 16),
                                Text(
                                  "Describe your issue",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lufga',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _issueController,
                                    decoration: const InputDecoration(
                                      hintText: "Type your issue",
                                      hintStyle: TextStyle(
                                        color: Color(0xFFBDBDBD),
                                        fontFamily: 'Lufga',
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onChanged: (_) {
                                      setState(() {}); // Update border color
                                    },
                                  ),
                                ),
                              ],
                            ] else ...[
                              const Text(
                                "Describe your issue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: TextField(
                                  controller: _issueController,
                                  decoration: InputDecoration(
                                    hintText: "Type your issue",
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFBDBDBD),
                                      fontFamily: 'Lufga',
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (_selectedCategoryObj?.id == 6) {
                                      setState(() {}); // Update border color
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Upload your issue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _pickMedia,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: DashedBorderPainter(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF7F7F7),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.add_box_outlined,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Add photos or short video",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Lufga',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Click here to upload images or videos related to the issue",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9E9E9E),
                                              fontFamily: 'Lufga',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedFiles.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedFiles.length,
                                    itemBuilder: (context, index) {
                                      final file = _selectedFiles[index];
                                      final isVideo =
                                          file.path.toLowerCase().endsWith(
                                            '.mp4',
                                          ) ||
                                          file.path.toLowerCase().endsWith(
                                            '.mov',
                                          );
                                      return Container(
                                        width: 90,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: !isVideo
                                              ? DecorationImage(
                                                  image: FileImage(file),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: isVideo
                                              ? Colors.black87
                                              : Colors.grey[200],
                                        ),
                                        child: Stack(
                                          children: [
                                            if (isVideo)
                                              const Center(
                                                child: Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedFiles.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],

                            const SizedBox(height: 16),

                            const Text(
                              "Select Slot",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lufga',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: TextField(
                                controller: _slotController,
                                readOnly: true,
                                onTap: () {
                                  _showSlotPicker(context);
                                },
                                decoration: const InputDecoration(
                                  hintText: "Select Slot",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFBDBDBD),
                                    fontFamily: 'Lufga',
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildRedeemCodeSection(),
                            const SizedBox(height: 16),

                            // Payment Method Selection
                            const Text(
                              "Payment Method",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Lufga',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Payment Method Selection Content
                            ValueListenableBuilder<String>(
                              valueListenable: _selectedPaymentMethodNotifier,
                              builder: (context, selectedMethod, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pay By Company
                                    GestureDetector(
                                      onTap: () {
                                        _selectedPaymentMethodNotifier.value =
                                            "company";
                                        // Auto-focus the company code field after a short delay for the expansion animation
                                        Future.delayed(
                                          const Duration(milliseconds: 400),
                                          () {
                                            if (mounted) {
                                              FocusScope.of(
                                                context,
                                              ).nextFocus();
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Pay By Company",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Lufga',
                                                color: Colors.black,
                                              ),
                                            ),
                                            const Spacer(),
                                            // Radio Button
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      selectedMethod ==
                                                          "company"
                                                      ? Colors.black
                                                      : const Color(0xFFD0D0D0),
                                                  width: 2,
                                                ),
                                              ),
                                              child: selectedMethod == "company"
                                                  ? Center(
                                                      child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Animated Input Section
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: selectedMethod == "company"
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  BlocConsumer<
                                                    CompanyCodeBloc,
                                                    CompanyCodeState
                                                  >(
                                                    listener: (context, state) {
                                                      if (state
                                                          is CompanyCodeSuccess) {
                                                        _showToast(
                                                          state
                                                              .response
                                                              .message,
                                                        );
                                                      } else if (state
                                                          is CompanyCodeFailure) {
                                                        _showToast(
                                                          _formatErrorMessage(
                                                            state.error,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      final bool isApplied =
                                                          state
                                                              is CompanyCodeSuccess;
                                                      final bool isLoading =
                                                          state
                                                              is CompanyCodeLoading;
                                                      final bool canApply =
                                                          _companyCodeController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty;

                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          border: Border.all(
                                                            color: isApplied
                                                                ? Colors.green
                                                                : (state
                                                                          is CompanyCodeFailure
                                                                      ? Colors
                                                                            .red
                                                                      : const Color(
                                                                          0xFFE0E0E0,
                                                                        )),
                                                            width:
                                                                isApplied ||
                                                                    state
                                                                        is CompanyCodeFailure
                                                                ? 1.5
                                                                : 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextField(
                                                                controller:
                                                                    _companyCodeController,
                                                                autofocus:
                                                                    false,
                                                                enabled:
                                                                    !isApplied &&
                                                                    !isLoading,
                                                                onChanged:
                                                                    (value) =>
                                                                        setState(
                                                                          () {},
                                                                        ),
                                                                decoration: const InputDecoration(
                                                                  hintText:
                                                                      "Company Code / ID",
                                                                  hintStyle: TextStyle(
                                                                    color: Color(
                                                                      0xFFBDBDBD,
                                                                    ),
                                                                    fontFamily:
                                                                        'Lufga',
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            14,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (isApplied)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      right: 4,
                                                                    ),
                                                                child: TextButton(
                                                                  onPressed:
                                                                      isLoading
                                                                      ? null
                                                                      : () {
                                                                          context
                                                                              .read<
                                                                                CompanyCodeBloc
                                                                              >()
                                                                              .add(
                                                                                ResetCompanyCode(),
                                                                              );
                                                                          setState(
                                                                            () {
                                                                              _companyCodeController.clear();
                                                                            },
                                                                          );
                                                                        },
                                                                  child: const Text(
                                                                    "Remove",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontFamily:
                                                                          'Lufga',
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            else
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      right: 8,
                                                                    ),
                                                                child: SizedBox(
                                                                  height: 36,
                                                                  child: ElevatedButton(
                                                                    onPressed:
                                                                        !canApply ||
                                                                            isLoading
                                                                        ? null
                                                                        : () {
                                                                            FocusScope.of(
                                                                              context,
                                                                            ).unfocus();
                                                                            context
                                                                                .read<
                                                                                  CompanyCodeBloc
                                                                                >()
                                                                                .add(
                                                                                  ValidateCompanyCode(
                                                                                    _companyCodeController.text.trim(),
                                                                                  ),
                                                                                );
                                                                          },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black,
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      disabledBackgroundColor:
                                                                          Colors
                                                                              .grey[300],
                                                                      elevation:
                                                                          0,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        isLoading
                                                                        ? const SizedBox(
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            child: CupertinoActivityIndicator(
                                                                              color: Colors.white,
                                                                              radius: 8,
                                                                            ),
                                                                          )
                                                                        : const Text(
                                                                            "Apply",
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontFamily: 'Lufga',
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
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),

                                    const SizedBox(height: 12),

                                    // Pay Now
                                    GestureDetector(
                                      onTap: () {
                                        _selectedPaymentMethodNotifier.value =
                                            "online";
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Pay Now",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Lufga',
                                                color: Colors.black,
                                              ),
                                            ),
                                            const Spacer(),
                                            // Radio Button
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      selectedMethod == "online"
                                                      ? Colors.black
                                                      : const Color(0xFFD0D0D0),
                                                  width: 2,
                                                ),
                                              ),
                                              child: selectedMethod == "online"
                                                  ? Center(
                                                      child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            BlocListener<LocationBloc, LocationState>(
                              listener: (context, state) {
                                if (state is LocationsLoaded) {
                                  _validateCurrentLocation(state.locations);
                                }
                              },
                              child: BlocListener<TicketBloc, TicketState>(
                                listener: (context, state) {
                                  if (state is TicketSuccess) {
                                    final requiresPayment =
                                        state.response.data?.paymentRequired ==
                                            true &&
                                        state.response.data?.paymentUrl != null;

                                    if (requiresPayment) {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            PaymentBottomSheet(
                                              vehicleName: widget.vehicleName,
                                              vehiclePlate: widget.vehiclePlate,
                                              locationAddress: _currentAddress,
                                              locationCity: "",
                                              date:
                                                  state
                                                          .response
                                                          .data
                                                          ?.ticket
                                                          ?.bookingType ==
                                                      "instant"
                                                  ? "Today"
                                                  : DateFormat(
                                                      'MMM dd',
                                                    ).format(_selectedDateTime),
                                              time:
                                                  state
                                                          .response
                                                          .data
                                                          ?.ticket
                                                          ?.bookingType ==
                                                      "instant"
                                                  ? "Instant"
                                                  : DateFormat(
                                                      'hh:mm a',
                                                    ).format(_selectedDateTime),
                                              paymentBreakdown: state
                                                  .response
                                                  .data
                                                  ?.paymentBreakdown,
                                              paymentUrl: state
                                                  .response
                                                  .data
                                                  ?.paymentUrl,
                                              intentionId: state
                                                  .response
                                                  .data
                                                  ?.intentionId,
                                            ),
                                      );
                                    } else {
                                      final breakdown =
                                          state.response.data?.paymentBreakdown;
                                      final invoice =
                                          state.response.data?.ticket?.invoice;
                                      final totalAmount =
                                          breakdown?.totalAmount ??
                                          invoice?.totalAmount;
                                      final currency =
                                          breakdown?.currency ??
                                          invoice?.currency ??
                                          "AED";
                                      final String toastMsg =
                                          (totalAmount != null &&
                                              totalAmount > 0)
                                          ? "Ticket created successfully! Total Amount: ${totalAmount.toStringAsFixed(2)} $currency"
                                          : "Ticket created successfully!";

                                      HomeScreenState.activeState?.showToast(
                                        toastMsg,
                                      );
                                      HomeScreenState.activeState
                                          ?.startServiceFlow(
                                            ticket: state.response.data?.ticket,
                                          );
                                      Navigator.pop(context);
                                    }
                                  } else if (state is TicketError) {
                                    _showToast(
                                      _formatErrorMessage(state.message),
                                    );
                                  }
                                },
                                child: BlocBuilder<TicketBloc, TicketState>(
                                  builder: (context, ticketState) {
                                    return OneBtn(
                                      onPressed: ticketState is TicketLoading
                                          ? null
                                          : () async {
                                              _submitTicket(isInstant: false);
                                            },
                                      text: "Submit Service",
                                      isLoading: ticketState is TicketLoading,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    );

    print('📋 [SubmitTicket] bookingType: ${request.bookingType}');
    print('📋 [SubmitTicket] paymentMethod: ${request.paymentMethod}');
    print('📋 [SubmitTicket] redeemCode: ${request.redeemCode}');
    print('📋 [SubmitTicket] companyCode: ${request.companyCode}');
    print('📋 [SubmitTicket] companyCodeId: ${request.companyCodeId}');

    // Dispatch create ticket event
    if (mounted) {
      context.read<TicketBloc>().add(CreateTicketRequested(request));
    }
  }

  String _getQuickServiceIcon(String name) {
    if (name.toLowerCase().contains('unlock')) {
      return 'assets/icon/Unlock.png';
    } else if (name.toLowerCase().contains('replacement')) {
      return 'assets/icon/batteryreplacemnanet.png';
    } else if (name.toLowerCase().contains('booster')) {
      return 'assets/icon/batteryboost.png';
    }
    return '';
  }

  Widget _buildRedeemCodeSection() {
    return BlocConsumer<RedeemCodeBloc, RedeemCodeState>(
      listener: (context, state) {
        if (state is RedeemCodeSuccess) {
          setState(() {
            _appliedRedeemCode = _redeemCodeController.text.trim();
          });
          _showToast(state.response.message);
        } else if (state is RedeemCodeFailure) {
          _showToast(state.message);
        }
      },
      builder: (context, state) {
        final bool isApplied = state is RedeemCodeSuccess;
        final bool isLoading = state is RedeemCodeLoading;
        final bool canApply = _redeemCodeController.text.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apply Redeem Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lufga',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isApplied
                      ? Colors.green
                      : (state is RedeemCodeFailure
                            ? Colors.red
                            : const Color(0xFFE0E0E0)),
                  width: isApplied || state is RedeemCodeFailure ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _redeemCodeController,
                      enabled: !isApplied && !isLoading,
                      onChanged: (value) => setState(() {}),
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: "Enter code here",
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontFamily: 'Lufga',
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isApplied)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<RedeemCodeBloc>().add(
                                  ResetRedeemCode(),
                                );
                                setState(() {
                                  _redeemCodeController.clear();
                                  _appliedRedeemCode = null;
                                });
                              },
                        child: const Text(
                          "Remove",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: !canApply || isLoading
                              ? null
                              : () {
                                  // Close keyboard
                                  FocusScope.of(context).unfocus();
                                  context.read<RedeemCodeBloc>().add(
                                    ValidateRedeemCode(
                                      _redeemCodeController.text.trim(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Apply",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lufga',
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isApplied)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Code applied successfully!",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
            if (state is RedeemCodeFailure)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lufga',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChargeUnitCard(IssueSubType subType, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChargeUnit = subType;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subType.name ?? '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lufga',
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    subType.iconImageUrl != null &&
                        subType.iconImageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          subType.iconImageUrl!,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.power,
                                color: Colors.white,
                                size: 22,
                              ),
                        ),
                      )
                    : _getQuickServiceIcon(subType.name ?? '').isNotEmpty
                    ? Image.asset(
                        _getQuickServiceIcon(subType.name ?? ''),
                        width: 22,
                        height: 22,
                        color: Colors.white,
                      )
                    : const Icon(Icons.power, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehcleBanner extends StatelessWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String vehicleImage;
  const VehcleBanner({
    super.key,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.vehicleImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    vehicleName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Lufga',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    vehiclePlate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Center(
            child: Image.network(
              vehicleImage,
              fit: BoxFit.cover,
              height: 150,
              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 80),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double dashWidth = 8;
    final double dashSpace = 4;
    final double radius = 16;

    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
