import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/location_model.dart';
import 'package:onecharge/models/location_config_model.dart';

class LocationRepository {
  final ApiClient apiClient;

  LocationRepository({required this.apiClient});

  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await apiClient.get('/customer/locations');
      if (response.data != null && response.data['success'] == true) {
        final listResponse = LocationListResponse.fromJson(response.data as Map<String, dynamic>);
        return listResponse.data.locations;
      } else {
        throw Exception(
          'Failed to fetch locations: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationModel> addLocation(LocationModel location) async {
    try {
      print('📤 [LocationRepository] Adding location: ${location.toJson()}');
      final response = await apiClient.post(
        '/customer/locations',
        data: location.toJson(),
      );
      print('📥 [LocationRepository] Response: ${response.data}');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('API returned success but data is null');
        }
        if (data is Map<String, dynamic> && data.containsKey('location')) {
          return LocationModel.fromJson(
            data['location'] as Map<String, dynamic>?,
          );
        }
        return LocationModel.fromJson(
          data is Map<String, dynamic> ? data : null,
        );
      } else {
        throw Exception(
          'Failed to add location: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLocation(int locationId) async {
    try {
      final response = await apiClient.delete(
        '/customer/locations/$locationId',
      );
      if (response.data['success'] != true) {
        throw Exception(
          'Failed to delete location: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationConfigResponse> getLocationConfig() async {
    try {
      final response = await apiClient.get('/customer/location-config');
      if (response.data != null && response.data['success'] == true) {
        return LocationConfigResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to fetch location config: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
