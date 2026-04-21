abstract class CarbonEmissionEvent {}

class FetchGridFactorsAndVehicles extends CarbonEmissionEvent {}

class CalculateEmissionEvent extends CarbonEmissionEvent {
  final double distanceKm;
  final int vehicleId;
  final String location;
  final String comparisonType;

  CalculateEmissionEvent({
    required this.distanceKm,
    required this.vehicleId,
    required this.location,
    this.comparisonType = 'petrol',
  });
}
