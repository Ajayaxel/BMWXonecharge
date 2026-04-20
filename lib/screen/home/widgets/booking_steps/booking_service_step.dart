import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/models/issue_category_model.dart';

import '../../../../const/onebtn.dart';

class BookingServiceStep extends StatelessWidget {
  final String selectedCategory;
  final IssueCategory? selectedCategoryObj;
  final IssueSubType? selectedChargeUnit;
  final TextEditingController issueController;
  final List<File> selectedFiles;
  final VoidCallback onPickMedia;
  final Function(int) onRemoveFile;
  final Function(IssueSubType) onServiceSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BookingServiceStep({
    super.key,
    required this.selectedCategory,
    this.selectedCategoryObj,
    this.selectedChargeUnit,
    required this.issueController,
    required this.selectedFiles,
    required this.onPickMedia,
    required this.onRemoveFile,
    required this.onServiceSelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 360;

    // Dynamic sizing based on screen width
    final double horizontalPadding = 16.0;
    final double crossSpacing = isSmallDevice ? 20.0 : 30.0;
    final double mainExtent = screenWidth > 600
        ? 360
        : 340; // Increased to fit card (220) + gap (50) + text

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedCategoryObj != null &&
                    selectedCategoryObj!.subTypes.isNotEmpty) ...[
                  Text(
                    selectedCategoryObj?.id == 6
                        ? "Quick Services"
                        : "Select charge Unit",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    clipBehavior: Clip.none,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: crossSpacing,
                      mainAxisSpacing: 20,
                      mainAxisExtent: mainExtent,
                    ),
                    itemCount: selectedCategoryObj!.subTypes.length,
                    itemBuilder: (context, index) {
                      final subType = selectedCategoryObj!.subTypes[index];
                      return _buildChargeUnitCard(
                        subType,
                        selectedChargeUnit?.id == subType.id,
                      );
                    },
                  ),
                  if (selectedCategoryObj?.id == 6) ...[
                    const SizedBox(height: 16),
                    _buildIssueDescriptionField(),
                  ],
                ] else ...[
                  _buildIssueDescriptionField(),
                  const SizedBox(height: 16),
                  _buildIssueUploadField(),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: OneBtn(
                  onPressed: onBack,
                  text: "Back",
                  backgroundColor: Colors.grey.shade400,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OneBtn(onPressed: onNext, text: "Next Step"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildIssueDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Describe your issue",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lufga',
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
            controller: issueController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Type your issue",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload your issue",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lufga',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPickMedia,
          child: CustomPaint(
            painter: DashedBorderPainter(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_box_outlined),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add photos or short video",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
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
                      color: isVideo ? Colors.black87 : Colors.grey[200],
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
                            onTap: () => onRemoveFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
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
          ),
      ],
    );
  }

  Widget _buildChargeUnitCard(IssueSubType subType, bool isSelected) {
    return GestureDetector(
      onTap: () => onServiceSelected(subType),
      child: Center(
        child: Column(
          children: [
            // The Card Box
            SizedBox(
              width: 130,
              height: 220,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 130,
                    height: 220,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff6dd4d0)
                          : (subType.backgroundColor != null &&
                                  subType.backgroundColor!.isNotEmpty)
                              ? _parseColor(subType.backgroundColor!)
                              : const Color(0xFFEAEEF1),
                      borderRadius: BorderRadius.circular(18),
                      border: null,
                    ),
                  ),
                  // The exact image positioning from snippet
                  Positioned(
                    bottom: -50,
                    right: -20,
                    child: SizedBox(
                      height: 280,
                      width: 150,
                      child:
                          subType.iconImageUrl != null &&
                              subType.iconImageUrl!.isNotEmpty
                          ? Image.network(
                              subType.iconImageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.car_repair),
                            )
                          : Image.asset(
                              "assets/home/carcard.png",
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Price and kWh text
            Text(
              subType.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Lufga',
                color: isSelected ? const Color(0xFF00A3A3) : Colors.black,
              ),
            ),
            Text(
              "AED ${subType.serviceCost}",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lufga',
                color: isSelected
                    ? const Color(0xFF00A3A3).withOpacity(0.8)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
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

  Color _parseColor(String colorStr) {
    try {
      colorStr = colorStr.replaceAll("#", "");
      if (colorStr.length == 6) {
        colorStr = "FF$colorStr";
      }
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      return const Color(0xFFEAEEF1);
    }
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
