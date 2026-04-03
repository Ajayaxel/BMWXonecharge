import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_state.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/screen/home/widgets/home_header.dart';
import 'package:onecharge/screen/shop/all_products_screen.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';
import 'package:onecharge/models/product_model.dart';
import 'package:onecharge/core/storage/location_storage.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';

class HomeProducts extends StatefulWidget {
  const HomeProducts({super.key});

  @override
  State<HomeProducts> createState() => _HomeProductsState();
}

class _HomeProductsState extends State<HomeProducts> {
  int _selectedCategoryId = 0; // 0 for "All"
  String _currentAddress = 'Loading...';
  final TextEditingController _searchController = TextEditingController();

  late PageController _productPageController;
  double _currentProductPage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _productPageController = PageController();
    _productPageController.addListener(() {
      setState(() {
        _currentProductPage = _productPageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productPageController.dispose();
    super.dispose();
  }

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
          final List<ProductModel> baseProducts;
          final String currentTitle;
          if (_selectedCategoryId == 0) {
            baseProducts = allUniqueProducts;
            currentTitle = 'All Products';
          } else {
            final category = categories.firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => categories.first,
            );
            baseProducts = category.products;
            currentTitle = category.name;
          }

          // Apply Search filtering
          final List<ProductModel> currentProducts = baseProducts.where((p) {
            if (_searchController.text.isEmpty) return true;
            return p.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
          }).toList();

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<LocationBloc, LocationState>(
                      builder: (context, locationState) {
                        String dynamicAddress = _currentAddress;
                        if (locationState is LocationsLoaded &&
                            locationState.selectedLocation != null) {
                          dynamicAddress =
                              locationState.selectedLocation!.name.isNotEmpty
                              ? locationState.selectedLocation!.name
                              : locationState.selectedLocation!.address;
                        }
                        return HomeHeader(
                          currentAddress: dynamicAddress,
                          hintText: 'Search for any products',
                          searchController: _searchController,
                          onSearchChanged: (value) {
                            setState(
                              () {},
                            ); // Trigger rebuild to filter products
                          },
                          onLocationChanged: (LocationModel result) {
                            setState(() {
                              _currentAddress = result.name.isNotEmpty
                                  ? result.name
                                  : result.address;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const BannerSection(),
                    const SizedBox(height: 16),
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
                          final int categoryId = isAll
                              ? 0
                              : categories[index - 1].id;
                          final bool isSelected =
                              _selectedCategoryId == categoryId;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = categoryId;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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

                    const SizedBox(height: 16),
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
                            height: 250,
                            width: double.infinity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Visual Stack
                                if (currentProducts.isNotEmpty)
                                  for (int i = 4; i >= 0; i--) ...[
                                    if (i + _currentProductPage.floor() <
                                        currentProducts.length)
                                      Builder(
                                        builder: (context) {
                                          final int itemIndex =
                                              i + _currentProductPage.floor();
                                          final product =
                                              currentProducts[itemIndex];
                                          final double relativePos =
                                              itemIndex - _currentProductPage;

                                          // Calculate position
                                          double leftOffset;
                                          if (relativePos < 0) {
                                            // Card is sliding away to the left
                                            leftOffset = relativePos * 300;
                                          } else {
                                            // Card is in the stack or moving forward
                                            leftOffset = relativePos * 35.0;
                                          }

                                          return Positioned(
                                            left: leftOffset,
                                            top:
                                                (relativePos.clamp(0, 4)) * 6.0,
                                            bottom:
                                                (relativePos.clamp(0, 4)) * 6.0,
                                            child:
                                                itemIndex ==
                                                    _currentProductPage.floor()
                                                ? _FloatingCard(
                                                    child: _ProductCard(
                                                      product: product,
                                                      bgColor: _getBgColor(
                                                        itemIndex,
                                                      ),
                                                      isFront: true,
                                                    ),
                                                  )
                                                : _ProductCard(
                                                    product: product,
                                                    bgColor: _getBgColor(
                                                      itemIndex,
                                                    ),
                                                    isFront: false,
                                                  ),
                                          );
                                        },
                                      ),
                                  ],
                                // Gesture Layer
                                Positioned.fill(
                                  child: PageView.builder(
                                    controller: _productPageController,
                                    itemCount: currentProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = currentProducts[index];
                                      return Stack(
                                        children: [
                                          // Replicate the card's tap area
                                          Positioned(
                                            left: 0,
                                            width: 280,
                                            height: 250,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailScreen(
                                                          productId: product.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Stack(
                                                children: [
                                                  // Wishlist Button Tap Area (if front card)
                                                  if (index ==
                                                      _currentProductPage
                                                          .floor())
                                                    Positioned(
                                                      top: 16,
                                                      right: 16,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                WishlistBloc
                                                              >()
                                                              .add(
                                                                ToggleWishlistEvent(
                                                                  productId:
                                                                      product
                                                                          .id,
                                                                ),
                                                              );
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is ShopCategoryFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _loadSavedLocation() async {
    final saved = await LocationStorage.getSelectedLocation();
    if (saved != null && saved['isManual'] == true) {
      if (mounted) {
        setState(() {
          _currentAddress = saved['address'];
        });
      }
    }
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
                const SizedBox(height: 10),
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
                      color: Colors.black, // Corrected colors
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
  final bool isFront;

  const _ProductCard({
    required this.product,
    required this.bgColor,
    this.isFront = true,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  @override
  void initState() {
    super.initState();
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
      child: Container(
        width: 280, // Wider for the horizontal layout
        margin: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          color: widget.bgColor, // Using existing bg colors
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(4, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Left Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag Bubble
                  const SizedBox(height: 20),
                  // Product Name
                  SizedBox(
                    width: 150,
                    child: Text(
                      widget.product.name,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        fontFamily: 'Lufga',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    '${widget.product.currency} ${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Lufga',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Product Image (Right side, overlapping)
            Positioned(
              right: -25,
              top: 20,
              bottom: 20,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(10, 10),
                    ),
                  ],
                ),
                child: Center(
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
            ),

            // Wishlist Icon (Top Right, if front card)
            if (widget.isFront)
              Positioned(
                top: 16,
                right: 16,
                child: BlocSelector<WishlistBloc, WishlistState, bool>(
                  selector: (state) =>
                      state.wishlistMap[widget.product.id] ??
                      widget.product.isWishlisted,
                  builder: (context, isWishlisted) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCard extends StatefulWidget {
  final Widget child;
  const _FloatingCard({required this.child});

  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}
