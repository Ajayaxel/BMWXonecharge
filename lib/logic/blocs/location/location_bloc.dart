import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/location_repository.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
import 'package:onecharge/models/location_model.dart';

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
    final currentState = state;
    List<LocationModel> currentLocations = [];
    if (currentState is LocationsLoaded) {
      currentLocations = List.from(currentState.locations);
    }

    emit(LocationLoading());
    try {
      final newLocation = await repository.addLocation(event.location);
      emit(LocationAdded(newLocation));
      // Locally update the list instead of fetching from server
      currentLocations.add(newLocation);
      emit(LocationsLoaded(currentLocations));
    } catch (e) {
      emit(LocationError(e.toString()));
      // Restore previous state on error
      if (currentLocations.isNotEmpty) {
        emit(LocationsLoaded(currentLocations));
      }
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    List<LocationModel> currentLocations = [];
    if (currentState is LocationsLoaded) {
      currentLocations = List.from(currentState.locations);
    }

    emit(LocationLoading());
    try {
      await repository.deleteLocation(event.locationId);
      emit(LocationDeleted());
      // Locally update the list instead of fetching from server
      currentLocations.removeWhere((loc) => loc.id == event.locationId);
      emit(LocationsLoaded(currentLocations));
    } catch (e) {
      emit(LocationError(e.toString()));
      // Restore previous state on error
      if (currentLocations.isNotEmpty) {
        emit(LocationsLoaded(currentLocations));
      }
    }
  }
}
