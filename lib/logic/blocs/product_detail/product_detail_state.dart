import 'package:onecharge/models/product_model.dart';

abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;
  ProductDetailLoaded(this.product);
}

class ProductDetailFailure extends ProductDetailState {
  final String error;
  ProductDetailFailure(this.error);
}
