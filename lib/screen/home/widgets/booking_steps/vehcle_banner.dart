import 'package:flutter/material.dart';

class VehcleBanner extends StatelessWidget {
  final String vehicleName;
  final String vehiclePlate;
  final String vehicleImage;
  const VehcleBanner({
    super.key,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.vehicleImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    vehicleName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Lufga',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    vehiclePlate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Center(
            child: Image.network(
              vehicleImage,
              fit: BoxFit.cover,
              height: 150,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.directions_car, size: 80),
            ),
          ),
        ],
      ),
    );
  }
}
