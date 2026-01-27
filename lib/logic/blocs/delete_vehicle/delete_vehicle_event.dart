import 'package:equatable/equatable.dart';

abstract class DeleteVehicleEvent extends Equatable {
  const DeleteVehicleEvent();

  @override
  List<Object> get props => [];
}

class DeleteVehicleRequested extends DeleteVehicleEvent {
  final int vehicleId;

  const DeleteVehicleRequested(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}
