import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:io';
import 'package:onecharge/const/onebtn.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onecharge/screen/home/payment_bottom_sheet.dart';
import 'package:onecharge/screen/home/location_map_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/models/issue_category_model.dart';

class IssueReportingBottomSheet extends StatefulWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String currentAddress;
  final String? initialCategory;
  const IssueReportingBottomSheet({
    super.key,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.currentAddress,
    this.initialCategory,
  });

  @override
  State<IssueReportingBottomSheet> createState() =>
      _IssueReportingBottomSheetState();
}

class _IssueReportingBottomSheetState extends State<IssueReportingBottomSheet> {
  String _selectedCategory = "Low Battery";
  IssueCategory? _selectedCategoryObj;
  String _currentAddress = "";
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _slotController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedFiles = [];
  OverlayEntry? _toastEntry;
  IssueSubType? _selectedChargeUnit;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!.replaceAll('\n', ' ');
    }
    DateTime now = DateTime.now();
    int minutes = now.minute;
    if (minutes <= 30) {
      _selectedDateTime = DateTime(now.year, now.month, now.day, now.hour, 30);
    } else {
      _selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 1,
        00,
      );
    }
    _currentAddress = widget.currentAddress;
    _slotController.text =
        "${DateFormat('MMM dd').format(_selectedDateTime)}, ${DateFormat('hh:mm a').format(_selectedDateTime)}";
  }

  @override
  void dispose() {
    _issueController.dispose();
    _slotController.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  void _showToast(String message) {
    _toastEntry?.remove();
    _toastEntry = null;

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
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
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
    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (_toastEntry == entry) {
        _toastEntry?.remove();
        _toastEntry = null;
      }
    });
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

  String _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('station') || lowerName.contains('charge')) {
      return 'assets/issue/Battery.png';
    }
    if (lowerName.contains('battery')) return 'assets/issue/lowbattery.png';
    if (lowerName.contains('mechanical') || lowerName.contains('engine')) {
      return 'assets/issue/mdi_mechanic.png';
    }
    if (lowerName.contains('tire') || lowerName.contains('tyre')) {
      return 'assets/issue/roentgen_tyre.png';
    }
    if (lowerName.contains('tow') || lowerName.contains('pickup')) {
      return 'assets/issue/truck-pickup.png';
    }
    return 'assets/issue/lowbattery.png'; // default
  }

  String _formatCategoryName(String name) {
    // Handle special cases for better formatting
    if (name.toLowerCase().contains('tow') && name.toLowerCase().contains('pickup')) {
      return 'Tow / Pickup\nRequired';
    }
    if (name.toLowerCase().contains('charging') && name.toLowerCase().contains('station')) {
      return 'Charging\nStation';
    }
    if (name.toLowerCase().contains('low') && name.toLowerCase().contains('battery')) {
      return 'Low\nBattery';
    }
    if (name.toLowerCase().contains('mechanical')) {
      return 'Mechanical\nIssue';
    }
    if (name.toLowerCase().contains('flat') && name.toLowerCase().contains('tyre')) {
      return 'Flat\nTyre';
    }
    // For other names, try to split at reasonable points
    if (name.contains(' ')) {
      final parts = name.split(' ');
      if (parts.length == 2) {
        return '${parts[0]}\n${parts[1]}';
      } else if (parts.length > 2) {
        // Split at the middle point
        final mid = parts.length ~/ 2;
        return '${parts.sublist(0, mid).join(' ')}\n${parts.sublist(mid).join(' ')}';
      }
    }
    return name;
  }

  void _showSlotPicker(BuildContext context) {
    _showDatePicker(context);
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        DateTime tempDate = _selectedDateTime;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateTime = DateTime(
                                tempDate.year,
                                tempDate.month,
                                tempDate.day,
                                _selectedDateTime.hour,
                                _selectedDateTime.minute,
                              );
                            });
                            Navigator.pop(context);
                            _showTimePicker(context);
                          },
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lufga',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedDateTime,
                      minimumDate: DateTime.now().subtract(
                        const Duration(minutes: 1),
                      ),
                      onDateTimeChanged: (DateTime newDate) {
                        tempDate = newDate;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        DateTime tempTime = _selectedDateTime;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showDatePicker(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final now = DateTime.now();
                            final selected = DateTime(
                              _selectedDateTime.year,
                              _selectedDateTime.month,
                              _selectedDateTime.day,
                              tempTime.hour,
                              tempTime.minute,
                            );

                            if (selected.isBefore(now)) {
                              _showToast("Please select a future time");
                              return;
                            }

                            setState(() {
                              _selectedDateTime = selected;
                              _slotController.text =
                                  "${DateFormat('MMM dd').format(_selectedDateTime)}, ${DateFormat('hh:mm a').format(_selectedDateTime)}";
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lufga',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      minuteInterval: 30,
                      initialDateTime: _selectedDateTime,
                      onDateTimeChanged: (DateTime newTime) {
                        tempTime = newTime;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag Handle
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Issue Reporting",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Categories Horizontal Scroll
                    BlocBuilder<IssueCategoryBloc, IssueCategoryState>(
                      builder: (context, state) {
                        if (state is IssueCategoryLoading) {
                          return const SizedBox(
                            height: 141,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (state is IssueCategoryError) {
                          return SizedBox(
                            height: 141,
                            child: Center(
                              child: Text(
                                'Error: ${state.message}',
                                style: const TextStyle(
                                  fontFamily: 'Lufga',
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        } else if (state is IssueCategoryLoaded) {
                          final categories = state.categories
                              .where((c) => c.name != null)
                              .toList();

                          // Set initial category if not set
                          if (_selectedCategoryObj == null && categories.isNotEmpty) {
                            final initialCat = widget.initialCategory != null
                                ? categories.firstWhere(
                                    (c) => c.name?.toLowerCase() ==
                                        widget.initialCategory!
                                            .toLowerCase()
                                            .replaceAll('\n', ' '),
                                    orElse: () => categories.first,
                                  )
                                : categories.first;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _selectedCategoryObj = initialCat;
                                _selectedCategory = initialCat.name ?? '';
                                if (initialCat.subTypes.isNotEmpty) {
                                  _selectedChargeUnit = initialCat.subTypes.first;
                                }
                              });
                            });
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((cat) {
                                final categoryName = cat.name ?? '';
                                final isSelected = _selectedCategory == categoryName;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                      _selectedCategoryObj = cat;
                                      if (cat.subTypes.isNotEmpty) {
                                        _selectedChargeUnit = cat.subTypes.first;
                                      } else {
                                        _selectedChargeUnit = null;
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 164,
                                    height: 141,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.black
                                          : const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _formatCategoryName(categoryName),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Lufga',
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                _getCategoryIcon(categoryName),
                                                width: 24,
                                                height: 24,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return const SizedBox(height: 141);
                      },
                    ),
                    const SizedBox(height: 16),

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final updatedAddress =
                                  await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LocationMapScreen(
                                        initialAddress: _currentAddress,
                                      ),
                                    ),
                                  );
                              if (updatedAddress != null) {
                                setState(() {
                                  _currentAddress = updatedAddress;
                                });
                              }
                            },
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          // Close the Issue Reporting sheet first
                          Navigator.pop(context);

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PaymentBottomSheet(
                              vehicleName: widget.vehicleName,
                              vehiclePlate: widget.vehiclePlate,
                              locationAddress: _currentAddress,
                              locationCity: "",
                              date: "Today",
                              time: "Instant",
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Instant Booking",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedCategoryObj != null &&
                        _selectedCategoryObj!.subTypes.isNotEmpty) ...[
                      const Text(
                        "Select charge Unit",
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
                              mainAxisExtent: 140,
                            ),
                        padding: EdgeInsets.zero,
                        itemCount: _selectedCategoryObj!.subTypes.length,
                        itemBuilder: (context, index) {
                          final subType = _selectedCategoryObj!.subTypes[index];
                          final isSelected = _selectedChargeUnit?.id == subType.id;
                          return _buildChargeUnitCard(subType, isSelected);
                        },
                      ),
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
                          border: Border.all(color: const Color(0xFFE0E0E0)),
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
                                      borderRadius: BorderRadius.circular(12),
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
                                  file.path.toLowerCase().endsWith('.mp4') ||
                                  file.path.toLowerCase().endsWith('.mov');
                              return Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
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
                                            _selectedFiles.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
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
                        border: Border.all(color: const Color(0xFFE0E0E0)),
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
                    const SizedBox(height: 32),

                    OneBtn(
                      onPressed: () {
                        if (_slotController.text.isEmpty) {
                          _showToast("Please select a Slot");
                          return;
                        }

                        // Close the Issue Reporting sheet first
                        Navigator.pop(context);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PaymentBottomSheet(
                            vehicleName: widget.vehicleName,
                            vehiclePlate: widget.vehiclePlate,
                            locationAddress: _currentAddress,
                            locationCity: "",
                            date: "Today", // Placeholder
                            time: _slotController.text,
                          ),
                        );
                      },
                      text: "Submit Service",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lufga',
                color: Colors.black,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.power, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
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
