import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/utils/toast_utils.dart';

class CancellationBottomSheet extends StatefulWidget {
  final int ticketId;

  const CancellationBottomSheet({super.key, required this.ticketId});

  @override
  State<CancellationBottomSheet> createState() =>
      _CancellationBottomSheetState();
}

class _CancellationBottomSheetState extends State<CancellationBottomSheet> {
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _suggestedReasons = [
    "Changed my plans / no longer needed.",
    "Found an alternative.",
    "Price is too high.",
    "Wait time is too long.",
    "Wrong service selected.",
    "Other",
  ];
  String? _selectedReason;

  bool _isDummyLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitCancellation() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ToastUtils.showToast(context, "Please provide a reason", isError: true);
      return;
    }

    // Dynamic Dummy Flow: Simulate API processing
    setState(() {
      _isDummyLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isDummyLoading = false;
      });
      ToastUtils.showToast(context, "Booking cancelled successfully");
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cancel Booking",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Please tell us why you want to cancel your booking.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                      if (reason != "Other") {
                        _reasonController.text = reason;
                      } else {
                        _reasonController.clear();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      reason,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "Additional Comments",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lufga',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 4,
                cursorColor: Colors.black,
                style: const TextStyle(fontFamily: 'Lufga', fontSize: 14),
                decoration: InputDecoration(
                  hintText: "“Changed my plans / no longer needed.”",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Lufga',
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            OneBtn(
              text: _isDummyLoading ? "Processing..." : "Confirm Cancellation",
              onPressed: _isDummyLoading ? null : _submitCancellation,
            ),
          ],
        ),
      ),
    );
  }
}
