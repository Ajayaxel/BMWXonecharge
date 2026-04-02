import 'package:equatable/equatable.dart';

class WishlistState extends Equatable {
  final Map<int, bool> wishlistMap;
  final int? loadingProductId;
  final String? error;
  final String? message;

  const WishlistState({
    this.wishlistMap = const {},
    this.loadingProductId,
    this.error,
    this.message,
  });

  WishlistState copyWith({
    Map<int, bool>? wishlistMap,
    int? loadingProductId,
    String? error,
    String? message,
  }) {
    return WishlistState(
      wishlistMap: wishlistMap ?? this.wishlistMap,
      loadingProductId: loadingProductId,
      error: error,
      message: message,
    );
  }

  @override
  List<Object?> get props => [wishlistMap, loadingProductId, error, message];
}
