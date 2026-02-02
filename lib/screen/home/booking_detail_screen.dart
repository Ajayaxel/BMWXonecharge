import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const BookingDetailScreen({super.key, required this.ticket});

  // Inside BookingDetailScreen
  void _showSideToast(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top:
            MediaQuery.of(context).padding.top +
            60, // Adjust top padding as needed
        right: 16,
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
                maxWidth: MediaQuery.of(context).size.width * 0.7,
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
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError ? Colors.redAccent : Colors.greenAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Variable mappings based on Ticket model
    final invoice = ticket.invoice;
    final driverName = ticket.driver?.name ?? '-';
    // Use ticketId as Order ID
    final orderId = ticket.ticketId;

    // Service name with sub-type if available
    final serviceName = ticket.issueCategory?.name != null
        ? (ticket.issueCategorySubType?.name != null
              ? '${ticket.issueCategory!.name} (${ticket.issueCategorySubType!.name})'
              : ticket.issueCategory!.name!)
        : '-';

    final location = ticket.location ?? '-';

    String bookingTime = '-';
    // Show scheduled time for scheduled bookings, creation time for instant
    String? rawTime = ticket.bookingType == 'scheduled'
        ? ticket.scheduledAt
        : ticket.createdAt;

    if (rawTime != null && rawTime.isNotEmpty) {
      try {
        String dateStr = rawTime;
        // If string doesn't have timezone info, assume it's UTC from server
        if (!dateStr.contains('Z') && !dateStr.contains('+')) {
          dateStr = '${dateStr.replaceFirst(' ', 'T')}Z';
        }
        final dt = DateTime.parse(dateStr).toLocal();
        bookingTime = DateFormat('hh:mm a').format(dt);
      } catch (_) {
        bookingTime = rawTime;
      }
    }

    final subType = ticket.issueCategorySubType;
    final serviceCost = subType?.serviceCost ?? 0.0;
    final serviceCharge = subType?.serviceCharge ?? 0.0;
    final vat = subType?.vat ?? 0.0;
    final calculatedTotal = serviceCost + serviceCharge + vat;
    final currency = invoice?.currency ?? 'AED';

    // final totalAmount = invoice != null
    //     ? '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}'
    //     : '-';
    // final trnNumber = invoice?.invoiceNumber != null
    //     ? '#${invoice!.invoiceNumber}'
    //     : '-';

    final paymentMethod = ticket.paymentMethod ?? '-';
    String formattedPaymentMethod = '-';
    if (paymentMethod != '-' && paymentMethod.isNotEmpty) {
      formattedPaymentMethod =
          paymentMethod[0].toUpperCase() + paymentMethod.substring(1);
    }

    final paymentStatus = ticket.status != null
        ? ticket.status![0].toUpperCase() + ticket.status!.substring(1)
        : 'Pending';

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is InvoiceDownloadLoading) {
          _showSideToast(context, 'Downloading invoice...', isError: false);
        } else if (state is InvoiceDownloadSuccess) {
          _showSideToast(
            context,
            'Invoice downloaded successfully!',
            isError: false,
          );
          OpenFile.open(state.filePath);
        } else if (state is InvoiceDownloadError) {
          _showSideToast(context, 'Error: ${state.message}', isError: true);
        }
      },
      child: Scaffold(
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
          actions: [
            IconButton(
              icon: const Icon(
                Icons.file_download_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                context.read<TicketBloc>().add(
                  DownloadInvoiceRequested(ticket.id),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
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
              // _buildDetailRow('Model', '-'),
              // _buildDetailRow('Number', '-'),
              const SizedBox(height: 10),
              _buildSectionHeader('Details'),
              _buildDetailRow('Service', serviceName),
              _buildDetailRow('Booking Time', bookingTime),
              _buildDetailRow(
                'Booking Type',
                ticket.bookingType != null
                    ? ticket.bookingType![0].toUpperCase() +
                          ticket.bookingType!.substring(1)
                    : '-',
              ),
              _buildDetailRow('Location', location, isMultiLine: true),

              const SizedBox(height: 10),
              _buildSectionHeader('Payment Details'),
              _buildDetailRow(
                'Service Cost',
                '$currency ${serviceCost.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Service Charge',
                '$currency ${serviceCharge.toStringAsFixed(2)}',
              ),
              _buildDetailRow('VAT', '$currency ${vat.toStringAsFixed(2)}'),
              _buildDetailRow(
                'Total Amount',
                '$currency ${calculatedTotal.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Payment Method',
                formattedPaymentMethod,
                isMultiLine: true,
              ),
              // _buildDetailRow('Payment Status', paymentStatus),
              const SizedBox(height: 40),
            ],
          ),
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
