import 'package:flutter/material.dart';
import 'package:onecharge/screen/home/home_screen.dart';
import 'package:onecharge/screen/settings/settings_screen.dart';
import 'package:onecharge/screen/shop/shop_product_screen.dart';
import 'package:onecharge/screen/ourservice/our_service_screen.dart';
import 'package:onecharge/screen/shop/cart_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 2});

  static _MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainScreenState>();
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late int _selectedIndex;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _isScrolling = false;
    });
  }

  final List<Widget> _pages = [
    const ShopProductScreen(),
    const CartScreen(),
    const HomeScreen(),
    const OurServiceScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Responsive dimensions
    final double navBarHeight = (screenHeight * 0.07).clamp(60.0, 75.0);
    final double navBarWidth = _isScrolling 
        ? (navBarHeight * 1.0) 
        : (screenWidth * 0.85).clamp(300.0, 500.0);
    final double horizontalPadding = (screenWidth * 0.04).clamp(12.0, 20.0);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content Pages
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.horizontal ||
                    notification.depth != 0) {
                  return false;
                }

                if (notification is ScrollUpdateNotification) {
                  final double delta = notification.scrollDelta ?? 0;
                  final double pixels = notification.metrics.pixels;
                  const double threshold = 20.0;

                  if (delta > threshold && pixels > 50) {
                    if (!_isScrolling) setState(() => _isScrolling = true);
                  } else if (delta < -threshold) {
                    if (_isScrolling) setState(() => _isScrolling = false);
                  }
                }
                return false;
              },
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),

          // Responsive Premium Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding > 0 ? bottomPadding : 20,
            child: SafeArea(
              top: false,
              bottom: bottomPadding == 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  height: navBarHeight,
                  width: navBarWidth,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(navBarHeight / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: _isScrolling ? 0 : horizontalPadding),
                  child: Row(
                    mainAxisAlignment: _isScrolling ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final itemData = [
                        {'outline': Icons.shopping_bag_outlined, 'solid': Icons.shopping_bag_rounded, 'label': 'Shop'},
                        {'outline': Icons.shopping_cart_outlined, 'solid': Icons.shopping_cart_rounded, 'label': 'Cart'},
                        {'outline': Icons.home_outlined, 'solid': Icons.home_rounded, 'label': 'Home'},
                        {'outline': Icons.car_repair_outlined, 'solid': Icons.car_repair_rounded, 'label': 'Service'},
                        {'outline': Icons.person_outline_rounded, 'solid': Icons.person_rounded, 'label': 'Profile'},
                      ][index];

                      bool isSelected = _selectedIndex == index;
                      bool shouldShow = !_isScrolling || isSelected;

                      if (!shouldShow) return const SizedBox.shrink();

                      return Flexible(
                        flex: isSelected && !_isScrolling ? 2 : 1,
                        child: _buildNavItem(
                          index,
                          itemData['outline'] as IconData,
                          itemData['solid'] as IconData,
                          itemData['label'] as String,
                          screenWidth,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label, double screenWidth) {
    final bool isSelected = _selectedIndex == index;
    
    // Proportional scaling
    final double iconSize = (screenWidth * 0.055).clamp(22.0, 26.0);
    final double fontSize = (screenWidth * 0.034).clamp(12.0, 14.0);

    return GestureDetector(
      onTap: () => setState(() {
        _selectedIndex = index;
        _isScrolling = false;
      }),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected && !_isScrolling ? 14 : 10,
            vertical: 10,
          ),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 400),
                  scale: isSelected ? 1.1 : 1.0,
                  child: Icon(
                    isSelected ? solidIcon : outlineIcon,
                    color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                    size: iconSize,
                  ),
                ),
                if (isSelected && !_isScrolling) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lufga',
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
