import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/service_group_model.dart';
import 'dart:developer' as developer;

class ServiceGroupRepository {
  final ApiClient apiClient;

  ServiceGroupRepository({required this.apiClient});

  Future<List<ServiceGroup>> getServiceGroups() async {
    try {
      final response = await apiClient.get('/customer/service-groups');
      developer.log("Service Groups Response: ${response.data}");
      
      if (response.data['success'] == true) {
        final List<dynamic> groupsJson = response.data['data']['service_groups'];
        return groupsJson.map((json) => ServiceGroup.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load service groups: ${response.data['message']}',
        );
      }
    } catch (e) {
      developer.log("Error in getServiceGroups: $e");
      rethrow;
    }
  }
}
