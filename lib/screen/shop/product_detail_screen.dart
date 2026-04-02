import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/product_detail/product_detail_bloc.dart';
import 'package:onecharge/logic/blocs/product_detail/product_detail_event.dart';
import 'package:onecharge/logic/blocs/product_detail/product_detail_state.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_bloc.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_event.dart';
import 'package:onecharge/logic/blocs/wishlist/wishlist_state.dart';
import 'package:onecharge/logic/blocs/cart/cart_bloc.dart';
import 'package:onecharge/logic/blocs/cart/cart_event.dart';
import 'package:onecharge/logic/blocs/cart/cart_state.dart';
import 'package:onecharge/models/product_model.dart';
import 'package:onecharge/screen/shop/cart_screen.dart';
import 'package:onecharge/utils/toast_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedTab = 0; // 0 for Description, 1 for Key Features
  int _quantity = 1;
  int _currentImageIndex = 0;

  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _btnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailBloc>().add(
      FetchProductDetailEvent(widget.productId),
    );
  }

  String _getImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://app.onecharge.io/storage/$path';
  }

  void _runAddToCartAnimation(String imageUrl) {
    if (_cartKey.currentContext == null || _btnKey.currentContext == null) {
      return;
    }

    final RenderBox cartBox =
        _cartKey.currentContext!.findRenderObject() as RenderBox;
    final Offset cartOffset = cartBox.localToGlobal(Offset.zero);

    final RenderBox buttonBox =
        _btnKey.currentContext!.findRenderObject() as RenderBox;
    final Offset startOffset = buttonBox.localToGlobal(
      Offset(buttonBox.size.width / 2, 0),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _FlyingItemAnimation(
          startOffset: startOffset,
          endOffset: Offset(cartOffset.dx + 5, cartOffset.dy + 5),
          imageUrl: imageUrl,
          onEnd: () {
            entry.remove();
          },
        );
      },
    );

    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state is ProductDetailLoaded) {
              final product = state.product;
              final images = product.images ?? [];
              final mainImageUrl = images.isNotEmpty
                  ? _getImageUrl(images[_currentImageIndex].path)
                  : _getImageUrl(product.image ?? '');

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildHeader(context, product),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image Box
                          Container(
                            height: 330,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              color: Colors.grey.shade200.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            child: Container(
                              height: 250,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                color: const Color(
                                  0xFFE9EEEC,
                                ).withValues(alpha: 0.9),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // Main Image
                                  Center(
                                    child: Hero(
                                      tag: 'product_${product.id}',
                                      child: mainImageUrl.isNotEmpty
                                          ? Image.network(
                                              mainImageUrl,
                                              height: 250,
                                              width: 250,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image_not_supported,
                                                    size: 100,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  // Thumbnail Overlay
                                  Positioned(
                                    bottom: 15,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _buildThumbnails(
                                            images,
                                            product.image,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Title and Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.shortDescription,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${product.currency} ${product.price}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tabs and Quantity Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tabs
                              Row(
                                children: [
                                  _buildTab("Description", 0),
                                  _buildTab("Key Features", 1),
                                ],
                              ),
                              // Quantity Selector
                              _buildQuantitySelector(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Tab Content
                          _buildTabContent(product),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Bar
                  _buildBottomBar(product, mainImageUrl),
                ],
              );
            } else if (state is ProductDetailFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductDetailBloc>().add(
                          FetchProductDetailEvent(widget.productId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Click a product to see details'));
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProductModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        const Text(
          "Product Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            _WishlistButton(product: product),
            const SizedBox(width: 15),
            GestureDetector(
              key: _cartKey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 24,
                    color: Colors.black,
                  ),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded && state.cart.totalCount > 0) {
                        return Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${state.cart.totalCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildThumbnails(
    List<ProductImageModel> images,
    String? fallbackImg,
  ) {
    List<Widget> thumbWidgets = [];

    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        bool isSelected = _currentImageIndex == i;
        thumbWidgets.add(
          _thumbnailItem(
            images[i].path,
            isSelected,
            () => setState(() => _currentImageIndex = i),
          ),
        );
      }
    } else if (fallbackImg != null && fallbackImg.isNotEmpty) {
      thumbWidgets.add(_thumbnailItem(fallbackImg, true, () {}));
    }

    return thumbWidgets;
  }

  Widget _thumbnailItem(String path, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.black, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _getImageUrl(path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.image, size: 24, color: Colors.grey.shade400),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }, false),
          const SizedBox(width: 12),
          Text(
            "$_quantity",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          _qtyBtn(Icons.add, () => setState(() => _quantity++), true),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isPrimary) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.black : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isPrimary ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTabContent(ProductModel product) {
    if (_selectedTab == 0) {
      return Text(
        product.description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      );
    } else {
      List<String> features = [];
      if (product.keyFeature != null && product.keyFeature!.isNotEmpty) {
        features = product.keyFeature!
            .split(RegExp(r'\r\n|\n'))
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.shortDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.shortDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (features.isNotEmpty)
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bolt, size: 18, color: Colors.orangeAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (features.isEmpty && product.shortDescription.isEmpty)
            const Text(
              "No additional features listed for this product.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      );
    }
  }

  Widget _buildBottomBar(ProductModel product, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Buy Now",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocListener<CartBloc, CartState>(
              listener: (context, state) {
                if (state is CartActionSuccess) {
                  ToastUtils.showToast(context, state.message);
                } else if (state is CartFailure) {
                  ToastUtils.showToast(context, state.error, isError: true);
                }
              },
              child: ElevatedButton(
                key: _btnKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _runAddToCartAnimation(imageUrl);
                  context.read<CartBloc>().add(
                    AddToCartEvent(productId: product.id, quantity: _quantity),
                  );
                },
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistButton extends StatefulWidget {
  final ProductModel product;
  const _WishlistButton({required this.product});

  @override
  State<_WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<_WishlistButton> {
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
      child: BlocSelector<WishlistBloc, WishlistState, bool>(
        selector: (state) =>
            state.wishlistMap[widget.product.id] ?? widget.product.isWishlisted,
        builder: (context, isWishlisted) {
          return GestureDetector(
            onTap: () {
              context.read<WishlistBloc>().add(
                ToggleWishlistEvent(productId: widget.product.id),
              );
            },
            child: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.black,
              size: 22,
            ),
          );
        },
      ),
    );
  }
}

class _FlyingItemAnimation extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String imageUrl;
  final VoidCallback onEnd;

  const _FlyingItemAnimation({
    required this.startOffset,
    required this.endOffset,
    required this.imageUrl,
    required this.onEnd,
  });

  @override
  State<_FlyingItemAnimation> createState() => _FlyingItemAnimationState();
}

class _FlyingItemAnimationState extends State<_FlyingItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _positionAnimation =
        Tween<Offset>(begin: widget.startOffset, end: widget.endOffset).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
        );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.2), weight: 70),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onEnd());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 25,
          top: _positionAnimation.value.dy - 25,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.shopping_cart, size: 20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
