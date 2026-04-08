import 'package:equatable/equatable.dart';

abstract class ComboOfferEvent extends Equatable {
  const ComboOfferEvent();

  @override
  List<Object?> get props => [];
}

class FetchComboOffers extends ComboOfferEvent {}
