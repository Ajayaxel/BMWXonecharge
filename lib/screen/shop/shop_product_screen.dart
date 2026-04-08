import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_bloc.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_event.dart';
import 'package:onecharge/logic/blocs/shop_category/shop_category_state.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/screen/home/widgets/home_header.dart';
import 'package:onecharge/screen/shop/all_products_screen.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';
import 'package:onecharge/models/product_model.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/logic/blocs/location/location_bloc.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
import 'package:onecharge/core/mixins/location_handler_mixin.dart';
import 'package:onecharge/widgets/banner_section.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_state.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/widgets/premium_combo_banner.dart';

class ShopProductScreen extends StatefulWidget {
  const ShopProductScreen({super.key});

  @override
  State<ShopProductScreen> createState() => _ShopProductScreenState();
}

class _ShopProductScreenState extends State<ShopProductScreen>
    with LocationHandlerMixin {
  int _selectedCategoryId = 0; // 0 for "All"
  List<ShopCategoryModel> _cachedCategories = []; 
  late PageController _productPageController;
  double _currentProductPage = 0.0;

  @override
  void initState() {
    super.initState();
    loadSavedLocation();
    _productPageController = PageController();
    _productPageController.addListener(() {
      setState(() {
        _currentProductPage = _productPageController.page ?? 0.0;
      });
    });

    // Initial fetch on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShopCategoryBloc>().add(FetchShopCategories());
      }
    });
  }

  @override
  void dispose() {
    disposeLocation();
    _productPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCategoryBloc, ShopCategoryState>(
      builder: (context, state) {
        if (state is ShopCategoryLoaded) {
          _cachedCategories = state.categories;
        }

        // If it's the very first load and we have no data yet
        if (state is ShopCategoryLoading && _cachedCategories.isEmpty) {
          return const _ShopScreenSkeleton();
        }

        if (_cachedCategories.isEmpty && state is! ShopCategoryLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state is ShopCategoryFailure
                          ? 'Error: ${state.error}'
                          : 'No categories available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ShopCategoryBloc>().add(FetchShopCategories());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B1B1B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = _cachedCategories;
        final bool isRefreshing = state is ShopCategoryLoading;

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
          if (searchController.text.isEmpty) return true;
          return p.name.toLowerCase().contains(
                searchController.text.toLowerCase(),
              );
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocListener<LocationBloc, LocationState>(
                      listener: (context, locationState) {
                        if (locationState is LocationsLoaded) {
                          validateCurrentLocation(locationState.locations);
                          if (locationState.selectedLocation != null) {
                            final loc = locationState.selectedLocation!;
                            setState(() {
                              currentAddress = loc.name.isNotEmpty
                                  ? loc.name
                                  : loc.address;
                              currentLatitude = loc.latitude;
                              currentLongitude = loc.longitude;
                              selectedLocationId = loc.id;
                            });
                          }
                        }
                      },
                      child: HomeHeader(
                        currentAddress: currentAddress,
                        hintText: 'Search for any products',
                        searchController: searchController,
                        onSearchChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                          // Reset carousel index to 0 when search query changes
                          if (_productPageController.hasClients) {
                            _productPageController.jumpToPage(0);
                          }
                          setState(() {
                            _currentProductPage = 0.0;
                          });
                        },
                        onLocationChanged: (LocationModel result) {
                          setState(() {
                            currentAddress = result.name.isNotEmpty
                                ? result.name
                                : result.address;
                            currentLatitude = result.latitude;
                            currentLongitude = result.longitude;
                            selectedLocationId = result.id;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<ComboOfferBloc, ComboOfferState>(
                      builder: (context, state) {
                        if (state is ComboOfferLoaded &&
                            state.comboOffers.isNotEmpty) {
                          final offer = state.comboOffers.firstWhere(
                            (o) => o.id == 1,
                            orElse: () => state.comboOffers.first,
                          );
                          return PremiumComboBanner(
                            offer: offer,
                            initialAddress: currentAddress,
                            initialLatitude: currentLatitude,
                            initialLongitude: currentLongitude,
                          );
                        }
                        
                        // Fallback or skeleton
                        if (state is ComboOfferLoading) {
                           return Shimmer.fromColors(
                             baseColor: Colors.grey[200]!,
                             highlightColor: Colors.grey[100]!,
                             child: Container(
                               height: 150,
                               width: double.infinity,
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(16),
                               ),
                             ),
                           );
                        }

                        return const BannerSection(
                          image:
                              "https://file.aiquickdraw.com/imgcompressed/img/compressed_9960ab753127cff8b7bca85811c3add6.webp",
                          title: "Enhance Your Ride:\nPremium Accessories",
                          subtitle:
                              "Explore our full range of essential EV add-ons and upgrades.",
                          buttonText: "Shop Now",
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Selection Row
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          final bool isAll = index == 0;
                          final String name =
                              isAll ? 'All' : categories[index - 1].name;
                          final int categoryId =
                              isAll ? 0 : categories[index - 1].id;
                          final bool isSelected =
                              _selectedCategoryId == categoryId;

                          return GestureDetector(
                            onTap: () {
                              if (_selectedCategoryId != categoryId) {
                                setState(() {
                                  _selectedCategoryId = categoryId;
                                });
                                
                                // Reset carousel index to 0 for the new category
                                if (_productPageController.hasClients) {
                                  _productPageController.jumpToPage(0);
                                }
                                setState(() {
                                  _currentProductPage = 0.0;
                                });

                                // Properly fetching on tab switch as requested
                                context
                                    .read<ShopCategoryBloc>()
                                    .add(FetchShopCategories());
                              }
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

                    const SizedBox(height: 22),

                    // Dynamic Product Section
                    if (isRefreshing && currentProducts.isEmpty)
                      SizedBox(
                        height: 265,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          padding: const EdgeInsets.only(left: 4),
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: _ProductCardSkeleton(),
                          ),
                        ),
                      )
                    else if (currentProducts.isEmpty)
                      _buildEmptyState()
                    else
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
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 265,
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

                                                double leftOffset;
                                                if (relativePos < 0) {
                                                  leftOffset = relativePos * 300;
                                                } else {
                                                  leftOffset = relativePos * 35.0;
                                                }

                                                return Positioned(
                                                  left: leftOffset,
                                                  top: (relativePos.clamp(0, 4)) *
                                                      6.0,
                                                  bottom:
                                                      (relativePos.clamp(0, 4)) *
                                                          6.0,
                                                  child: itemIndex ==
                                                          _currentProductPage
                                                              .floor()
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
                                                Positioned(
                                                  left: 0,
                                                  width: 280,
                                                  height: 250,
                                                  child: GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductDetailScreen(
                                                                productId:
                                                                    product.id,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: Stack(
                                                      children: [
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
                                                                        WishlistBloc>()
                                                                    .add(
                                                                      ToggleWishlistEvent(
                                                                        productId:
                                                                            product
                                                                                .id,
                                                                        isWishlisted:
                                                                            product
                                                                                .isWishlisted,
                                                                      ),
                                                                    );
                                                              },
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                color: Colors.transparent,
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
                          const SizedBox(height: 30),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 265,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.read<ShopCategoryBloc>().add(FetchShopCategories());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Reload products',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    _initializeWishlistStatus();
  }

  @override
  void didUpdateWidget(_ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _initializeWishlistStatus();
    }
  }

  void _initializeWishlistStatus() {
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
        width: 280,
        margin: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          color: widget.bgColor,
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
                  const SizedBox(height: 20),
                  // Product Name - Adjusted styling as per USER request
                  SizedBox(
                    width: 150,
                    child: Text(
                      widget.product.name,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
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

            // Product Image (Right side) - Adjusted positioning as per USER request
            Positioned(
              right: -10,
              top: 20,
              bottom: 20,
              child: Container(
                width: 150,
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

            // Wishlist Icon
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

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 140,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 90,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 30,
              bottom: 30,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopScreenSkeleton extends StatelessWidget {
  const _ShopScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Bar Skeleton
              Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Banner Skeleton
              Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Categories Skeleton
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Product Section Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 265,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: _ProductCardSkeleton(),
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

