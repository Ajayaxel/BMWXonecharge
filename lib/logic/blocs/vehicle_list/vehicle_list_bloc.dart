import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:onecharge/logic/blocs/vehicle_list/vehicle_list_state.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  final VehicleRepository vehicleRepository;

  VehicleListBloc({required this.vehicleRepository})
    : super(const VehicleListInitial()) {
    on<FetchVehicles>(_onFetchVehicles);
    on<RemoveVehicleFromList>(_onRemoveVehicleFromList);
  }

  Future<void> _onFetchVehicles(
    FetchVehicles event,
    Emitter<VehicleListState> emit,
  ) async {
    // Prevent duplicate API calls if data already exists and forceRefresh is false
    if (!event.forceRefresh &&
        state is VehicleListLoaded &&
        state.vehicles.isNotEmpty) {
      return;
    }

    // Only show full loading if list is empty
    if (state.vehicles.isEmpty) {
      emit(VehicleListLoading(totalCount: state.totalCount));
    }

    try {
      final response = await vehicleRepository.getVehicles();
      emit(VehicleListLoaded(response.vehicles));
    } catch (e) {
      emit(
        VehicleListError(
          e.toString(),
          vehicles: state.vehicles,
          totalCount: state.totalCount,
        ),
      );
    }
  }

  void _onRemoveVehicleFromList(
    RemoveVehicleFromList event,
    Emitter<VehicleListState> emit,
  ) {
    if (state is VehicleListLoaded) {
      final updatedList = state.vehicles
          .where((v) => v.id != event.vehicleId)
          .toList();
      emit(VehicleListLoaded(updatedList, totalCount: updatedList.length));
    }
  }
}
