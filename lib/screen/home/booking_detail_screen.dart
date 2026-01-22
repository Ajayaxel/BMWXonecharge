import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Page',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Details'),
            _buildDetailRow('Agent Name', 'Muhammed'),
            _buildDetailRow('Order ID', '555455'),
            _buildDetailRow('Model', 'BMW i7'),
            _buildDetailRow('Number', '532212'),
            const SizedBox(height: 10),
            _buildSectionHeader('Details'),
            _buildDetailRow('Service', 'Low Battery'),
            _buildDetailRow('Booking Time', '20:10'),
            _buildDetailRow(
              'Location',
              '1901 Thornridge\nCir. Shiloh, Hawaii 81063',
              isMultiLine: true,
            ),
            _buildDetailRow('Number', '532212'),
            const SizedBox(height: 10),
            _buildSectionHeader('Payment Details'),
            _buildDetailRow('Total Amount', 'AED 7500.00'),
            _buildDetailRow('TRN Number', '#95249'),
            _buildDetailRow(
              'Payment Method',
              'Bank Transfer\nRef#000000, TT Ref#\n00000000',
              isMultiLine: true,
            ),
            _buildDetailRow('Payment Status', 'Paid'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF7F7F7),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lufga',
          color: Color(0xFF4A4D54),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Color(0xFF4A4D54),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Color(0xFF23262F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
