import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/product/product_bloc.dart';
import 'package:onecharge/logic/blocs/product/product_state.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/models/product_model.dart';
import 'package:onecharge/screen/shop/product_detail_screen.dart';

class AllProductsScreen extends StatefulWidget {
  final String? title;
  final List<ProductModel>? products;

  const AllProductsScreen({super.key, this.title, this.products});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _selectedSort = 'Latest';
  List<ProductModel> _sortedProducts = [];
  bool _showAvailableOnly = false;

  final List<String> _sortOptions = [
    'Latest',
    'Popularity',
    'Price: Low → High',
    'Price: High → Low',
    'Rating',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.products != null) {
      _sortedProducts = List.from(widget.products!);
      _applySort();
    }
  }

  void _applySort() {
    setState(() {
      // First, get the baseline products (either from widget or BLoC result)
      // Note: this assumes we only sort the current view's list.
      List<ProductModel> baselineProducts = widget.products != null
          ? List.from(widget.products!)
          : (context.read<ProductBloc>().state is ProductLoaded
              ? List.from((context.read<ProductBloc>().state as ProductLoaded).data.data)
              : []);

      if (baselineProducts.isEmpty) return;

      // Filter by availability if toggled
      if (_showAvailableOnly) {
        baselineProducts = baselineProducts.where((p) => p.stock > 0).toList();
      }

      switch (_selectedSort) {
        case 'Price: Low → High':
          baselineProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High → Low':
          baselineProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Latest':
          baselineProducts.sort((a, b) {
            if (a.createdAt != null && b.createdAt != null) {
              return b.createdAt!.compareTo(a.createdAt!);
            }
            return b.id.compareTo(a.id);
          });
          break;
        case 'Popularity':
          baselineProducts.sort((a, b) => b.id.compareTo(a.id));
          break;
        case 'Rating':
          // Proxy sort by name for now
          baselineProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
      }
      _sortedProducts = baselineProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'All Products',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lufga',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () => _showFilterBottomSheet(),
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.products != null
                ? _buildProductGrid(_sortedProducts)
                : BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ProductLoaded) {
                        final allProducts = state.data.data;
                        if (allProducts.isEmpty) {
                          return const Center(child: Text('No products found'));
                        }
                        // Initialize if empty or if we need to update due to BLoC reload
                        if (_sortedProducts.isEmpty && allProducts.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _applySort();
                          });
                        }
                        return _buildProductGrid(_sortedProducts);
                      } else if (state is ProductFailure) {
                        return Center(child: Text('Error: ${state.error}'));
                      }
                      return const Center(child: Text('Something went wrong'));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lufga',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedSort = 'Latest';
                              _showAvailableOnly = false;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lufga',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sort By',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lufga',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _sortOptions.map((option) {
                              final isSelected = _selectedSort == option;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedSort = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF1B1B1B) : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF374151),
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontFamily: 'Lufga',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Availability',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lufga',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Show In Stock Only',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                                fontFamily: 'Lufga',
                              ),
                            ),
                            value: _showAvailableOnly,
                            activeColor: const Color(0xFF1B1B1B),
                            onChanged: (value) {
                              setModalState(() {
                                _showAvailableOnly = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: () {
                        _applySort();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B1B1B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(18),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductGridCard(product: products[index]);
      },
    );
  }
}

class ProductGridCard extends StatefulWidget {
  final ProductModel product;

  const ProductGridCard({super.key, required this.product});

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
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
          current.error != null && current.loadingProductId == widget.product.id,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: widget.product.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: widget.product.mainImage.isNotEmpty
                              ? Image.network(widget.product.mainImage, fit: BoxFit.contain)
                              : const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
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
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  color: isWishlisted ? Colors.red : Colors.black,
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
              Padding(
                padding: const EdgeInsets.all(12),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product.currency} ${widget.product.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lufga',
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
