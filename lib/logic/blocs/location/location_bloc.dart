import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/location_repository.dart';
import 'package:onecharge/logic/blocs/location/location_event.dart';
import 'package:onecharge/logic/blocs/location/location_state.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/core/storage/secure_storage_service.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;
  final SecureStorageService storage;

  LocationBloc({required this.repository, required this.storage}) : super(LocationInitial()) {
    on<FetchLocations>(_onFetchLocations);
    on<FetchLocationConfig>(_onFetchLocationConfig);
    on<AddLocation>(_onAddLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<SelectLocation>(_onSelectLocation);
    on<LoadSelectedLocation>(_onLoadSelectedLocation);
  }

  Future<void> _onFetchLocations(
    FetchLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final locations = await repository.getLocations();
      
      // Try to load stored selection
      LocationModel? storedSelection;
      final storedJson = await storage.getSelectedLocation();
      if (storedJson != null) {
        try {
          storedSelection = LocationModel.fromJson(jsonDecode(storedJson));
        } catch (_) {}
      }

      emit(LocationsLoaded(locations, selectedLocation: storedSelection));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onFetchLocationConfig(
    FetchLocationConfig event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final config = await repository.getLocationConfig();
      emit(LocationConfigLoaded(config));
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
    LocationModel? currentSelected;
    if (currentState is LocationsLoaded) {
      currentLocations = List.from(currentState.locations);
      currentSelected = currentState.selectedLocation;
    }

    emit(LocationLoading());
    try {
      final newLocation = await repository.addLocation(event.location);
      emit(LocationAdded(newLocation));
      // Locally update the list instead of fetching from server
      currentLocations.add(newLocation);
      emit(LocationsLoaded(currentLocations, selectedLocation: currentSelected));
    } catch (e) {
      emit(LocationError(e.toString()));
      // Restore previous state on error
      if (currentLocations.isNotEmpty) {
        emit(LocationsLoaded(currentLocations, selectedLocation: currentSelected));
      }
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    List<LocationModel> currentLocations = [];
    LocationModel? currentSelected;
    if (currentState is LocationsLoaded) {
      currentLocations = List.from(currentState.locations);
      currentSelected = currentState.selectedLocation;
    }

    emit(LocationLoading());
    try {
      await repository.deleteLocation(event.locationId);
      emit(LocationDeleted());
      
      // If deleted location was the selected one, clear it
      if (currentSelected?.id == event.locationId) {
        currentSelected = null;
        await storage.saveSelectedLocation("");
      }

      currentLocations.removeWhere((loc) => loc.id == event.locationId);
      emit(LocationsLoaded(currentLocations, selectedLocation: currentSelected));
    } catch (e) {
      emit(LocationError(e.toString()));
      // Restore previous state on error
      if (currentLocations.isNotEmpty) {
        emit(LocationsLoaded(currentLocations, selectedLocation: currentSelected));
      }
    }
  }

  Future<void> _onSelectLocation(
    SelectLocation event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    if (currentState is LocationsLoaded) {
      // Save to storage
      await storage.saveSelectedLocation(jsonEncode(event.location.toJson()));
      
      emit(LocationsLoaded(
        currentState.locations,
        selectedLocation: event.location,
      ));
    }
  }

  Future<void> _onLoadSelectedLocation(
    LoadSelectedLocation event,
    Emitter<LocationState> emit,
  ) async {
    final storedJson = await storage.getSelectedLocation();
    if (storedJson != null && storedJson.isNotEmpty) {
      try {
        final location = LocationModel.fromJson(jsonDecode(storedJson));
        final currentState = state;
        if (currentState is LocationsLoaded) {
          emit(LocationsLoaded(
            currentState.locations,
            selectedLocation: location,
          ));
        }
      } catch (_) {}
    }
  }
}
