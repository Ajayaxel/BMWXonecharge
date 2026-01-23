import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/data/repositories/issue_repository.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceSummaryBottomSheet extends StatefulWidget {
  final int? ticketId;

  const ServiceSummaryBottomSheet({
    super.key,
    this.ticketId,
  });

  @override
  State<ServiceSummaryBottomSheet> createState() =>
      _ServiceSummaryBottomSheetState();
}

class _ServiceSummaryBottomSheetState
    extends State<ServiceSummaryBottomSheet> {
  Ticket? _ticket;
  bool _isLoading = true;
  String? _error;
  double? _distance;
  String? _estimatedTime;

  @override
  void initState() {
    super.initState();
    if (widget.ticketId != null) {
      _fetchTicketDetails();
    } else {
      // In initState, widget is not yet mounted, but setState is safe here
      // since it's called synchronously during initialization
      setState(() {
        _isLoading = false;
        _error = 'No ticket ID provided';
      });
    }
  }

  Future<void> _fetchTicketDetails() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = context.read<IssueRepository>();
      final response = await repository.getTicketDetails(widget.ticketId!);

      if (!mounted) return;
      
      if (response.success && response.data?.ticket != null) {
        setState(() {
          _ticket = response.data!.ticket;
          _isLoading = false;
        });
        // Calculate distance after ticket is loaded
        _calculateDistanceAndTime();
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load ticket details';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateDistanceAndTime() async {
    if (_ticket?.latitude == null || _ticket?.longitude == null) {
      return;
    }

    try {
      final currentPosition = await Geolocator.getCurrentPosition();
      
      if (!mounted) return;
      
      final ticketLat = double.tryParse(_ticket!.latitude ?? '');
      final ticketLng = double.tryParse(_ticket!.longitude ?? '');

      if (ticketLat != null && ticketLng != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          ticketLat,
          ticketLng,
        );

        final distanceInKm = distanceInMeters / 1000;
        // Estimate time: assume average speed of 50 km/h
        final estimatedHours = distanceInKm / 50;
        final estimatedMinutes = (estimatedHours * 60).round();

        if (!mounted) return;
        setState(() {
          _distance = distanceInKm;
          _estimatedTime = estimatedMinutes >= 60
              ? '${(estimatedMinutes / 60).round()} Hour${(estimatedMinutes / 60).round() > 1 ? 's' : ''}'
              : '$estimatedMinutes min';
        });
      }
    } catch (e) {
      // If location calculation fails, use defaults
      if (!mounted) return;
      setState(() {
        _distance = null;
        _estimatedTime = null;
      });
    }
  }

  String _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return '';
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('battery')) {
      return 'assets/issue/lowbattery.png';
    }
    if (lowerName.contains('tire') || lowerName.contains('tyre')) {
      return 'assets/issue/roentgen_tyre.png';
    }
    if (lowerName.contains('mechanical')) {
      return 'assets/issue/mdi_mechanic.png';
    }
    if (lowerName.contains('station') || lowerName.contains('charge')) {
      return 'assets/issue/Battery.png';
    }
    if (lowerName.contains('tow') || lowerName.contains('pickup')) {
      return 'assets/issue/truck-pickup.png';
    }
    return '';
  }

  IconData _getCategoryDefaultIcon(String? categoryName) {
    if (categoryName == null) return Icons.build;
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('battery')) {
      return Icons.battery_charging_full;
    }
    if (lowerName.contains('tire') || lowerName.contains('tyre')) {
      return Icons.tire_repair;
    }
    if (lowerName.contains('mechanical')) {
      return Icons.build;
    }
    if (lowerName.contains('station') || lowerName.contains('charge')) {
      return Icons.ev_station;
    }
    if (lowerName.contains('tow') || lowerName.contains('pickup')) {
      return Icons.local_shipping;
    }
    return Icons.build;
  }

  String _formatCurrency(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lufga',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTicketDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lufga',
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "HELP",
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lufga',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Distance & Time
                      if (_distance != null || _estimatedTime != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _distance != null
                                  ? "${_distance!.toStringAsFixed(0)} km"
                                  : "N/A",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Lufga',
                              ),
                            ),
                            if (_estimatedTime != null) ...[
                              const SizedBox(width: 24),
                              const Icon(Icons.access_time,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                _estimatedTime!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (_distance != null || _estimatedTime != null)
                        const Divider(
                            height: 32, thickness: 1, color: Color(0xFFF0F0F0)),

                      // Car Model
                      if (_ticket?.issueCategorySubType != null)
                        Row(
                          children: [
                            Image.asset(
                              'assets/home/car_icon_black.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.directions_car),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Service Type",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lufga',
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                Text(
                                  _ticket!.issueCategorySubType!.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Lufga',
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (_ticket?.issueCategorySubType != null)
                        const SizedBox(height: 20),

                      // Landmark
                      if (_ticket?.location != null)
                        Row(
                          children: [
                            const Icon(Icons.location_pin,
                                size: 24, color: Colors.black),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Landmark",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Lufga',
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  Text(
                                    _ticket!.location!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Lufga',
                                      color: Color(0xFF757575),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (_ticket?.location != null) const SizedBox(height: 24),

                      // Added Services Section
                      if (_ticket?.issueCategory != null) ...[
                        const Text(
                          "Added Services",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Service Card
                        _buildServiceCard(
                          title: _ticket!.issueCategory!.name,
                          price: _ticket!.issueCategorySubType != null
                              ? _formatCurrency(
                                  _ticket!.issueCategorySubType!.serviceCost,
                                  _ticket!.invoice?.currency ?? 'AED',
                                )
                              : "AED 0.00",
                          iconPath: _getCategoryIcon(_ticket!.issueCategory!.name),
                          items: _ticket!.issueCategorySubType != null
                              ? [_ticket!.issueCategorySubType!.name]
                              : [],
                          defaultIcon:
                              _getCategoryDefaultIcon(_ticket!.issueCategory!.name),
                        ),

                        const SizedBox(height: 24),
                      ],

                      // Pricing Table (Invoice Section)
                      if (_ticket?.invoice != null) ...[
                        _buildPriceRow(
                          "Service Cost",
                          _formatCurrency(
                            _ticket!.invoice!.subtotal,
                            _ticket!.invoice!.currency,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_ticket!.invoice!.vatAmount > 0) ...[
                          _buildPriceRow(
                            "Vat",
                            _formatCurrency(
                              _ticket!.invoice!.vatAmount,
                              _ticket!.invoice!.currency,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_ticket!.invoice!.discountAmount > 0) ...[
                          _buildPriceRow(
                            "Discount",
                            "-${_formatCurrency(
                              _ticket!.invoice!.discountAmount,
                              _ticket!.invoice!.currency,
                            )}",
                          ),
                          const SizedBox(height: 12),
                        ],
                        _buildPriceRow(
                          "Total price",
                          _formatCurrency(
                            _ticket!.invoice!.totalAmount,
                            _ticket!.invoice!.currency,
                          ),
                          isTotal: true,
                        ),
                      ] else if (_ticket?.issueCategorySubType != null) ...[
                        // Fallback to sub-type costs if invoice is not available
                        _buildPriceRow(
                          "Service Cost",
                          _formatCurrency(
                            _ticket!.issueCategorySubType!.serviceCost,
                            'AED',
                          ),
                        ),
                        if (_ticket!.issueCategorySubType!.serviceCharge > 0) ...[
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            "Service Charge",
                            _formatCurrency(
                              _ticket!.issueCategorySubType!.serviceCharge,
                              'AED',
                            ),
                          ),
                        ],
                        if (_ticket!.issueCategorySubType!.vat > 0) ...[
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            "Vat",
                            _formatCurrency(
                              _ticket!.issueCategorySubType!.vat,
                              'AED',
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildPriceRow(
                          "Total price",
                          _formatCurrency(
                            _ticket!.issueCategorySubType!.serviceCost +
                                _ticket!.issueCategorySubType!.serviceCharge +
                                _ticket!.issueCategorySubType!.vat,
                            'AED',
                          ),
                          isTotal: true,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Done Button
                      OneBtn(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: "Done",
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String price,
    required String iconPath,
    required List<String> items,
    required IconData defaultIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    height: 24,
                    width: 24,
                    errorBuilder: (c, e, s) => Icon(defaultIcon, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lufga',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lufga',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 36, top: 2),
                    child: Row(
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(color: Color(0xFF4A4D54)),
                        ),
                        Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lufga',
                            color: Color(0xFF4A4D54),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w600,
            fontFamily: 'Lufga',
            color: isTotal ? Colors.black : const Color(0xFF4A4D54),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w600,
            fontFamily: 'Lufga',
            color: isTotal ? Colors.black : const Color(0xFF4A4D54),
          ),
        ),
      ],
    );
  }
}
