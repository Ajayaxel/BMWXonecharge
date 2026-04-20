import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_bloc.dart';
import 'package:onecharge/logic/blocs/product_group/product_group_state.dart';
import 'package:onecharge/models/product_group_model.dart';
import 'package:onecharge/models/product_model.dart';

class HomeProductGroups extends StatefulWidget {
  final String searchQuery;

  const HomeProductGroups({super.key, required this.searchQuery});

  @override
  State<HomeProductGroups> createState() => _HomeProductGroupsState();
}

class _HomeProductGroupsState extends State<HomeProductGroups> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductGroupBloc, ProductGroupState>(
      builder: (context, state) {
        if (state is ProductGroupLoading) {
          return _buildShimmerLoading();
        } else if (state is ProductGroupError) {
          return const SizedBox();
        } else if (state is ProductGroupLoaded) {
          final groups = state.productGroups;
          if (groups.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groups.map((group) => _buildGroup(group)).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildGroup(ProductGroupModel group) {
    var products = group.products;

    if (widget.searchQuery.isNotEmpty) {
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(widget.searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            group.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
        ),
        ProductGroupCarousel(products: products),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 140,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductGroupCarousel extends StatefulWidget {
  final List<ProductModel> products;

  const ProductGroupCarousel({super.key, required this.products});

  @override
  State<ProductGroupCarousel> createState() => _ProductGroupCarouselState();
}

class _ProductGroupCarouselState extends State<ProductGroupCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.60, // Narrower cards, showing more of the next item
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Slightly reduced height to match the narrower width
      child: PageView.builder(
        controller: _pageController,
        clipBehavior: Clip.none,
        padEnds: false, // Aligns first card to the left
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          // Scale logic: Active card is 1.0, side cards are 0.8. Stronger difference.
          double delta = (_currentPage - index).abs();
          double scale = (1 - delta * 0.2).clamp(0.7, 1.0);

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: scale, end: scale),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                alignment: Alignment.center,
                child: _ProductCard(
                  product: product,
                  backgroundColor: index % 2 == 0
                      ? const Color(0xffF5F5F5)
                      : const Color(0xffF5F5F5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _showDescription = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Hero(
                          tag: 'product_${widget.product.id}',
                          child: _buildImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Content Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lufga',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                "${widget.product.currency} ${widget.product.price}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ),
                            if (widget.product.sku.isNotEmpty)
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    widget.product.sku,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.3),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Lufga',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expanding Glass Description Sheet (Bottom)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _showDescription ? 0 : -120, // Slide up/down
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Quick Info",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showDescription = false),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              widget.product.shortDescription,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Lufga',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Glassmorphism Eye Icon (Top Right)
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showDescription = !_showDescription),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: _showDescription
                              ? Colors.black.withOpacity(0.1)
                              : Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _showDescription
                                ? Icons.visibility_off
                                : Icons.visibility_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String imageUrl = widget.product.mainImage;

    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 150,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black.withOpacity(0.1),
              size: 100,
            ),
          )
        : Icon(
            Icons.shopping_bag_outlined,
            color: Colors.black.withOpacity(0.1),
            size: 100,
          );
  }
}
