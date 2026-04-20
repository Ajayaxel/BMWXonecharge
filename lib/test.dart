import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_event.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_state.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/screens/combo_buy_screen.dart';
import 'package:onecharge/screen/home/widgets/carbon/carbon_banner.dart';
import 'package:onecharge/screen/home/widgets/home_product_groups.dart';
import 'package:onecharge/screen/home/widgets/home_service_groups.dart';
import 'package:onecharge/screen/home/widgets/vehicle_selection_bottom_sheet.dart';
import 'package:onecharge/widgets/banner_section.dart';

class HomeFullScreen extends StatefulWidget {
  const HomeFullScreen({super.key});

  @override
  State<HomeFullScreen> createState() => _HomeFullScreenState();
}

class _HomeFullScreenState extends State<HomeFullScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _carouselData = [
    {
      "image":
          "https://i.pinimg.com/736x/f4/60/b2/f460b2344511dfe1daedb09c6d02840b.jpg",
      "title": "Save 30% off",
      "subtitle": "first 2 booking",
      "code": "125MND",
    },
    {
      "image":
          "https://wallpapers.com/images/featured/tesla-olny3d2960kbjdtk.jpg",
      "title": "Ultra Speed",
      "subtitle": "Charge anywhere",
      "code": "SPEED25",
    },
    {
      "image":
          "https://www.elektrischeauto.nl/wp-content/uploads/2024/05/Tesla_Model_3_Performance_2024-01@2x-1024x576.jpg",
      "title": "Eco Friendly",
      "subtitle": "Go Green Today",
      "code": "ECO10",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_currentPage < _carouselData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.62,
              child: Stack(
                children: [
                  // Auto-Scrolling Background Carousel
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _carouselData.length,
                    itemBuilder: (context, index) {
                      return _buildCarouselItem(_carouselData[index]);
                    },
                  ),

                  // Static UI overlay (Header & Search)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Custom Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white10,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    fontFamily: 'Lufga',
                                  ),
                                ),
                                const Text(
                                  "Ajay",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lufga',
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Search Component
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const TextField(
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lufga',
                            ),
                            decoration: InputDecoration(
                              hintText: "Search your destination...",
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Lufga',
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.white70,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //. dont use this

            // Our Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeServiceGroups(
                    searchQuery: "",
                    onServiceSelected: (categoryName, categoryId) {
                      VehicleSelectionBottomSheet.show(
                        context,
                        category: categoryName,
                        currentAddress: "currentAddress",
                        currentLatitude: 12,
                        currentLongitude: 12,
                        selectedLocationId: 12,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  CarbonBanner(),
                  const SizedBox(height: 16),

                  const HomeProductGroups(searchQuery: ""),
                  const SizedBox(height: 16),
                  BlocBuilder<ComboOfferBloc, ComboOfferState>(
                    builder: (context, state) {
                      final offer =
                          state is ComboOfferLoaded &&
                              state.comboOffers.isNotEmpty
                          ? state.comboOffers.firstWhere(
                              (o) => o.id == 2,
                              orElse: () => state.comboOffers.first,
                            )
                          : null;

                      return BannerSection(
                        image: offer != null
                            ? offer.imageUrl
                            : "https://static.vecteezy.com/system/resources/previews/059/007/249/non_2x/ev-charger-station-transparent-background-free-png.png",
                        title: offer != null
                            ? offer.name
                            : "Mega Deals on EV Accessories ⚡",
                        subtitle: offer != null
                            ? offer.description
                            : "Grab exclusive discounts on top-quality upgrades for your ride.",
                        buttonText: "Shop Deals",
                        comboPrice: offer?.comboPrice,
                        originalPrice: offer?.originalPrice,
                        onTap: () {
                          if (offer != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComboBuyScreen(
                                  offer: offer,
                                  initialAddress: "currentAddress",
                                  initialLatitude: 12,
                                  initialLongitude: 12,
                                ),
                              ),
                            );
                          } else {
                            context.read<ComboOfferBloc>().add(
                              FetchComboOffers(),
                            );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, String> data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(data["image"]!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay Gradients
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          // Coupon Content
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  data["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Lufga',
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  data["subtitle"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lufga',
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                // Enhanced Visibility Voucher Bar with Glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          0.12,
                        ), // Subtle dark tint for visibility
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "USECODE : ${data["code"]!}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Lufga',
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
