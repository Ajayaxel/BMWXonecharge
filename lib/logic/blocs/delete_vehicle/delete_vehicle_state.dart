import 'package:equatable/equatable.dart';

abstract class DeleteVehicleState extends Equatable {
  const DeleteVehicleState();

  @override
  List<Object> get props => [];
}

class DeleteVehicleInitial extends DeleteVehicleState {}

class DeleteVehicleLoading extends DeleteVehicleState {}

class DeleteVehicleSuccess extends DeleteVehicleState {}

class DeleteVehicleError extends DeleteVehicleState {
  final String message;

  const DeleteVehicleError(this.message);

  @override
  List<Object> get props => [message];
}
