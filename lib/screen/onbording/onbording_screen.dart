import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/screen/login/login_screen.dart';
import 'package:onecharge/utils/onboarding_service.dart';
import 'package:smoke_effect/smoke_effect.dart';

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/onbord/car_onboarding.png',
      'title': "Premium EV Accessories",
      'subtitle':
          "OneCharge delivers quick, reliable support\nwhenever your vehicle needs it.",
    },
    {
      'image': 'assets/onbord/onbord2.png',
      'title': "Roadside Assistance",
      'subtitle':
          "From flat tyres to mechanical issues,\nwe get you moving again, fast.",
    },

    {
      'image': 'assets/onbord/onbord4.png',
      'title': "Reliable Towing",
      'subtitle':
          "Professional towing services across the city,\navailable whenever you're stuck.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Testlogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image (behind everything, changes with PageView)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                _pages[_currentPage]['image']!,
                key: ValueKey<int>(_currentPage),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Full Page Smoke Effect
          const Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: IgnorePointer(
                child: SmokeEffect(
                  gradientSmoke: true,
                  singleSmokeColor: Colors.white,
                ),
              ),
            ),
          ),
          // Content Layout
          Column(
            children: [
              // Top section (visual only, for height distribution)
              const Expanded(flex: 6, child: SizedBox.shrink()),

              // Bottom section - 40% of screen height with glass effect
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _pages.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Text(
                                    _pages[index]['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Lufga',
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _pages[index]['subtitle']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Lufga',
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Overlay UI Elements (indicators and skip)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List.generate(_pages.length, (index) {
                              return _buildTopIndicator(_currentPage == index);
                            })
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: e,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + -10,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Skip logic - mark complete and go to login
                _finishOnboarding();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation (Dots and Button)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white30,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                OneBtn(
                  onPressed: _nextPage,
                  text: _currentPage == _pages.length - 1
                      ? "Get Started"
                      : "Next",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 40 : 20,
      height: 2,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
