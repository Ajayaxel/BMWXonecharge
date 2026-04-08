import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/combo_offer_repository.dart';
import 'combo_purchase_event.dart';
import 'combo_purchase_state.dart';

class ComboPurchaseBloc extends Bloc<ComboPurchaseEvent, ComboPurchaseState> {
  final ComboOfferRepository repository;

  ComboPurchaseBloc({required this.repository}) : super(ComboPurchaseInitial()) {
    on<PurchaseComboOfferRequested>((event, emit) async {
      emit(ComboPurchaseLoading());
      try {
        final response = await repository.purchaseComboOffer(event.request);
        emit(ComboPurchaseSuccess(response: response));
      } catch (e) {
        emit(ComboPurchaseFailure(error: e.toString()));
      }
    });
  }
}
