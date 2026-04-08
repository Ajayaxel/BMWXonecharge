import 'package:equatable/equatable.dart';
import '../../data/models/combo_purchase_model.dart';

abstract class ComboPurchaseEvent extends Equatable {
  const ComboPurchaseEvent();

  @override
  List<Object?> get props => [];
}

class PurchaseComboOfferRequested extends ComboPurchaseEvent {
  final ComboPurchaseRequest request;

  const PurchaseComboOfferRequested({required this.request});

  @override
  List<Object?> get props => [request];
}
