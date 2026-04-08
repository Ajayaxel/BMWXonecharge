import 'package:equatable/equatable.dart';
import '../../data/models/combo_purchase_model.dart';

abstract class ComboPurchaseState extends Equatable {
  const ComboPurchaseState();

  @override
  List<Object?> get props => [];
}

class ComboPurchaseInitial extends ComboPurchaseState {}

class ComboPurchaseLoading extends ComboPurchaseState {}

class ComboPurchaseSuccess extends ComboPurchaseState {
  final ComboPurchaseResponse response;

  const ComboPurchaseSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class ComboPurchaseFailure extends ComboPurchaseState {
  final String error;

  const ComboPurchaseFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
