import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/charging_type_model.dart';

class ChargingTypeRepository {
  final ApiClient apiClient;

  ChargingTypeRepository({required this.apiClient});

  Future<List<ChargingType>> getChargingTypes() async {
    try {
      final response = await apiClient.get('/customer/vehicles/masters');
      if (response.data['success'] == true) {
        final List<dynamic> chargingTypesJson =
            response.data['data']['charging_types'];
        return chargingTypesJson
            .map((json) => ChargingType.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load charging types: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
