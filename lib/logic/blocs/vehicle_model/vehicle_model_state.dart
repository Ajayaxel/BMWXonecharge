import 'package:equatable/equatable.dart';
import 'package:onecharge/models/vehicle_model.dart';

abstract class VehicleModelState extends Equatable {
  const VehicleModelState();

  @override
  List<Object?> get props => [];
}

class VehicleModelInitial extends VehicleModelState {}

class VehicleModelLoading extends VehicleModelState {}

class VehicleModelLoaded extends VehicleModelState {
  final List<VehicleModel> models;

  const VehicleModelLoaded(this.models);

  @override
  List<Object?> get props => [models];
}

class VehicleModelError extends VehicleModelState {
  final String message;

  const VehicleModelError(this.message);

  @override
  List<Object?> get props => [message];
}
