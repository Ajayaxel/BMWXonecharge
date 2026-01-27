import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_event.dart';
import 'package:onecharge/logic/blocs/delete_vehicle/delete_vehicle_state.dart';

class DeleteVehicleBloc extends Bloc<DeleteVehicleEvent, DeleteVehicleState> {
  final VehicleRepository vehicleRepository;

  DeleteVehicleBloc({required this.vehicleRepository})
    : super(DeleteVehicleInitial()) {
    on<DeleteVehicleRequested>(_onDeleteVehicleRequested);
  }

  Future<void> _onDeleteVehicleRequested(
    DeleteVehicleRequested event,
    Emitter<DeleteVehicleState> emit,
  ) async {
    emit(DeleteVehicleLoading());
    try {
      await vehicleRepository.deleteVehicle(event.vehicleId);
      emit(DeleteVehicleSuccess());
    } catch (e) {
      emit(DeleteVehicleError(e.toString()));
    }
  }
}
