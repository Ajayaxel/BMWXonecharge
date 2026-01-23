import 'package:equatable/equatable.dart';

abstract class VehicleListEvent extends Equatable {
  const VehicleListEvent();

  @override
  List<Object> get props => [];
}

class FetchVehicles extends VehicleListEvent {}
