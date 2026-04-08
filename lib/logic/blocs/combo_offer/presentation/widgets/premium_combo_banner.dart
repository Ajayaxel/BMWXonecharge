import 'package:flutter/material.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/models/combo_offer_model.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/screens/combo_buy_screen.dart';

class PremiumComboBanner extends StatelessWidget {
  final ComboOfferModel offer;
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const PremiumComboBanner({
    super.key,
    required this.offer,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Shape
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Image
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Hero(
                    tag: 'combo_offer_${offer.id}',
                    child: Center(
                      child: Image.network(
                        offer.imageUrl,
                        height: 130,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black26,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              // Right: Content
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Sale Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B1B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${offer.discountPercentage.replaceAll('.00', '')}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          offer.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        offer.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Lufga',
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),

                      const Spacer(),

                      // Price and CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Prices
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AED ${offer.comboPrice}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Lufga',
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'AED ${offer.originalPrice}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: 'Lufga',
                                  color: Colors.black26,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComboBuyScreen(
                                    offer: offer,
                                    initialAddress: initialAddress,
                                    initialLatitude: initialLatitude,
                                    initialLongitude: initialLongitude,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Shop Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
