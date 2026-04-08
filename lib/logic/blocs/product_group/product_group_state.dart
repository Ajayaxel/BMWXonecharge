import 'package:equatable/equatable.dart';
import '../../../../models/product_group_model.dart';

abstract class ProductGroupState extends Equatable {
  const ProductGroupState();

  @override
  List<Object?> get props => [];
}

class ProductGroupInitial extends ProductGroupState {}

class ProductGroupLoading extends ProductGroupState {}

class ProductGroupLoaded extends ProductGroupState {
  final List<ProductGroupModel> productGroups;

  const ProductGroupLoaded(this.productGroups);

  @override
  List<Object?> get props => [productGroups];
}

class ProductGroupError extends ProductGroupState {
  final String message;

  const ProductGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
