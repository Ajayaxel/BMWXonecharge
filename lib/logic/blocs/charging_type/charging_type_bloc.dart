import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/charging_type_repository.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_event.dart';
import 'package:onecharge/logic/blocs/charging_type/charging_type_state.dart';

class ChargingTypeBloc extends Bloc<ChargingTypeEvent, ChargingTypeState> {
  final ChargingTypeRepository chargingTypeRepository;

  ChargingTypeBloc({required this.chargingTypeRepository})
      : super(ChargingTypeInitial()) {
    on<FetchChargingTypes>((event, emit) async {
      emit(ChargingTypeLoading());
      try {
        final chargingTypes =
            await chargingTypeRepository.getChargingTypes();
        emit(ChargingTypeLoaded(chargingTypes));
      } catch (e) {
        emit(ChargingTypeError(e.toString()));
      }
    });
  }
}
