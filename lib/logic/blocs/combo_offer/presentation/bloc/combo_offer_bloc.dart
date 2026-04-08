import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/combo_offer_repository.dart';
import 'combo_offer_event.dart';
import 'combo_offer_state.dart';

class ComboOfferBloc extends Bloc<ComboOfferEvent, ComboOfferState> {
  final ComboOfferRepository repository;

  ComboOfferBloc({required this.repository}) : super(ComboOfferInitial()) {
    on<FetchComboOffers>((event, emit) async {
      emit(ComboOfferLoading());
      try {
        final response = await repository.getComboOffers();
        emit(ComboOfferLoaded(response.data));
      } catch (e) {
        emit(ComboOfferError(e.toString()));
      }
    });
  }
}
