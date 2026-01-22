import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'vehicle_model_event.dart';
import 'vehicle_model_state.dart';

class VehicleModelBloc extends Bloc<VehicleModelEvent, VehicleModelState> {
  final VehicleRepository vehicleRepository;

  VehicleModelBloc({required this.vehicleRepository})
    : super(VehicleModelInitial()) {
    on<FetchVehicleModels>((event, emit) async {
      emit(VehicleModelLoading());
      try {
        final models = await vehicleRepository.getModels();
        emit(VehicleModelLoaded(models));
      } catch (e) {
        emit(VehicleModelError(e.toString()));
      }
    });
  }
}
