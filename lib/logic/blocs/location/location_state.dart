import 'package:equatable/equatable.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/models/location_config_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationsLoaded extends LocationState {
  final List<LocationModel> locations;
  final LocationModel? selectedLocation;

  const LocationsLoaded(this.locations, {this.selectedLocation});

  @override
  List<Object?> get props => [locations, selectedLocation];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationAdded extends LocationState {
  final LocationModel location;

  const LocationAdded(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationDeleted extends LocationState {}

class LocationConfigLoaded extends LocationState {
  final LocationConfigResponse config;

  const LocationConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}
