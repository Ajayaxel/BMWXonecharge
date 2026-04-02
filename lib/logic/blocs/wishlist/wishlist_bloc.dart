import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final ProductRepository productRepository;

  WishlistBloc({required this.productRepository}) : super(const WishlistState()) {
    on<InitializeProductWishlistStatusEvent>(_onInitializeStatus);
    on<ToggleWishlistEvent>(_onToggleWishlist);
  }

  void _onInitializeStatus(
    InitializeProductWishlistStatusEvent event,
    Emitter<WishlistState> emit,
  ) {
    // Only initialize if we haven't seen this product yet, to avoid overwriting changes
    if (!state.wishlistMap.containsKey(event.productId)) {
      final newMap = Map<int, bool>.from(state.wishlistMap);
      newMap[event.productId] = event.isWishlisted;
      emit(state.copyWith(wishlistMap: newMap));
    }
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final bool currentlyInWishlist = state.wishlistMap[event.productId] ?? false;
    
    // Optimistically update the UI
    final optimisticMap = Map<int, bool>.from(state.wishlistMap);
    optimisticMap[event.productId] = !currentlyInWishlist;
    emit(state.copyWith(
      wishlistMap: optimisticMap,
      loadingProductId: event.productId,
      error: null,
      message: null,
    ));

    try {
      bool success;
      if (currentlyInWishlist) {
        success = await productRepository.removeFromWishlist(event.productId);
      } else {
        success = await productRepository.addToWishlist(event.productId);
      }

      if (success) {
        emit(state.copyWith(
          loadingProductId: null,
          message: currentlyInWishlist ? 'Removed from wishlist' : 'Added to wishlist',
        ));
      } else {
        // Revert optimistic update
        final revertedMap = Map<int, bool>.from(state.wishlistMap);
        revertedMap[event.productId] = currentlyInWishlist;
        emit(state.copyWith(
          wishlistMap: revertedMap,
          loadingProductId: null,
          error: 'Failed to update wishlist',
        ));
      }
    } catch (e) {
      // Revert optimistic update
      final revertedMap = Map<int, bool>.from(state.wishlistMap);
      revertedMap[event.productId] = currentlyInWishlist;
      emit(state.copyWith(
        wishlistMap: revertedMap,
        loadingProductId: null,
        error: e.toString(),
      ));
    }
  }
}
