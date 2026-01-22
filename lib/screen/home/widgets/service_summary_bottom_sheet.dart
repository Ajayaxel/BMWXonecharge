import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';

class ServiceSummaryBottomSheet extends StatelessWidget {
  const ServiceSummaryBottomSheet({super.key});

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
      child: SingleChildScrollView(
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
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                const Text(
                  "50 km",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                const Text(
                  "1 Hour",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),

            // Car Model
            Row(
              children: [
                Image.asset(
                  'assets/home/car_icon_black.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (c, e, s) => const Icon(Icons.directions_car),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Card Model",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      "Tesla",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lufga',
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Landmark
            Row(
              children: [
                const Icon(Icons.location_pin, size: 24, color: Colors.black),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Landmark",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      "Baskin robbins, World trade center",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lufga',
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Added Services Section
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

            // Service Card 1
            _buildServiceCard(
              title: "Low Battery",
              price: "AED 20",
              iconPath: 'assets/home/battery_icon.png',
              items: ["battery swap", "battery swap"],
              defaultIcon: Icons.battery_charging_full,
            ),
            const SizedBox(height: 12),

            // Service Card 2
            _buildServiceCard(
              title: "Flat Tire",
              price: "AED 20",
              iconPath: 'assets/home/tire_icon.png',
              items: ["Tyre change", "Tyre change"],
              defaultIcon: Icons.tire_repair,
            ),

            const SizedBox(height: 24),

            // Pricing Table
            _buildPriceRow("Service Cost", "AED 2441"),
            const SizedBox(height: 12),
            _buildPriceRow("Service Charge", "AED 73.23"),
            const SizedBox(height: 12),
            _buildPriceRow("Vat", "AED 122.05"),
            const SizedBox(height: 16),
            _buildPriceRow("Total price", "AED 2,636.73", isTotal: true),

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
