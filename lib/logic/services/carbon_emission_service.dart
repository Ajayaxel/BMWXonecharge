import '../../core/network/api_client.dart';
import '../../models/carbon_emission_models.dart';

class CarbonEmissionService {
  final ApiClient _apiClient;

  CarbonEmissionService(this._apiClient);

  Future<List<GridFactor>> getGridFactors() async {
    try {
      final response = await _apiClient.get('/customer/emission/grid-factor');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => GridFactor.fromJson(json)).toList();
      }
      throw Exception('Failed to load grid factors');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VehicleData>> getVehicleData() async {
    try {
      final response = await _apiClient.get('/customer/emission/vehicle-data');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['vehicles'];
        return data.map((json) => VehicleData.fromJson(json)).toList();
      }
      throw Exception('Failed to load vehicle data');
    } catch (e) {
      rethrow;
    }
  }

  Future<EmissionResult> calculateEmission({
    required double distanceKm,
    required int vehicleId,
    required String location,
    String comparisonType = 'petrol',
  }) async {
    try {
      final response = await _apiClient.post(
        '/customer/emission/calculate-emission',
        data: {
          'distance_km': distanceKm,
          'vehicle_id': vehicleId,
          'comparison_type': comparisonType,
          'location': location,
        },
      );
      if (response.data['success'] == true) {
        return EmissionResult.fromJson(response.data['data']);
      }
      throw Exception('Failed to calculate emission');
    } catch (e) {
      rethrow;
    }
  }
}

