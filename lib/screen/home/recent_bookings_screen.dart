import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/screen/home/booking_detail_screen.dart';
import 'package:intl/intl.dart';

class RecentBookingsScreen extends StatefulWidget {
  const RecentBookingsScreen({super.key});

  @override
  State<RecentBookingsScreen> createState() => _RecentBookingsScreenState();
}

class _RecentBookingsScreenState extends State<RecentBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(const FetchTicketsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
          'Recent Bookings',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        buildWhen: (previous, current) =>
            current is TicketListLoading ||
            current is TicketListLoaded ||
            current is TicketError,
        builder: (context, state) {
          if (state is TicketListLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is TicketListLoaded) {
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return const Center(
                child: Text(
                  'No bookings found',
                  style: TextStyle(fontFamily: 'Lufga', fontSize: 16),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _buildBookingCard(context, ticket);
              },
            );
          }

          if (state is TicketError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Ticket ticket) {
    final bookingId = ticket.ticketId;
    // Show scheduled time for scheduled bookings, creation time for instant
    String? rawTime = ticket.bookingType == 'scheduled'
        ? ticket.scheduledAt
        : ticket.createdAt;

    String dateTimeText = '';
    if (rawTime != null && rawTime.isNotEmpty) {
      try {
        String dateStr = rawTime;
        if (!dateStr.contains('Z') && !dateStr.contains('+')) {
          dateStr = '${dateStr.replaceFirst(' ', 'T')}Z';
        }
        final dt = DateTime.parse(dateStr).toLocal();
        dateTimeText = DateFormat('dd-MM-yyyy   hh:mm a').format(dt);
      } catch (_) {
        dateTimeText = rawTime;
      }
    }

    final serviceName = ticket.issueCategory?.name ?? 'Service';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking ID: $bookingId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Lufga',
                  color: Colors.grey,
                ),
              ),
              Container(), // Filler
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "$dateTimeText   •   ${ticket.bookingType != null ? (ticket.bookingType![0].toUpperCase() + ticket.bookingType!.substring(1)) : '-'}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            serviceName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailScreen(ticket: ticket),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Lufga',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
