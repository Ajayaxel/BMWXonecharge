import 'package:flutter/material.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _vehicles = [
    {
      'model': 'Tesla Model S',
      'image': 'assets/home/carimag.png',
      'range': '163 km Left',
      'battery': '50',
      'type': 'Mennekes (Type 2)',
      'number': 'DUBAI01AS55',
    },
    {
      'model': 'BMW i4 M50',
      'image': 'assets/home/carimag.png',
      // Using same image as placeholder
      'range': '210 km Left',
      'battery': '75',
      'type': 'CCS Combo 2',
      'number': 'DUBAI02XY99',
    },
    {
      'model': 'Audi e-tron GT',
      'image': 'assets/home/carimag.png', // Using same image as placeholder
      'range': '185 km Left',
      'battery': '60',
      'type': 'Type 2 / CCS',
      'number': 'DUBAI03QQ11',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final vehicle = _vehicles[_selectedIndex];

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
          'My Vehicle',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-50 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Text(
                vehicle['range']!,
                style: const TextStyle(
                  fontSize: 48,
                  fontFamily: 'Lufga',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(-40 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildInfoColumn('Car Model', vehicle['model']!),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(40 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildInfoColumn(
                    'Charging Type',
                    vehicle['type']!,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-30 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: _buildInfoColumn('Vehicle Number', vehicle['number']!),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(
                      _selectedIndex,
                    ), // Key forces animation on switch
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(
                      milliseconds: 1500,
                    ), // Slower duration
                    curve: Curves
                        .easeInOutCubic, // More organic, professional curve
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            800 * (1 - value),
                          ), // Start further down
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      vehicle['image']!,
                      height: 380,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_vehicles.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildThumbnail(
                          _vehicles[index]['image']!,
                          isSelected: _selectedIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(8, (index) {
                        double batteryLevel = double.parse(vehicle['battery']!);
                        int greenBars = (batteryLevel / 12.5).round();
                        return Container(
                          width: 32,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: index < greenBars
                                ? const Color(0xFF27AE10)
                                : const Color(0xFFE9F5E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${vehicle['battery']}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'Lufga',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF9E9E9E),
            fontFamily: 'Lufga',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lufga',
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(
    String imagePath, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 100,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
      ),
    );
  }
}
