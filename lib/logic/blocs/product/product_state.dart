import 'package:onecharge/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final ProductPaginationData data;
  ProductLoaded({required this.data});
}

class ProductFailure extends ProductState {
  final String error;
  ProductFailure({required this.error});
}
