import 'package:equatable/equatable.dart';
import 'package:onecharge/models/add_vehicle_model.dart';

abstract class AddVehicleEvent extends Equatable {
  const AddVehicleEvent();

  @override
  List<Object> get props => [];
}

class AddVehicleRequested extends AddVehicleEvent {
  final AddVehicleRequest request;

  const AddVehicleRequested(this.request);

  @override
  List<Object> get props => [request];
}
