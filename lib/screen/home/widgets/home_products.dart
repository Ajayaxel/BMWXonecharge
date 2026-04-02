import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_state.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/screen/shop/all_products_screen.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';
import 'package:onecharge/models/product_model.dart';

class HomeProducts extends StatefulWidget {
  const HomeProducts({super.key});

  @override
  State<HomeProducts> createState() => _HomeProductsState();
}

class _HomeProductsState extends State<HomeProducts> {
  int _selectedCategoryId = 0; // 0 for "All"

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCategoryBloc, ShopCategoryState>(
      builder: (context, state) {
        if (state is ShopCategoryLoading) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        } else if (state is ShopCategoryLoaded) {
          if (state.categories.isEmpty) {
            return const SizedBox();
          }

          final categories = state.categories;

          // Aggregating all products for the "All" category
          final allUniqueProducts = <ProductModel>[];
          final uniqueIds = <int>{};
          for (var cat in categories) {
            for (var prod in cat.products) {
              if (uniqueIds.add(prod.id)) {
                allUniqueProducts.add(prod);
              }
            }
          }

          // Determining what to display based on selection
          final List<ProductModel> currentProducts;
          final String currentTitle;
          if (_selectedCategoryId == 0) {
            currentProducts = allUniqueProducts;
            currentTitle = 'All Products';
          } else {
            final category = categories.firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => categories.first,
            );
            currentProducts = category.products;
            currentTitle = category.name;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BannerSection(),
              SizedBox(height: 20),
              // Category Selection Row
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final bool isAll = index == 0;
                    final String name = isAll
                        ? 'All'
                        : categories[index - 1].name;
                    final int categoryId = isAll ? 0 : categories[index - 1].id;
                    final bool isSelected = _selectedCategoryId == categoryId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = categoryId;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1B1B1B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lufga',
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 24),
              // Dynamic Product Section (Single Row with 4 items or filtered data)
              if (currentProducts.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lufga',
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllProductsScreen(
                                  title: currentTitle,
                                  products: currentProducts,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lufga',
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        // Limiting to 4 items as requested for the home page row
                        itemCount: currentProducts.length > 4
                            ? 4
                            : currentProducts.length,
                        itemBuilder: (context, index) {
                          final product = currentProducts[index];
                          return _ProductCard(
                            product: product,
                            bgColor: _getBgColor(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        } else if (state is ShopCategoryFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return const SizedBox();
      },
    );
  }

  Color _getBgColor(int index) {
    final colors = [
      const Color(0xFFFEE4E2),
      const Color(0xFFE0F2FE),
      const Color(0xFFF0FDF4),
      const Color(0xFFFFF7ED),
    ];
    return colors[index % colors.length];
  }
}

class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA), // Lighter, premium gray background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Image
          Image.network(
            "https://file.aiquickdraw.com/imgcompressed/img/compressed_9960ab753127cff8b7bca85811c3add6.webp",
            height: 120,
            fit: BoxFit.contain,
          ),

          // Spacing between image and content
          // Right Side: Texts and Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                // Main Title (Updated for Accessories)
                const Text(
                  "Enhance Your Ride:\nPremium Accessories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle (Updated for Accessories)
                const Text(
                  "Explore our full range of essential EV add-ons and upgrades.",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Lufga',
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                // "Shop Now" Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ), // Light blue-gray
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Shop Now",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                        color: Colors.white,
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

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final Color bgColor;

  const _ProductCard({required this.product, required this.bgColor});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  @override
  void initState() {
    super.initState();
    // Initialize global wishlist state from the product model
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
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.bgColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: widget.product.mainImage.isNotEmpty
                              ? Image.network(
                                  widget.product.mainImage,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  'assets/home/chargingsation.png',
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: BlocSelector<WishlistBloc, WishlistState, bool>(
                          selector: (state) =>
                              state.wishlistMap[widget.product.id] ??
                              widget.product.isWishlisted,
                          builder: (context, isWishlisted) {
                            return GestureDetector(
                              onTap: () {
                                context.read<WishlistBloc>().add(
                                  ToggleWishlistEvent(
                                    productId: widget.product.id,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isWishlisted
                                      ? Colors.red
                                      : Colors.black,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '${widget.product.currency} ${widget.product.price}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lufga',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
