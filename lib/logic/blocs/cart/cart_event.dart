import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class FetchCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final int productId;
  final int quantity;

  const AddToCartEvent({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final int productId;

  const RemoveFromCartEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQuantityEvent extends CartEvent {
  final int productId;
  final int quantity;

  const UpdateCartQuantityEvent({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class CheckoutEvent extends CartEvent {
  final Map<String, dynamic> checkoutData;

  const CheckoutEvent({required this.checkoutData});

  @override
  List<Object?> get props => [checkoutData];
}
