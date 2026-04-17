import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../const/onebtn.dart';

class BookingSlotStep extends StatefulWidget {
  final DateTime selectedDateTime;
  final bool isSlotSelected;
  final Function(DateTime) onDateTimeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BookingSlotStep({
    super.key,
    required this.selectedDateTime,
    required this.isSlotSelected,
    required this.onDateTimeChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BookingSlotStep> createState() => _BookingSlotStepState();
}

class _BookingSlotStepState extends State<BookingSlotStep> {
  String _selectedPeriod = "Morning";
  late DateTime _localDateTime;

  @override
  void initState() {
    super.initState();
    _localDateTime = widget.selectedDateTime;
    _updatePeriodFromTime();
  }

  void _updatePeriodFromTime() {
    int hour = _localDateTime.hour;
    if (hour >= 6 && hour < 12) {
      _selectedPeriod = "Morning";
    } else if (hour >= 12 && hour < 18) {
      _selectedPeriod = "Afternoon";
    } else {
      _selectedPeriod = "Night";
    }
  }

  List<String> _getTimeSlots() {
    // Generate slots with 1.5h gap (90 mins)
    return List.generate(16, (i) {
      int totalMinutes = i * 90;
      int h = totalMinutes ~/ 60;
      int m = totalMinutes % 60;
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    });
  }

  List<String> _getFilteredSlots() {
    List<String> allSlots = _getTimeSlots();
    if (_selectedPeriod == "Morning") {
      return allSlots.where((s) {
        int h = int.parse(s.split(':')[0]);
        return h >= 6 && h < 12;
      }).toList();
    } else if (_selectedPeriod == "Afternoon") {
      return allSlots.where((s) {
        int h = int.parse(s.split(':')[0]);
        return h >= 12 && h < 18;
      }).toList();
    } else {
      // Reorder Night slots: 6 PM - 12 AM (18, 19:30, 21, 22:30) 
      // followed by 12 AM - 6 AM (00, 01:30, 03, 04:30)
      List<String> evening = allSlots.where((s) {
        int h = int.parse(s.split(':')[0]);
        return h >= 18;
      }).toList();
      List<String> earlyMorning = allSlots.where((s) {
        int h = int.parse(s.split(':')[0]);
        return h >= 0 && h < 6;
      }).toList();
      return [...evening, ...earlyMorning];
    }
  }

  String _formatTo12h(String time24h) {
    try {
      final parts = time24h.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2024, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return time24h;
    }
  }

  String _getEndTime(String startTime24h) {
    try {
      final parts = startTime24h.split(':');
      int h = int.parse(parts[0]);
      int m = int.parse(parts[1]);
      int total = h * 60 + m + 90; // 1.5 hour gap
      int endH = (total ~/ 60) % 24;
      int endM = total % 60;
      final dt = DateTime(2024, 1, 1, endH, endM);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<DateTime>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();

              bool isTimeDisabled(String timeStr) {
                DateTime activeDate = DateTime(
                  _localDateTime.year,
                  _localDateTime.month,
                  _localDateTime.day,
                );
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14, // Next 14 days
                      itemBuilder: (context, index) {
                        DateTime date = DateTime.now().add(
                          Duration(days: index),
                        );
                        bool isSelected = date.year == _localDateTime.year &&
                            date.month == _localDateTime.month &&
                            date.day == _localDateTime.day;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _localDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _localDateTime.hour,
                                _localDateTime.minute,
                              );
                              widget.onDateTimeChanged(_localDateTime);
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('E').format(date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Pick a Slot",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lufga',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Period Filters
                  Row(
                    children: [
                      _buildPeriodFilter("Morning", Icons.wb_cloudy_outlined),
                      const SizedBox(width: 8),
                      _buildPeriodFilter("Afternoon", Icons.wb_sunny_outlined),
                      const SizedBox(width: 8),
                      _buildPeriodFilter(
                        "Night",
                        Icons.nightlight_round_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Time Slots
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: _getFilteredSlots().length,
                      itemBuilder: (context, index) {
                        String time = _getFilteredSlots()[index];
                        final parts = time.split(':');
                        final hour = int.parse(parts[0]);
                        final minute = int.parse(parts[1]);

                        bool isSelected = widget.isSlotSelected &&
                            _localDateTime.hour == hour &&
                            _localDateTime.minute == minute;
                        bool disabled = isTimeDisabled(time);

                        return GestureDetector(
                          onTap: disabled
                              ? null
                              : () {
                                  setState(() {
                                    _localDateTime = DateTime(
                                      _localDateTime.year,
                                      _localDateTime.month,
                                      _localDateTime.day,
                                      hour,
                                      minute,
                                    );
                                    widget.onDateTimeChanged(_localDateTime);
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[200]!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "${_formatTo12h(time).replaceAll(' AM', '').replaceAll(' PM', '')} - ${_getEndTime(time)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (disabled
                                              ? Colors.grey[400]
                                              : Colors.black),
                                    ),
                                  ),
                                  if (disabled)
                                    Text(
                                      "Not Available",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade300,
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
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: OneBtn(
                onPressed: widget.onBack,
                text: "Back",
                backgroundColor: Colors.grey.shade200,
                textColor: Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OneBtn(onPressed: widget.onNext, text: "Next Step"),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget _buildPeriodFilter(String period, IconData icon) {
    bool isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey[200]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
