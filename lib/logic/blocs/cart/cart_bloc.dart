import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/product_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';
export 'cart_event.dart';
export 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ProductRepository productRepository;

  CartBloc({required this.productRepository}) : super(CartInitial()) {
    on<FetchCartEvent>(_onFetchCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartQuantityEvent>(_onUpdateCartQuantity);
    on<CheckoutEvent>(_onCheckout);
  }

  Future<void> _onFetchCart(FetchCartEvent event, Emitter<CartState> emit) async {
    // Only show loading if we are NOT already in a loaded or success state
    // Or if the event explicitly asks for it (could naturally be default)
    if (state is! CartLoaded && state is! CartActionSuccess) {
      emit(CartLoading());
    }
    
    await _fetchCartItems(emit);
  }

  Future<void> _fetchCartItems(Emitter<CartState> emit) async {
    try {
      final response = await productRepository.getCart();
      emit(CartLoaded(response.data));
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      final success = await productRepository.addToCart(event.productId, event.quantity);
      if (success) {
        emit(const CartActionSuccess('Added to cart'));
        await _fetchCartItems(emit);
      } else {
        emit(const CartFailure('Failed to add to cart'));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final success = await productRepository.removeFromCart(event.productId);
      if (success) {
        emit(const CartActionSuccess('Removed from cart'));
        await _fetchCartItems(emit);
      } else {
        emit(const CartFailure('Failed to remove from cart'));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final success = await productRepository.updateCartQuantity(
        event.productId,
        event.quantity,
      );
      if (success) {
        // Just refresh the cart items silently
        await _fetchCartItems(emit);
      } else {
        emit(const CartFailure('Failed to update cart quantity'));
      }
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

  Future<void> _onCheckout(CheckoutEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final data = await productRepository.checkout(event.checkoutData);
      emit(CheckoutSuccess(data));
      // Refresh the cart data so that if the user returns (e.g. cancels payment),
      // the cart items are still visible and up to date.
      await _fetchCartItems(emit);
    } catch (e) {
      emit(CartFailure(e.toString()));
      // Refresh the cart even on failure to restore the Loaded state
      await _fetchCartItems(emit);
    }
  }
}
