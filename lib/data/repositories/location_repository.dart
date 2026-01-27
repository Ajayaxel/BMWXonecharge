import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/location_model.dart';

class LocationRepository {
  final ApiClient apiClient;

  LocationRepository({required this.apiClient});

  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await apiClient.get('/customer/locations');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['locations'] != null) {
          final List<dynamic> locationsData = data['locations'];
          return locationsData
              .where((item) => item is Map<String, dynamic>)
              .map(
                (json) => LocationModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
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
}
