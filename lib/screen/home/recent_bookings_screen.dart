import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/booking_detail_screen.dart';

class RecentBookingsScreen extends StatelessWidget {
  const RecentBookingsScreen({super.key});

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildBookingCard(context);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context) {
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
              const Text(
                'Booking ID: 555455',
                style: TextStyle(
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
          const Text(
            '11-09-2024   20:10',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Low Battery',
            style: TextStyle(
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
                    builder: (context) => const BookingDetailScreen(),
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
