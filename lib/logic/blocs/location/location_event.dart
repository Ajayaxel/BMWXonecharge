import 'package:equatable/equatable.dart';
import 'package:onecharge/models/location_model.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class FetchLocations extends LocationEvent {}

class AddLocation extends LocationEvent {
  final LocationModel location;

  const AddLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class DeleteLocation extends LocationEvent {
  final int locationId;

  const DeleteLocation(this.locationId);

  @override
  List<Object?> get props => [locationId];
}
