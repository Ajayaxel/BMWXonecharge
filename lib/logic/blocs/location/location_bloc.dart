import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/location_repository.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository}) : super(LocationInitial()) {
    on<FetchLocations>(_onFetchLocations);
    on<AddLocation>(_onAddLocation);
    on<DeleteLocation>(_onDeleteLocation);
  }

  Future<void> _onFetchLocations(
    FetchLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final locations = await repository.getLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final newLocation = await repository.addLocation(event.location);
      emit(LocationAdded(newLocation));
      // Refresh the list after adding
      add(FetchLocations());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      await repository.deleteLocation(event.locationId);
      emit(LocationDeleted());
      // Refresh the list after deleting
      add(FetchLocations());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
