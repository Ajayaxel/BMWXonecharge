import 'package:equatable/equatable.dart';
import 'package:onecharge/models/cart_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartData cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartFailure extends CartState {
  final String error;

  const CartFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CartActionSuccess extends CartState {
  final String message;
  // Hold the previous cart state to avoid losing data while performing actions if needed
  // or just notify success.
  const CartActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckoutSuccess extends CartState {
  final Map<String, dynamic> data;

  const CheckoutSuccess(this.data);

  @override
  List<Object?> get props => [data];
}
