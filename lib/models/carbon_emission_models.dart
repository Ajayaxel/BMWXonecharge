class GridFactor {
  final String country;
  final double gridFactor;

  GridFactor({required this.country, required this.gridFactor});

  factory GridFactor.fromJson(Map<String, dynamic> json) {
    return GridFactor(
      country: json['country'] ?? '',
      gridFactor: (json['grid_factor'] ?? 0.0).toDouble(),
    );
  }
}

class VehicleData {
  final int id;
  final String name;
  final double consumptionKwhPerKm;

  VehicleData({
    required this.id,
    required this.name,
    required this.consumptionKwhPerKm,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      consumptionKwhPerKm: (json['consumption_kwh_per_km'] ?? 0.0).toDouble(),
    );
  }
}

class EmissionResult {
  final double evEmission;
  final double iceEmission;
  final double co2Saved;
  final double treesSaved;
  final double fuelSavedLitres;
  final String unit;

  EmissionResult({
    required this.evEmission,
    required this.iceEmission,
    required this.co2Saved,
    required this.treesSaved,
    required this.fuelSavedLitres,
    required this.unit,
  });

  factory EmissionResult.fromJson(Map<String, dynamic> json) {
    return EmissionResult(
      evEmission: (json['ev_emission'] ?? 0.0).toDouble(),
      iceEmission: (json['ice_emission'] ?? 0.0).toDouble(),
      co2Saved: (json['co2_saved'] ?? 0.0).toDouble(),
      treesSaved: (json['trees_saved'] ?? 0.0).toDouble(),
      fuelSavedLitres: (json['fuel_saved_litres'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'kg CO2',
    );
  }
}
