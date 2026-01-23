import 'package:flutter/material.dart';
import 'package:onecharge/models/ticket_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const BookingDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final invoice = ticket.invoice;
    final driverName = ticket.driver?.name ?? '-';
    final orderId = ticket.ticketId;
    final serviceName = ticket.issueCategory?.name ?? '-';
    final location = ticket.location ?? '-';

    String bookingTime = '-';
    if (ticket.createdAt != null && ticket.createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(ticket.createdAt!);
        bookingTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        bookingTime = ticket.createdAt!;
      }
    }

    final totalAmount = invoice != null
        ? '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}'
        : '-';
    final trnNumber = invoice?.invoiceNumber != null
        ? '#${invoice!.invoiceNumber}'
        : '-';
    final paymentMethod = ticket.paymentMethod ?? '-';
    final paymentStatus = (ticket.status ?? 'Pending');

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
            _buildDetailRow('Agent Name', driverName),
            _buildDetailRow('Order ID', orderId),
            _buildDetailRow('Model', '-'),
            _buildDetailRow('Number', '-'),
            const SizedBox(height: 10),
            _buildSectionHeader('Details'),
            _buildDetailRow('Service', serviceName),
            _buildDetailRow('Booking Time', bookingTime),
            _buildDetailRow(
              'Location',
              location,
              isMultiLine: true,
            ),
            _buildDetailRow('Number', '-'),
            const SizedBox(height: 10),
            _buildSectionHeader('Payment Details'),
            _buildDetailRow('Total Amount', totalAmount),
            _buildDetailRow('TRN Number', trnNumber),
            _buildDetailRow(
              'Payment Method',
              paymentMethod,
              isMultiLine: true,
            ),
            _buildDetailRow('Payment Status', paymentStatus),
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
