import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/vehicle_model.dart';

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
}
