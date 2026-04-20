import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onecharge/screen/carbon/carbon_emiosn.dart';

class CarbonBanner extends StatelessWidget {
  final String? userName;
  const CarbonBanner({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECE9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content Section
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      color: Color(0xFF1D2D2D),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Tip of the Day",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2D2D),
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Taking the train instead of a car once a week could reduce your footprint by",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    fontFamily: 'Lufga',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      "12%",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2D2D),
                        fontFamily: 'Lufga',
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarbonEmiosn(
                              userName: userName ?? "User",
                            ),
                          ),
                        );
                        // Navigation or info logic here
                      },
                      child: const Row(
                        children: [
                          Text(
                            "Explore",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D5A27),
                              fontFamily: 'Lufga',
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF2D5A27),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right Illustration Section
          Expanded(
            flex: 11,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(
                  '/Users/ajay/.gemini/antigravity/brain/cd8f2cc2-4d11-4f45-88b6-5a31deb681df/lung_trees_illustration_1776685236069.png',
                ),

                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
