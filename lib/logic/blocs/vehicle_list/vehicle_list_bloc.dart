import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  final VehicleRepository vehicleRepository;

  VehicleListBloc({required this.vehicleRepository})
      : super(VehicleListInitial()) {
    on<FetchVehicles>(_onFetchVehicles);
  }

  Future<void> _onFetchVehicles(
    FetchVehicles event,
    Emitter<VehicleListState> emit,
  ) async {
    emit(VehicleListLoading());
    try {
      final response = await vehicleRepository.getVehicles();
      emit(VehicleListLoaded(response.vehicles));
    } catch (e) {
      emit(VehicleListError(e.toString()));
    }
  }
}
