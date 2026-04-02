abstract class ProductEvent {}

class FetchProductsEvent extends ProductEvent {
  final int page;
  FetchProductsEvent({this.page = 1});
}
