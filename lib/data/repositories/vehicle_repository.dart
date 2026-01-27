import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/vehicle_model.dart';
import 'package:onecharge/models/add_vehicle_model.dart';
import 'package:onecharge/models/vehicle_list_model.dart';

class VehicleRepository {
  final ApiClient apiClient;

  VehicleRepository({required this.apiClient});

  Future<List<VehicleModel>> getModels() async {
    try {
      final response = await apiClient.get('/customer/models');
      if (response.data['success'] == true) {
        final List<dynamic> modelsJson = response.data['data']['models'];
        return modelsJson.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load models: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AddVehicleResponse> addVehicle(AddVehicleRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/vehicles',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return AddVehicleResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to add vehicle: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VehicleListResponse> getVehicles() async {
    try {
      final response = await apiClient.get('/customer/vehicles');
      if (response.data['success'] == true) {
        return VehicleListResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load vehicles: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    try {
      final response = await apiClient.delete('/customer/vehicles/$vehicleId');
      if (response.data['success'] != true) {
        throw Exception(
          'Failed to delete vehicle: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
