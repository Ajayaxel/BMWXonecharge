import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/screen/home/select_payment_bottom_sheet.dart';
import 'package:onecharge/models/ticket_model.dart';

class PaymentBottomSheet extends StatelessWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String locationAddress;
  final String locationCity;
  final String date;
  final String time;
  final PaymentBreakdown? paymentBreakdown;
  final String? paymentUrl;
  final String? intentionId;

  const PaymentBottomSheet({
    super.key,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.locationAddress,
    required this.locationCity,
    required this.date,
    required this.time,
    this.paymentBreakdown,
    this.paymentUrl,
    this.intentionId,
  });

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
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Payment",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lufga',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Vehicle Info
          Text(
            vehicleName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          Text(
            vehiclePlate,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lufga',
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Address Info
          Text(
            locationAddress,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lufga',
              color: Color(0xFF424242),
            ),
          ),
          Text(
            locationCity,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lufga',
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Date & Time Info
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF757575)),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 32),

          // Price Breakdown
          if (paymentBreakdown != null) ...[
            _buildPriceRow(
              "Service Cost",
              "${paymentBreakdown!.baseAmount.toStringAsFixed(2)} ${paymentBreakdown!.currency}",
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              "Vat",
              "${paymentBreakdown!.vatAmount.toStringAsFixed(2)} ${paymentBreakdown!.currency}",
            ),
            if (paymentBreakdown!.discountApplied) ...[
              const SizedBox(height: 12),
              _buildPriceRow(
                "Discount",
                "-${paymentBreakdown!.discountAmount.toStringAsFixed(2)} ${paymentBreakdown!.currency}",
              ),
            ],
            const SizedBox(height: 16),
            _buildPriceRow(
              "Total price",
              "${paymentBreakdown!.totalAmount.toStringAsFixed(2)} ${paymentBreakdown!.currency}",
              isTotal: true,
            ),
          ] else ...[
            _buildPriceRow("Service Cost", "AED 2441"),
            const SizedBox(height: 12),
            _buildPriceRow("Service Charge", "AED 73.23"),
            const SizedBox(height: 12),
            _buildPriceRow("Vat", "AED 122.05"),
            const SizedBox(height: 16),
            _buildPriceRow("Total price", "AED 2,636.73", isTotal: true),
          ],
          const SizedBox(height: 32),

          OneBtn(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SelectPaymentBottomSheet(
                  paymentBreakdown: paymentBreakdown,
                  paymentUrl: paymentUrl,
                  intentionId: intentionId,
                ),
              );
            },
            text: "Make Payment",
          ),
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
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Lufga',
            color: isTotal ? Colors.black : const Color(0xFF616161),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'Lufga',
            color: isTotal ? Colors.black : const Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
