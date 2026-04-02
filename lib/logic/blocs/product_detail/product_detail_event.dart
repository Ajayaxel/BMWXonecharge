abstract class ProductDetailEvent {}

class FetchProductDetailEvent extends ProductDetailEvent {
  final int productId;
  FetchProductDetailEvent(this.productId);
}
