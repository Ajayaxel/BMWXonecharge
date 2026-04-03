import 'package:flutter/material.dart';

import 'package:onecharge/screen/home/home_screen.dart';

import 'package:onecharge/screen/home/settings_screen.dart';
import 'package:onecharge/screen/home/widgets/home_products.dart';
import 'package:onecharge/screen/ourservice/our_service_screen.dart';
import 'package:onecharge/screen/shop/cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  bool _isScrolling = false;

  final List<Widget> _pages = [
    const HomeProducts(),
    const CartScreen(),
    const HomeScreen(),
    const OurServiceScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Screens
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Ignore horizontal scrolls (card swiping) and internal events
                if (notification.metrics.axis == Axis.horizontal ||
                    notification.depth != 0) {
                  return false;
                }

                if (notification is ScrollUpdateNotification) {
                  final double delta = notification.scrollDelta ?? 0;
                  final double pixels = notification.metrics.pixels;
                  const double threshold = 15.0;

                  // Shrink ONLY on intentional vertical scroll down
                  if (delta > threshold && pixels > 50) {
                    if (!_isScrolling) {
                      setState(() {
                        _isScrolling = true;
                      });
                    }
                  }
                  // Expand ONLY on intentional vertical scroll up
                  else if (delta < -threshold) {
                    if (_isScrolling) {
                      setState(() {
                        _isScrolling = false;
                      });
                    }
                  }
                }
                return false;
              },
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages.map((page) {
                  return page;
                }).toList(),
              ),
            ),
          ),

          // Custom Bottom Navigation Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            bottom: bottomPadding + 1,
            left: _isScrolling ? (screenWidth / 2 - 30) : 50,
            right: _isScrolling ? (screenWidth / 2 - 30) : 50,
            child: Container(
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.none,
                alignment: Alignment.center,
                child: Container(
                  width:
                      screenWidth -
                      100, // Matches initial expanded width (50 left, 50 right)
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: _isScrolling
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.shopping_bag_rounded, 'Shop'),
                      _buildNavItem(1, Icons.shopping_cart_rounded, 'Cart'),
                      _buildNavItem(2, Icons.home_rounded, 'Home'),
                      _buildNavItem(3, Icons.car_rental_rounded, 'Service'),
                      _buildNavItem(4, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    bool shouldShow = !_isScrolling || isSelected;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: shouldShow ? 1.0 : 0.0,
      child: shouldShow
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  _isScrolling = false; // Expand on click
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected && !_isScrolling ? 10 : 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.black
                          : Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    if (isSelected && !_isScrolling) ...[
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lufga',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
