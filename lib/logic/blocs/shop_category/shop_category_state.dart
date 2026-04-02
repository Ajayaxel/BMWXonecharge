import 'package:equatable/equatable.dart';
import 'package:onecharge/models/product_model.dart';

abstract class ShopCategoryState extends Equatable {
  const ShopCategoryState();

  @override
  List<Object?> get props => [];
}

class ShopCategoryInitial extends ShopCategoryState {}

class ShopCategoryLoading extends ShopCategoryState {}

class ShopCategoryLoaded extends ShopCategoryState {
  final List<ShopCategoryModel> categories;

  const ShopCategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class ShopCategoryFailure extends ShopCategoryState {
  final String error;

  const ShopCategoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}
