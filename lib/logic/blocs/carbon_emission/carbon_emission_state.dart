import '../../../models/carbon_emission_models.dart';

abstract class CarbonEmissionState {
  final List<GridFactor> gridFactors;
  final List<VehicleData> vehicles;

  CarbonEmissionState({
    this.gridFactors = const [],
    this.vehicles = const [],
  });
}

class CarbonEmissionInitial extends CarbonEmissionState {}

class CarbonEmissionLoading extends CarbonEmissionState {}

class CarbonEmissionCalculating extends CarbonEmissionState {
  CarbonEmissionCalculating({
    required super.gridFactors,
    required super.vehicles,
  });
}

class CarbonEmissionDataLoaded extends CarbonEmissionState {
  CarbonEmissionDataLoaded({
    required super.gridFactors,
    required super.vehicles,
  });
}

class CarbonEmissionCalculated extends CarbonEmissionState {
  final EmissionResult result;

  CarbonEmissionCalculated({
    required this.result,
    required super.gridFactors,
    required super.vehicles,
  });
}

class CarbonEmissionError extends CarbonEmissionState {
  final String message;
  CarbonEmissionError(
    this.message, {
    super.gridFactors = const [],
    super.vehicles = const [],
  });
}
