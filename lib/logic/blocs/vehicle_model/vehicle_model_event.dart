import 'package:equatable/equatable.dart';

abstract class VehicleModelEvent extends Equatable {
  const VehicleModelEvent();

  @override
  List<Object?> get props => [];
}

class FetchVehicleModels extends VehicleModelEvent {}
