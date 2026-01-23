import 'package:equatable/equatable.dart';
import 'package:onecharge/models/vehicle_list_model.dart';

abstract class VehicleListState extends Equatable {
  const VehicleListState();

  @override
  List<Object> get props => [];
}

class VehicleListInitial extends VehicleListState {}

class VehicleListLoading extends VehicleListState {}

class VehicleListLoaded extends VehicleListState {
  final List<VehicleListItem> vehicles;

  const VehicleListLoaded(this.vehicles);

  @override
  List<Object> get props => [vehicles];
}

class VehicleListError extends VehicleListState {
  final String message;

  const VehicleListError(this.message);

  @override
  List<Object> get props => [message];
}
