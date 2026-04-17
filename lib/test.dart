import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});
  final List<String> images = const [
    "assets/home/carcard.png",
    "assets/home/carcard.png",
    "assets/home/carcard.png",
    "assets/home/carcard.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16, // Extra space for the bottom overflow
              childAspectRatio: 130 / 230,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const Center(child: CarCards());
            },
          ),
        ),
      ),
    );
  }
}

class CarCards extends StatelessWidget {
  const CarCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: 130,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xff6dd4d0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -50,
                    right: -20,
                    child: Image.asset(
                      "assets/home/carcard.png",
                      fit: BoxFit.contain,
                      height: 280,
                      width: 150,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text("KWH 320"),
            Text("AED 100"),
          ],
        ),
      ],
    );
  }
}
