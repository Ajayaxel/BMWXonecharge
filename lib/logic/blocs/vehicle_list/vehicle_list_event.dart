import 'package:equatable/equatable.dart';

abstract class VehicleListEvent extends Equatable {
  const VehicleListEvent();

  @override
  List<Object> get props => [];
}

class FetchVehicles extends VehicleListEvent {
  final bool forceRefresh;
  const FetchVehicles({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class RemoveVehicleFromList extends VehicleListEvent {
  final int vehicleId;
  const RemoveVehicleFromList(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}
