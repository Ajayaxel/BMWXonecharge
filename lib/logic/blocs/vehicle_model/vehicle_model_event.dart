import 'package:equatable/equatable.dart';

abstract class VehicleModelEvent extends Equatable {
  const VehicleModelEvent();

  @override
  List<Object?> get props => [];
}

class FetchVehicleModels extends VehicleModelEvent {
  final bool isRefresh;
  const FetchVehicleModels({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreVehicleModels extends VehicleModelEvent {}
