import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/models/product_model.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';

class PremiumProductCard extends StatefulWidget {
  final ProductModel product;
  final double? width;
  final double? height;
  final String? categoryName;

  const PremiumProductCard({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.categoryName,
  });

  @override
  State<PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<PremiumProductCard> {
  @override
  void initState() {
    super.initState();
    // Initialize wishlist status in the BLoC for this product
    context.read<WishlistBloc>().add(
      InitializeProductWishlistStatusEvent(
        productId: widget.product.id,
        isWishlisted: widget.product.isWishlisted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistBloc, WishlistState>(
      listenWhen: (previous, current) =>
          current.error != null &&
          current.loadingProductId == widget.product.id,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(productId: widget.product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            AspectRatio(
              aspectRatio: 0.95, // Slightly taller than square for premium feel
              child: Stack(
                children: [
                  // Main Image with dark background and curved bottom
                  Positioned.fill(
                    child: ClipPath(
                      clipper: ProductImageClipper(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(
                            232,
                            231,
                            234,
                            234,
                          ), // Dark background
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: widget.product.mainImage.isNotEmpty
                                ? Hero(
                                    tag:
                                        'product_image_${widget.product.id}_${widget.hashCode}',
                                    child: Image.network(
                                      widget.product.mainImage,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Wishlist Button (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: BlocSelector<WishlistBloc, WishlistState, bool>(
                      selector: (state) =>
                          state.wishlistMap[widget.product.id] ??
                          widget.product.isWishlisted,
                      builder: (context, isWishlisted) {
                        return GestureDetector(
                          onTap: () {
                            context.read<WishlistBloc>().add(
                              ToggleWishlistEvent(productId: widget.product.id),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.black,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Price Tag (Bottom Right placement inside the curve)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.product.currency} ${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'Lufga',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Product Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.categoryName ?? 'Premium Accessories',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cutoutWidth = 72.0; // Optimized spacing
    const double cutoutHeight = 35.0;
    const double radius = 24.0; // Match card border radius

    final path = Path();

    // Start at top left
    path.moveTo(0, 0);

    // Top right
    path.lineTo(size.width, 0);

    // Right side down to where curve starts
    path.lineTo(size.width, size.height - cutoutHeight - 20);

    // The concave curve for the "notch" - an inward scoop
    path.cubicTo(
      size.width,
      size.height - cutoutHeight - 10,
      size.width - 5,
      size.height - cutoutHeight,
      size.width - 25,
      size.height - cutoutHeight,
    );

    // Horizontal line for cutout top
    path.lineTo(size.width - cutoutWidth + 25, size.height - cutoutHeight);

    // Another smooth transition down to the vertical wall
    path.cubicTo(
      size.width - cutoutWidth + 5,
      size.height - cutoutHeight,
      size.width - cutoutWidth,
      size.height - cutoutHeight + 10,
      size.width - cutoutWidth,
      size.height - cutoutHeight + 25,
    );

    // Vertical wall down toward bottom, stopping early for radius
    path.lineTo(size.width - cutoutWidth, size.height - radius);

    // NEW: Border radius for the bottom corner of the red container
    path.arcToPoint(
      Offset(size.width - cutoutWidth - radius, size.height),
      radius: const Radius.circular(radius),
    );

    // Bottom edge to left
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
