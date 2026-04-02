import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class InitializeProductWishlistStatusEvent extends WishlistEvent {
  final int productId;
  final bool isWishlisted;

  const InitializeProductWishlistStatusEvent({
    required this.productId,
    required this.isWishlisted,
  });

  @override
  List<Object?> get props => [productId, isWishlisted];
}

class ToggleWishlistEvent extends WishlistEvent {
  final int productId;

  const ToggleWishlistEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}
