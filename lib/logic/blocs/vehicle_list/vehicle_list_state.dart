import 'package:equatable/equatable.dart';
import 'package:onecharge/models/vehicle_list_model.dart';

abstract class VehicleListState extends Equatable {
  final List<VehicleListItem> vehicles;
  final int totalCount;

  const VehicleListState({this.vehicles = const [], this.totalCount = 0});

  @override
  List<Object> get props => [vehicles, totalCount];
}

class VehicleListInitial extends VehicleListState {
  const VehicleListInitial() : super();
}

class VehicleListLoading extends VehicleListState {
  const VehicleListLoading({super.vehicles, super.totalCount});
}

class VehicleListLoaded extends VehicleListState {
  const VehicleListLoaded(List<VehicleListItem> vehicles, {int? totalCount})
    : super(vehicles: vehicles, totalCount: totalCount ?? vehicles.length);
}

class VehicleListError extends VehicleListState {
  final String message;

  const VehicleListError(this.message, {super.vehicles, super.totalCount});

  @override
  List<Object> get props => [message, vehicles, totalCount];
}
