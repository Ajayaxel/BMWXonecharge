import 'package:equatable/equatable.dart';

abstract class ShopCategoryEvent extends Equatable {
  const ShopCategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchShopCategories extends ShopCategoryEvent {}
