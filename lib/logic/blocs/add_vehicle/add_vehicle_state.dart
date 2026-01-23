import 'package:equatable/equatable.dart';
import 'package:onecharge/models/add_vehicle_model.dart';

abstract class AddVehicleState extends Equatable {
  const AddVehicleState();

  @override
  List<Object> get props => [];
}

class AddVehicleInitial extends AddVehicleState {}

class AddVehicleLoading extends AddVehicleState {}

class AddVehicleSuccess extends AddVehicleState {
  final AddVehicleResponse response;

  const AddVehicleSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class AddVehicleError extends AddVehicleState {
  final String message;

  const AddVehicleError(this.message);

  @override
  List<Object> get props => [message];
}
