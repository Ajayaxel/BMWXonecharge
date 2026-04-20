class CarbonCalculationResult {
  final double evEmission;
  final double iceEmission;
  final double co2Saved;
  final double treesSaved;
  final double fuelSavedLitres;

  CarbonCalculationResult({
    required this.evEmission,
    required this.iceEmission,
    required this.co2Saved,
    required this.treesSaved,
    required this.fuelSavedLitres,
  });
}

class CarbonEmissionService {
  // Static Data (Mocking Database)
  static const Map<String, double> gridFactors = {
    'IN': 0.82, // India (High coal dependence)
    'AE': 0.45, // UAE
    'DE': 0.35, // Germany
    'US': 0.38, // USA
    'UK': 0.25, // UK
    'NO': 0.02, // Norway (Hydropower)
  };

  static const Map<String, double> iceFactors = {
    'petrol': 0.15, // kg/km average
    'diesel': 0.18, // kg/km average
  };

  // Modern EV Consumption Data (kWh/km)
  static const Map<String, double> vehicleEfficiencies = {
    'hatchback': 0.15,
    'sedan': 0.17,
    'suv': 0.21,
    'luxury': 0.23,
  };

  static CarbonCalculationResult calculate({
    required double distanceKm,
    required String vehicleType, // hatchback, sedan, etc.
    required String location, // IN, AE, etc.
    String comparisonType = 'petrol',
  }) {
    // 1. Get Factors
    final gridFactor = gridFactors[location] ?? 0.5; // default fallback
    final evEfficiency = vehicleEfficiencies[vehicleType] ?? 0.18;
    final iceFactor = iceFactors[comparisonType] ?? 0.15;

    // 2. Run Calculations
    // Formula: CO2_EV = D * Ec * Gf
    final evEmission = distanceKm * evEfficiency * gridFactor;

    // Formula: CO2_ICE = D * Ef
    final iceEmission = distanceKm * iceFactor;

    // Formula: CO2_Saved = CO2_ICE - CO2_EV
    final co2Saved = iceEmission - evEmission;

    // 3. Convert into Equivalents
    // trees = saved / 21
    final treesSaved = co2Saved / 21.0;
    
    // fuel = saved / 2.31
    final fuelSavedLitres = co2Saved / 2.31;

    return CarbonCalculationResult(
      evEmission: evEmission,
      iceEmission: iceEmission,
      co2Saved: co2Saved,
      treesSaved: treesSaved,
      fuelSavedLitres: fuelSavedLitres,
    );
  }
}
