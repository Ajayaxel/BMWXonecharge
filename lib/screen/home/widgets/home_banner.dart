import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_bloc.dart';
import 'package:onecharge/logic/blocs/service_banner/service_banner_state.dart';

class HomeBanner extends StatefulWidget {
  final Function(String) onToast;

  const HomeBanner({super.key, required this.onToast});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        final state = context.read<ServiceBannerBloc>().state;
        if (state is ServiceBannerLoaded && state.banners.length > 1) {
          final nextIndex = (_currentBannerIndex + 1) % state.banners.length;
          _bannerController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBannerBloc, ServiceBannerState>(
      builder: (context, state) {
        // ── Shimmer while loading ──────────────────────────
        if (state is ServiceBannerInitial || state is ServiceBannerLoading) {
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }

        // ── Error: fall back to static asset banner ────────
        if (state is ServiceBannerError) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home/bannerBG.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save 30% off\nfirst 2 booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'USECODE 125MND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // ── Loaded: API banners ────────────────────────────
        if (state is ServiceBannerLoaded) {
          final banners = state.banners;
          if (banners.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _bannerController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // Background image
                            Image.network(
                              banner.bgImage,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Image.asset(
                                        'assets/home/bannerBG.png',
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            // Dark gradient so text is always readable
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withOpacity(0.55),
                                      Colors.black.withOpacity(0.10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Text & code chip
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      () {
                                        final words = banner.title.split(' ');
                                        if (words.length <= 1) {
                                          return banner.title;
                                        }
                                        final mid = (words.length / 2).ceil();
                                        return '${words.take(mid).join(' ')}\n${words.skip(mid).join(' ')}';
                                      }(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Lufga',
                                        height: 1.2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Code pill chip — tap to copy
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: banner.code),
                                      );
                                      widget.onToast(
                                        'Code "${banner.code}" copied!',
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.20),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.50),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'USECODE ${banner.code}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Lufga',
                                              letterSpacing: 0.5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.copy_rounded,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (banners.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentBannerIndex == index
                                ? Colors.black
                                : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
