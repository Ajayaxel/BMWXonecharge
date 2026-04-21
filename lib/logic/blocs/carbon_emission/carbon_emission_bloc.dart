import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/carbon_emission_service.dart';
import '../../../models/carbon_emission_models.dart';
import 'carbon_emission_event.dart';
import 'carbon_emission_state.dart';

class CarbonEmissionBloc extends Bloc<CarbonEmissionEvent, CarbonEmissionState> {
  final CarbonEmissionService _service;
  List<GridFactor> _gridFactors = [];
  List<VehicleData> _vehicles = [];

  CarbonEmissionBloc(this._service) : super(CarbonEmissionInitial()) {
    on<FetchGridFactorsAndVehicles>(_onFetchData);
    on<CalculateEmissionEvent>(_onCalculate);
  }

  Future<void> _onFetchData(
    FetchGridFactorsAndVehicles event,
    Emitter<CarbonEmissionState> emit,
  ) async {
    emit(CarbonEmissionLoading());
    try {
      _gridFactors = await _service.getGridFactors();
      _vehicles = await _service.getVehicleData();
      emit(CarbonEmissionDataLoaded(
        gridFactors: _gridFactors,
        vehicles: _vehicles,
      ));
    } catch (e) {
      emit(CarbonEmissionError(e.toString()));
    }
  }

  Future<void> _onCalculate(
    CalculateEmissionEvent event,
    Emitter<CarbonEmissionState> emit,
  ) async {
    emit(CarbonEmissionCalculating(
      gridFactors: _gridFactors,
      vehicles: _vehicles,
    ));
    try {
      final result = await _service.calculateEmission(
        distanceKm: event.distanceKm,
        vehicleId: event.vehicleId,
        location: event.location,
        comparisonType: event.comparisonType,
      );
      emit(CarbonEmissionCalculated(
        result: result,
        gridFactors: _gridFactors,
        vehicles: _vehicles,
      ));
    } catch (e) {
      emit(CarbonEmissionError(
        e.toString(),
        gridFactors: _gridFactors,
        vehicles: _vehicles,
      ));
    }
  }
}
