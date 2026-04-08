import 'package:equatable/equatable.dart';
import '../../data/models/combo_offer_model.dart';

abstract class ComboOfferState extends Equatable {
  const ComboOfferState();

  @override
  List<Object?> get props => [];
}

class ComboOfferInitial extends ComboOfferState {}

class ComboOfferLoading extends ComboOfferState {}

class ComboOfferLoaded extends ComboOfferState {
  final List<ComboOfferModel> comboOffers;

  const ComboOfferLoaded(this.comboOffers);

  @override
  List<Object?> get props => [comboOffers];
}

class ComboOfferError extends ComboOfferState {
  final String message;

  const ComboOfferError(this.message);

  @override
  List<Object?> get props => [message];
}
