import 'package:equatable/equatable.dart';
import 'package:onecharge/models/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationsLoaded extends LocationState {
  final List<LocationModel> locations;

  const LocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
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
