import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/screen/home/booking_detail_screen.dart';

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
        builder: (context, state) {
          if (state is TicketListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TicketListLoaded) {
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return const Center(
                child: Text(
                  'No bookings found',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
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
    final createdAt = ticket.createdAt;
    String dateTimeText = '';
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        final date =
            '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
        final time =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        dateTimeText = '$date   $time';
      } catch (_) {
        dateTimeText = createdAt;
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
            dateTimeText,
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
