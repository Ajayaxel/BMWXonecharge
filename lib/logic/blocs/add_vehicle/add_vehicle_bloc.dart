import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/vehicle_repository.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_event.dart';
import 'package:onecharge/logic/blocs/add_vehicle/add_vehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  final VehicleRepository vehicleRepository;

  AddVehicleBloc({required this.vehicleRepository})
      : super(AddVehicleInitial()) {
    on<AddVehicleRequested>(_onAddVehicleRequested);
  }

  Future<void> _onAddVehicleRequested(
    AddVehicleRequested event,
    Emitter<AddVehicleState> emit,
  ) async {
    emit(AddVehicleLoading());
    try {
      final response = await vehicleRepository.addVehicle(event.request);
      
      // Print the API response to console
      print('✅ [AddVehicleBloc] Vehicle added successfully!');
      print('📦 [AddVehicleBloc] Response: ${response.message}');
      print('🚗 [AddVehicleBloc] Vehicle ID: ${response.data.id}');
      print('🔢 [AddVehicleBloc] Vehicle Number: ${response.data.vehicleNumber}');
      print('🏷️ [AddVehicleBloc] Vehicle Type: ${response.data.vehicleType?.name ?? 'N/A'}');
      print('🏭 [AddVehicleBloc] Brand: ${response.data.brand?.name ?? 'N/A'}');
      print('🚙 [AddVehicleBloc] Model: ${response.data.model?.name ?? 'N/A'}');
      print('⚡ [AddVehicleBloc] Charging Type: ${response.data.chargingType?.name ?? 'N/A'}');
      print('📅 [AddVehicleBloc] Created At: ${response.data.createdAt}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      emit(AddVehicleSuccess(response));
    } catch (e) {
      print('❌ [AddVehicleBloc] Error adding vehicle: $e');
      emit(AddVehicleError(e.toString()));
    }
  }
}
