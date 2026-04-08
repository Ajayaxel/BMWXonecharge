import 'package:equatable/equatable.dart';

abstract class ProductGroupEvent extends Equatable {
  const ProductGroupEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductGroups extends ProductGroupEvent {}
